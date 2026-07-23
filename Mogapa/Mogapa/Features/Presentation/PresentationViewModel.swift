//
//  PresentationViewModel.swift
//  Mogapa
//
//  Created by sun on 7/21/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class PresentationViewModel {

    let text: String

    private let speechManager: SpeechManager

    private(set) var tokens: [SpeechToken] = []

    init(
        text: String = """
        안녕하세요 이게 150자까지만 가능해서 확인용 텍스트를 작성 중입니다. 리스트에 표시된 특정 단어를 누르면 해당 단어부터 음성 재생이 시작됩니다. 현재 읽고 있는 단어는 노란색으로 표시되고 이미 읽은 단어는 흰색으로 표시됩니다.안녕하세요 이게 150자까지만 가능해서 확인용 텍스트를 작성 중입니다. 리스트에 표시된 특정 단어를 누르면 해당 단어부터 음성 재생이 시작됩니다. 현재 읽고 있는 단어는 노란색으로 표시되고 이미 읽은 단어는 흰색으로 표시됩니다.안녕하세요 이게 150자까지만 가능해서 확인용 텍스트를 작성 중입니다. 리스트에 표시된 특정 단어를 누르면 해당 단어부터 음성 재생이 시작됩니다. 현재 읽고 있는 단어는 노란색으로 표시되고 이미 읽은 단어는 흰색으로 표시됩니다.
        """
    ) {
        self.text = text
        self.speechManager = SpeechManager()
        self.tokens = Self.makeTokens(from: text)
    }

    // MARK: - 재생 상태

    var isActive: Bool {
        speechManager.activeText == text
    }

    var isSpeaking: Bool {
        isActive && speechManager.playbackState == .speaking
    }

    var mainPlaybackIcon: String {
        guard isActive else {
            return "speaker.wave.2.fill"
        }

        switch speechManager.playbackState {
        case .speaking:
            return "pause.fill"

        case .paused:
            return "play.fill"

        case .stopped:
            return "play.fill"
        }
    }

    // MARK: - 재생 제어

    func handleMainPlaybackButton() {
        guard isActive else {
            speechManager.play(text)
            return
        }

        switch speechManager.playbackState {
        case .speaking:
            speechManager.pause()

        case .paused:
            speechManager.resume()

        case .stopped:
            speechManager.play(text)
        }
    }

    func play(from token: SpeechToken) {
        let startOffset = playableStartOffset(for: token)

        speechManager.play(
            text,
            fromUTF16Offset: startOffset
        )
    }

    func stop() {
        speechManager.stop()
    }

    // MARK: - 단어 상태

    func tokenDisplayState(
        for token: SpeechToken
    ) -> TokenDisplayState {
        guard isActive else {
            return .unspoken
        }

        if isCurrentlySpeaking(token) {
            return .speaking
        }

        let tokenEnd =
            token.range.location
            + token.range.length

        if tokenEnd <= speechManager.spokenLength {
            return .spoken
        }

        return .unspoken
    }

    func isCurrentlySpeaking(
        _ token: SpeechToken
    ) -> Bool {
        guard isActive,
              let highlightedRange =
                speechManager.highlightedRange else {
            return false
        }

        return NSIntersectionRange(
            token.range,
            highlightedRange
        ).length > 0
    }

    // MARK: - 스크롤 추적

    var currentSpeakingTokenID: Int? {
        tokens.first { isCurrentlySpeaking($0) }?.id
    }
    // MARK: - 접근성

    func accessibilityText(
        for token: SpeechToken
    ) -> String {
        let trimmedText = token.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedText.isEmpty else {
            return "다음 문장부터 재생"
        }

        return "\(trimmedText)부터 재생"
    }

    // MARK: - 글자 크기

    func responsiveFontSize(
        for size: CGSize
    ) -> CGFloat {
        switch size.width {
        case ..<700:
            return 28

        case ..<950:
            return 36

        default:
            return 44
        }
    }

    // MARK: - 재생 시작 위치

    private func playableStartOffset(
        for token: SpeechToken
    ) -> Int {
        let nsText = text as NSString
        var offset = token.range.location

        while offset < nsText.length {
            let character = nsText.substring(
                with: NSRange(
                    location: offset,
                    length: 1
                )
            )

            let trimmedCharacter =
                character.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            if !trimmedCharacter.isEmpty {
                break
            }

            offset += 1
        }

        return min(
            offset,
            max(nsText.length - 1, 0)
        )
    }

    // MARK: - 단어 분리

    private static func makeTokens(
        from text: String
    ) -> [SpeechToken] {
        let nsText = text as NSString

        guard nsText.length > 0 else {
            return []
        }

        guard let regex = try? NSRegularExpression(
            // 단어 뒤 공백까지 하나의 토큰으로 포함
            pattern: #"[^ \t\n]+[ \t]*|\n"#,
            options: []
        ) else {
            return []
        }

        let matches = regex.matches(
            in: text,
            options: [],
            range: NSRange(
                location: 0,
                length: nsText.length
            )
        )

        return matches.enumerated().map {
            index,
            match in

            SpeechToken(
                id: index,
                text: nsText.substring(
                    with: match.range
                ),
                range: match.range
            )
        }
    }
}

// MARK: - 화면 표시 상태

extension PresentationViewModel {

    enum TokenDisplayState {
        case spoken
        case speaking
        case unspoken
    }
}
