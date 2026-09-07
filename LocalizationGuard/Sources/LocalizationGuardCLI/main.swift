import Foundation

struct Settings: Decodable {
    var catalogs: [String] = []
    var requiredLocales: [String] = []
    var excludedPaths: [String] = ["Tests", "Generated", "PreviewContent", ".build"]
    var ignoredFunctions: [String] = ["print", "debugPrint", "assertionFailure", "preconditionFailure", "fatalError", "os_log"]

    private enum CodingKeys: String, CodingKey {
        case catalogs, requiredLocales, excludedPaths, ignoredFunctions
    }
}

let arguments = Array(CommandLine.arguments.dropFirst())
let root = URL(fileURLWithPath: arguments.first ?? FileManager.default.currentDirectoryPath)
    .standardizedFileURL
let stampPath: String? = arguments.indices.contains(2) && arguments[1] == "--stamp"
    ? arguments[2]
    : nil
let configURL = root.appendingPathComponent(".localizationguard.json")
let settings = (try? Data(contentsOf: configURL)).flatMap {
    try? JSONDecoder().decode(Settings.self, from: $0)
} ?? Settings()

func projectFiles(extension extensionName: String) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else { return [] }
    return enumerator.compactMap { item in
        guard let url = item as? URL, url.pathExtension == extensionName else { return nil }
        let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
        let parts = relative.split(separator: "/")
        return settings.excludedPaths.contains { parts.contains(Substring($0)) } ? nil : url
    }
}

let catalogURLs = settings.catalogs.isEmpty
    ? projectFiles(extension: "xcstrings")
    : settings.catalogs.map { root.appendingPathComponent($0) }
var keys = Set<String>()
var warnings: [String] = []

for catalogURL in catalogURLs {
    guard
        let data = try? Data(contentsOf: catalogURL),
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { continue }
    let sourceLanguage = json["sourceLanguage"] as? String ?? "en"
    let strings = json["strings"] as? [String: Any] ?? [:]
    keys.formUnion(strings.keys)

    for locale in settings.requiredLocales where locale != sourceLanguage {
        for (key, rawEntry) in strings {
            let entry = rawEntry as? [String: Any]
            let localizations = entry?["localizations"] as? [String: Any]
            let localization = localizations?[locale] as? [String: Any]
            let unit = localization?["stringUnit"] as? [String: Any]
            let value = unit?["value"] as? String
            if value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
                warnings.append("\(catalogURL.path):1:1: warning: [LG002] \"\(key)\"의 \(locale) 번역이 비어 있습니다.")
            }
        }
    }
}

let literalPatterns = [
    #"Text\s*\(\s*verbatim\s*:\s*\"((?:\\.|[^\"\\])*)\""#,
    #"(?:\.text\s*=|setTitle\s*\()\s*\"((?:\\.|[^\"\\])*)\""#,
    #"(?:Text|Button|Label|navigationTitle|accessibilityLabel)\s*\(\s*\"((?:\\.|[^\"\\])*)\""#,
]
let localizedKeyPattern = #"(?:String\s*\(\s*localized\s*:|LocalizedStringResource\s*\()\s*\"((?:\\.|[^\"\\])*)\""#
let anyStringLiteralPattern = #"\"((?:\\.|[^\"\\])*)\""#
let koreanPattern = #"[\u{AC00}-\u{D7A3}]"#

func matches(_ pattern: String, in line: String) -> [(value: String, column: Int)] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    return regex.matches(in: line, range: NSRange(line.startIndex..., in: line)).compactMap { match in
        guard match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: line) else { return nil }
        return (String(line[range]), match.range.location + 1)
    }
}

func decoded(_ value: String) -> String {
    let json = "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
    return (try? JSONDecoder().decode(String.self, from: Data(json.utf8))) ?? value
}

func containsKorean(_ value: String) -> Bool {
    value.range(of: koreanPattern, options: .regularExpression) != nil
}

func isIgnoredDiagnosticLine(_ line: String) -> Bool {
    settings.ignoredFunctions.contains { function in
        line.range(of: #"\b"# + NSRegularExpression.escapedPattern(for: function) + #"\s*\("#,
                   options: .regularExpression) != nil
    }
}

for file in projectFiles(extension: "swift") {
    guard let source = try? String(contentsOf: file, encoding: .utf8) else { continue }
    let lines = source.components(separatedBy: .newlines)
    var previewBraceDepth = 0
    var isInsidePreview = false
    var ignoredCallParenthesisDepth = 0

    for (index, line) in lines.enumerated() {
        if line.contains("#Preview") {
            isInsidePreview = true
        }
        if isInsidePreview {
            previewBraceDepth += line.filter { $0 == "{" }.count
            previewBraceDepth -= line.filter { $0 == "}" }.count
            if previewBraceDepth <= 0, line.contains("}") {
                isInsidePreview = false
                previewBraceDepth = 0
            }
            continue
        }

        if ignoredCallParenthesisDepth > 0 {
            ignoredCallParenthesisDepth += line.filter { $0 == "(" }.count
            ignoredCallParenthesisDepth -= line.filter { $0 == ")" }.count
            continue
        }

        if line.contains("localization-guard:disable-line") { continue }
        if index > 0, lines[index - 1].contains("localization-guard:disable-next-line") { continue }
        if isIgnoredDiagnosticLine(line) {
            ignoredCallParenthesisDepth = max(
                line.filter { $0 == "(" }.count - line.filter { $0 == ")" }.count,
                0
            )
            continue
        }

        for pattern in literalPatterns {
            for match in matches(pattern, in: line) {
                let value = decoded(match.value)
                if match.value.contains(#"\("#) {
                    warnings.append("\(file.path):\(index + 1):\(match.column): warning: [LG003] 문자열 보간은 String(localized:) 또는 LocalizedStringResource로 확인하세요.")
                } else if !value.isEmpty, !keys.contains(value) {
                    warnings.append("\(file.path):\(index + 1):\(match.column): warning: [LG001] \"\(value)\"가 String Catalog에 없습니다.")
                }
            }
        }
        for match in matches(localizedKeyPattern, in: line) {
            let key = decoded(match.value)
            if !keys.contains(key) {
                warnings.append("\(file.path):\(index + 1):\(match.column): warning: [LG004] 존재하지 않는 로컬라이제이션 키 \"\(key)\"입니다.")
            }
        }

        for match in matches(anyStringLiteralPattern, in: line) {
            let value = decoded(match.value)
            guard containsKorean(value) else { continue }

            if match.value.contains(#"\("#) {
                warnings.append("\(file.path):\(index + 1):\(match.column): warning: [LG003] 문자열 보간은 String(localized:) 또는 LocalizedStringResource로 확인하세요.")
            } else if !keys.contains(value) {
                warnings.append("\(file.path):\(index + 1):\(match.column): warning: [LG001] \"\(value)\"가 String Catalog에 없습니다.")
            }
        }
    }
}

for warning in Set(warnings).sorted() {
    fputs(warning + "\n", stderr)
}
let count = Set(warnings).count
let summary = count == 0 ? "누락 없음" : "\(count)개 확인 필요"
fputs("\(root.path):1:1: warning: [LG000] LocalizationGuard 실행 완료 — \(summary)\n", stderr)

if let stampPath {
    try? Data().write(to: URL(fileURLWithPath: stampPath))
}
