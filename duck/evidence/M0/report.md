# M0 Evidence — Shell, Design Tokens, Navigation

## Delivered
- Native iPhone SwiftUI application shell targeting iOS 18 with Swift 6.
- XcodeGen project specification and generated Xcode project.
- Semantic Quiet Earth palette with light/dark appearances, system typography, spacing, shape, and button tokens.
- Original contour-field motif implemented as native SwiftUI drawing.
- Opening screen using approved product copy.
- Two working navigation paths:
  - opening → privacy choice
  - opening → how it works → privacy choice
- Privacy-choice boundary screen for questionnaire-only, Ask-your-AI, and experimental import routes. Feature actions intentionally remain unimplemented until their milestones.

## Build and test evidence
Environment:
- Xcode 26.6 (build 17F113)
- Swift 6.3.3 toolchain, project language mode Swift 6
- iPhone 16 Pro simulator, iOS 18.1

Command:
```sh
xcodebuild -project ProjectStill.xcodeproj -scheme ProjectStill -sdk iphonesimulator -destination 'platform=iOS Simulator,id=51DA5274-448A-4988-A3FF-C4A970727791' -derivedDataPath .build/DerivedData test
```

Result: `TEST SUCCEEDED`
- 1 unit test passed: route accessibility titles.
- 2 UI tests passed: primary and explanatory onboarding routes both reach the privacy-choice screen.
- 0 failures.

Latest result bundle (local derived data, intentionally not versioned):
`.build/DerivedData/Logs/Test/Test-ProjectStill-2026.09.14_14-46-19-+0200.xcresult`

## Visual evidence
- `opening.png`: light appearance on iPhone 16 Pro.
- `opening-dark.png`: dark appearance on iPhone 16 Pro.
- Visual review found a dark-mode primary-label contrast defect; the implementation added a fixed `quietOnAccent` semantic token and the final build/screenshots were regenerated.

## Privacy and data flow
M0 contains no persistence, analytics, account, network client, import parser, microphone access, or third-party dependency. It neither collects nor transmits personal data. The privacy choices are presentation/navigation boundaries only.

## Accessibility notes
- Functional text uses Dynamic Type styles.
- Primary actions have a minimum 52-point height; secondary actions have a minimum 44-point height.
- Decorative contour drawing is hidden from accessibility and ignores hit testing.
- Screen headings are exposed as headers, related privacy-card text is combined, and navigation controls have stable UI-test identifiers.
- Light and dark appearances were visually inspected.

## Known issues / deliberately deferred work
- The app uses the generated placeholder icon; branded app-icon work is deferred to polish.
- Privacy-choice cards are non-interactive until M1, M2, and M7 respectively.
- Full Dynamic Type, VoiceOver traversal, contrast automation, localization, and Reduce Motion test passes remain milestone acceptance work as their associated screens mature.
- Xcode emits non-blocking LLDB version-store messages while launching UI tests; build and tests succeed.

