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
    func toMarkdownString() -> NSAttributedString {
        // 1. Attempt to parse Markdown (requires iOS 15+)
        guard let attributedString = try? NSAttributedString(
            markdown: self,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return NSAttributedString(string: self)
        }
        
        // 2. The Markdown parser often resets fonts to small/black.
        // We create a mutable copy to re-apply your app's font sizes and colors.
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = NSRange(location: 0, length: mutableString.length)
        
        // 3. Define your base styles (Adjust size/color to match your app design)
        let baseFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        // Adjust color based on your theme (e.g., .label for dark/light mode support)
        let textColor = UIColor.label
        
        // 4. Iterate through the string to preserve Bold traits while fixing font size
        mutableString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            if let font = value as? UIFont, font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                // If Markdown made it bold, apply YOUR bold font
                mutableString.addAttribute(.font, value: boldFont, range: range)
            } else {
                // Otherwise apply your regular font
                mutableString.addAttribute(.font, value: baseFont, range: range)
            }
        }
        
        // 5. Force the text color
        mutableString.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        
        return mutableString
    }
}
