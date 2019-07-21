import Danger
let danger = Danger()

let violations = SwiftLint.lint(inline: true)

if violations.isEmpty {
    message("All checks passed. Good job!!!")
} else {
    let violationString = violations.count > 1 ? "violations" : "violation"
    warn(
        "Found \(violations.count) \(violationString)! " +
        "You can run `swiftlint autocorrect` in terminal to fix minor violations.")
}
