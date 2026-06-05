import UIKit

extension UIViewController {
    func enableKeyboardDismissOnTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    private struct ScriptStyles {
        let baseFont: UIFont
        let boldFont: UIFont
        let textColor: UIColor
        let bulletColor: UIColor
        let baseParagraph: NSParagraphStyle
        let bulletParagraph: NSParagraphStyle
    }

    func toStyledScript() -> NSAttributedString {
        let styles = setupScriptStyles()

        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: styles.baseFont,
                .foregroundColor: styles.textColor,
                .paragraphStyle: styles.baseParagraph
            ]
        )

        parseBold(in: attributedString, with: styles.boldFont)
        parseBullets(in: attributedString, with: styles.bulletParagraph, color: styles.bulletColor)
        cleanupSeparators(in: attributedString)

        return attributedString
    }

    private func setupScriptStyles() -> ScriptStyles {
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            .withSymbolicTraits(.traitBold)
        let boldFont = UIFont(descriptor: boldDescriptor!, size: 0)

        let bulletParagraph = NSMutableParagraphStyle()
        bulletParagraph.headIndent = 20
        bulletParagraph.firstLineHeadIndent = 0

        return ScriptStyles(
            baseFont: baseFont,
            boldFont: boldFont,
            textColor: .label,
            bulletColor: .systemBlue,
            baseParagraph: NSMutableParagraphStyle(),
            bulletParagraph: bulletParagraph
        )
    }

    private func parseBold(in attributedString: NSMutableAttributedString, with boldFont: UIFont) {
        guard let regex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: []) else { return }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        for match in matches.reversed() {
            let fullRange = match.range
            if let swiftRange = Range(match.range(at: 1), in: self) {
                let innerText = String(self[swiftRange])
                attributedString.replaceCharacters(in: fullRange, with: innerText)
                let newRange = NSRange(location: fullRange.location, length: innerText.utf16.count)
                attributedString.addAttribute(.font, value: boldFont, range: newRange)
            }
        }
    }

    private func parseBullets(
        in attributedString: NSMutableAttributedString,
        with style: NSParagraphStyle,
        color: UIColor
    ) {
        let stringContent = attributedString.string
        guard let regex = try? NSRegularExpression(
            pattern: "^\\s*\\*\\s+(.*)$",
            options: .anchorsMatchLines
        ) else { return }

        let range = NSRange(location: 0, length: stringContent.utf16.count)
        let matches = regex.matches(in: stringContent, options: [], range: range)
        for match in matches.reversed() {
            let fullRange = match.range
            let contentText = (stringContent as NSString).substring(with: match.range(at: 1))
            let replacement = "•  \(contentText)"

            attributedString.replaceCharacters(in: fullRange, with: replacement)
            let newRange = NSRange(location: fullRange.location, length: replacement.utf16.count)
            attributedString.addAttribute(.paragraphStyle, value: style, range: newRange)
            let bulletRange = NSRange(location: fullRange.location, length: 1)
            attributedString.addAttribute(.foregroundColor, value: color, range: bulletRange)
        }
    }

    private func cleanupSeparators(in attributedString: NSMutableAttributedString) {
        guard let regex = try? NSRegularExpression(pattern: "\\n+\\s*---\\s*\\n+", options: []) else { return }
        let range = NSRange(location: 0, length: attributedString.string.utf16.count)
        let matches = regex.matches(in: attributedString.string, options: [], range: range)
        for match in matches.reversed() {
            attributedString.replaceCharacters(in: match.range, with: "\n\n")
        }
    }
}
