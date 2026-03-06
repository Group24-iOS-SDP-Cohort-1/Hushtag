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
    func toStyledScript() -> NSAttributedString {
        // 1. Define your Design System
        //      let baseFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        //      let boldFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        let boldDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(.traitBold)
        let boldFont = UIFont(descriptor: boldDescriptor!, size: 0)
        let textColor = UIColor.label
        let bulletColor = UIColor.systemBlue
        
        // Paragraph style for normal text
        let baseParagraph = NSMutableParagraphStyle()
        //baseParagraph.lineSpacing = 6
        //baseParagraph.paragraphSpacing = 12 // Reduced slightly to tighten general spacing
        
        // Paragraph style for Bullet Points
        let bulletParagraph = NSMutableParagraphStyle()
        //bulletParagraph.lineSpacing = 4
        //bulletParagraph.paragraphSpacing = 6
        bulletParagraph.headIndent = 20
        bulletParagraph.firstLineHeadIndent = 0
        
        // 2. Start with the raw string
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: baseFont,
                .foregroundColor: textColor,
                .paragraphStyle: baseParagraph
            ]
        )
        
        // 3. PARSE BOLD (**text**)
        let boldRegex = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        let matches = boldRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in matches.reversed() {
            let fullRange = match.range
            let innerRange = match.range(at: 1)
            
            if let swiftRange = Range(innerRange, in: self) {
                let innerText = String(self[swiftRange])
                attributedString.replaceCharacters(in: fullRange, with: innerText)
                let newRange = NSRange(location: fullRange.location, length: innerText.utf16.count)
                attributedString.addAttribute(.font, value: boldFont, range: newRange)
            }
        }
        
        // 4. PARSE BULLETS (* text)
        let stringContent = attributedString.string
        let bulletRegex = try! NSRegularExpression(pattern: "^\\s*\\*\\s+(.*)$", options: .anchorsMatchLines)
        let bulletMatches = bulletRegex.matches(in: stringContent, options: [], range: NSRange(location: 0, length: stringContent.utf16.count))
        
        for match in bulletMatches.reversed() {
            let fullRange = match.range
            let contentRange = match.range(at: 1)
            
            let nsString = stringContent as NSString
            let contentText = nsString.substring(with: contentRange)
            
            let replacement = "•  \(contentText)"
            attributedString.replaceCharacters(in: fullRange, with: replacement)
            
            let newRange = NSRange(location: fullRange.location, length: replacement.utf16.count)
            attributedString.addAttribute(.paragraphStyle, value: bulletParagraph, range: newRange)
            
            let bulletRange = NSRange(location: fullRange.location, length: 1)
            attributedString.addAttribute(.foregroundColor, value: bulletColor, range: bulletRange)
        }
        
        // 5. CLEANUP: Remove "---" lines AND the surrounding extra newlines
        // The regex now looks for: (newline) + (---) + (newline)
        let separatorRegex = try! NSRegularExpression(pattern: "\\n+\\s*---\\s*\\n+", options: [])
        let separatorMatches = separatorRegex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.string.utf16.count))
        
        for match in separatorMatches.reversed() {
            // Replace the whole block with just TWO newlines (Standard paragraph break)
            // This turns [Text] \n\n --- \n\n [Text]  --->  [Text] \n\n [Text]
            attributedString.replaceCharacters(in: match.range, with: "\n\n")
        }
        
        return attributedString
    }
}
