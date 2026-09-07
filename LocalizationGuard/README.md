# LocalizationGuard

Swift source and String Catalog cross-checking for localization gaps that Xcode can miss. The package intentionally contains only one scanner and one build plug-in.

## Rules

- `LG001`: UI-facing literal missing from a String Catalog
- `LG002`: Required locale is missing or empty
- `LG003`: Interpolated string requiring localization review
- `LG004`: Unknown explicit localization key, with typo suggestion

Suppress an intentional finding with:

```swift
// localization-guard:disable-next-line
Text(verbatim: "HTTP")
```

## Run

```sh
swift run LocalizationGuardCLI /path/to/your/project
swift run LocalizationGuardCLI /path/to/your/project --strict
```

Copy `.localizationguard.json.example` to `.localizationguard.json` in the scanned project and adjust the catalog paths and required locales.

Attach `LocalizationGuardPlugin` under the app target's **Build Phases → Run Build Tool Plug-ins** section. It runs on every build and prints an `LG000` completion summary so you can immediately verify that it ran.
