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

// MARK: - Markdown → NSAttributedString Renderer
// Tuned for openai/gpt-oss-20b output style (clean, concise, well-structured).
extension String {

    func toStyledScript() -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textColor = UIColor.white // bot bubble is gray, text is white

        let baseParagraph = NSMutableParagraphStyle()
        baseParagraph.lineSpacing = 4
        baseParagraph.paragraphSpacing = 6

        let result = NSMutableAttributedString()
        let lines = self.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let isLast = index == lines.count - 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // ── Horizontal rule (---, ***, ===) ──────────────────────────
            let isHRule = (trimmed.count >= 3) && (trimmed.allSatisfy { $0 == "-" } ||
                                                   trimmed.allSatisfy { $0 == "*" } ||
                                                   trimmed.allSatisfy { $0 == "=" })
            if isHRule {
                let sepStyle = NSMutableParagraphStyle()
                sepStyle.paragraphSpacingBefore = 8
                sepStyle.paragraphSpacing = 8
                result.append(NSAttributedString(
                    string: "─────────────────────\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 9),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.35),
                        .paragraphStyle: sepStyle
                    ]
                ))
                continue
            }

            // ── H1: # Heading ─────────────────────────────────────────────
            if line.hasPrefix("# ") {
                let text = String(line.dropFirst(2))
                let font = UIFont.systemFont(ofSize: 18, weight: .bold)
                let style = makePStyle(before: 10, after: 4)
                let attr = parseInline(text, font: font, color: textColor)
                attr.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attr.length))
                result.append(attr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── H2: ## Heading ────────────────────────────────────────────
            if line.hasPrefix("## ") {
                let text = String(line.dropFirst(3))
                let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                let style = makePStyle(before: 8, after: 3)
                let attr = parseInline(text, font: font, color: textColor)
                attr.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attr.length))
                result.append(attr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── H3: ### Heading ───────────────────────────────────────────
            if line.hasPrefix("### ") {
                let text = String(line.dropFirst(4))
                let font = UIFont.systemFont(ofSize: 15, weight: .medium)
                let style = makePStyle(before: 6, after: 2)
                let attr = parseInline(text, font: font, color: textColor)
                attr.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attr.length))
                result.append(attr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── Bullet list: - item or * item ─────────────────────────────
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                let text = String(trimmed.dropFirst(2))
                let bStyle = NSMutableParagraphStyle()
                bStyle.headIndent = 18
                bStyle.firstLineHeadIndent = 4
                bStyle.paragraphSpacing = 3
                bStyle.lineSpacing = 3

                let bulletAttr = NSMutableAttributedString(
                    string: "•  ",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                        .foregroundColor: UIColor.systemCyan,
                        .paragraphStyle: bStyle
                    ]
                )
                let content = parseInline(text, font: baseFont, color: textColor)
                content.addAttribute(.paragraphStyle, value: bStyle, range: NSRange(location: 0, length: content.length))
                bulletAttr.append(content)
                result.append(bulletAttr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── Numbered list: 1. item ────────────────────────────────────
            if let (numPart, bodyPart) = extractNumbered(line) {
                let nStyle = NSMutableParagraphStyle()
                nStyle.headIndent = 24
                nStyle.firstLineHeadIndent = 4
                nStyle.paragraphSpacing = 3
                nStyle.lineSpacing = 3

                let numFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
                let numAttr = NSMutableAttributedString(
                    string: numPart,
                    attributes: [
                        .font: numFont,
                        .foregroundColor: UIColor.systemMint,
                        .paragraphStyle: nStyle
                    ]
                )
                let content = parseInline(bodyPart, font: baseFont, color: textColor)
                content.addAttribute(.paragraphStyle, value: nStyle, range: NSRange(location: 0, length: content.length))
                numAttr.append(content)
                result.append(numAttr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── Blockquote: > text ────────────────────────────────────────
            if trimmed.hasPrefix("> ") || trimmed == ">" {
                let text = trimmed.hasPrefix("> ") ? String(trimmed.dropFirst(2)) : ""
                let qStyle = NSMutableParagraphStyle()
                qStyle.headIndent = 16
                qStyle.firstLineHeadIndent = 16
                qStyle.paragraphSpacing = 3
                let qFont = UIFont.italicSystemFont(ofSize: 14)
                let qAttr = parseInline("▎  " + text, font: qFont, color: UIColor.white.withAlphaComponent(0.6))
                qAttr.addAttribute(.paragraphStyle, value: qStyle, range: NSRange(location: 0, length: qAttr.length))
                result.append(qAttr)
                if !isLast { result.append(nl()) }
                continue
            }

            // ── Empty line ────────────────────────────────────────────────
            if trimmed.isEmpty {
                result.append(NSAttributedString(string: "\n"))
                continue
            }

            // ── Regular paragraph ─────────────────────────────────────────
            let parsed = parseInline(line, font: baseFont, color: textColor)
            parsed.addAttribute(.paragraphStyle, value: baseParagraph, range: NSRange(location: 0, length: parsed.length))
            result.append(parsed)
            if !isLast { result.append(nl()) }
        }

        return result
    }

    // MARK: - Inline formatting parser

    private func parseInline(_ text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: color]
        )

        // Bold+Italic: ***text***
        let biDesc = font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        applyInline("\\*\\*\\*(.*?)\\*\\*\\*", to: result,
                    font: UIFont(descriptor: biDesc ?? font.fontDescriptor, size: 0),
                    color: color)

        // Bold: **text**
        let bDesc = font.fontDescriptor.withSymbolicTraits(.traitBold)
        applyInline("\\*\\*(.*?)\\*\\*", to: result,
                    font: UIFont(descriptor: bDesc ?? font.fontDescriptor, size: 0),
                    color: UIColor.white)   // pure white for bold emphasis

        // Italic: _text_
        let iDesc = font.fontDescriptor.withSymbolicTraits(.traitItalic)
        applyInline("_(.*?)_", to: result,
                    font: UIFont(descriptor: iDesc ?? font.fontDescriptor, size: 0),
                    color: color)

        // Inline code: `code`
        applyInline("`(.*?)`", to: result,
                    font: UIFont.monospacedSystemFont(ofSize: font.pointSize - 1, weight: .regular),
                    color: UIColor.systemYellow,
                    backgroundColor: UIColor.black.withAlphaComponent(0.25))

        return result
    }

    private func applyInline(
        _ pattern: String,
        to attrStr: NSMutableAttributedString,
        font: UIFont,
        color: UIColor,
        backgroundColor: UIColor? = nil
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let str = attrStr.string
        let matches = regex.matches(in: str, range: NSRange(location: 0, length: str.utf16.count))
        for match in matches.reversed() {
            guard match.numberOfRanges > 1,
                  let innerRange = Range(match.range(at: 1), in: str) else { continue }
            var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
            if let bg = backgroundColor { attrs[.backgroundColor] = bg }
            attrStr.replaceCharacters(
                in: match.range,
                with: NSAttributedString(string: String(str[innerRange]), attributes: attrs)
            )
        }
    }

    // MARK: - Helpers

    private func makePStyle(before: CGFloat, after: CGFloat) -> NSParagraphStyle {
        let s = NSMutableParagraphStyle()
        s.paragraphSpacingBefore = before
        s.paragraphSpacing = after
        s.lineSpacing = 3
        return s
    }

    private func nl() -> NSAttributedString { NSAttributedString(string: "\n") }

    private func extractNumbered(_ line: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^(\\d+\\.\\s+)(.*)"),
              let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)),
              match.numberOfRanges == 3,
              let a = Range(match.range(at: 1), in: line),
              let b = Range(match.range(at: 2), in: line)
        else { return nil }
        return (String(line[a]), String(line[b]))
    }
}
