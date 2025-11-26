//
//  ScriptedIdea.swift
//  Hushtag
//
//  Created by SDC-USER on 26/11/25.
//

//
//  ScriptedIdea.swift
//  Hushtag
//
//  Created by SDC-USER on 26/11/25.
//
import UIKit

class ScriptedIdea: UIViewController {



    @IBOutlet weak var scriptTextView: UITextView!



    private var idea: Idea?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        loadFirstIdea()
    }

    private func setupTextView() {
        scriptTextView.isEditable = false
        scriptTextView.isScrollEnabled = true
        scriptTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private func loadFirstIdea() {
        do {
            let ideaResponse = try IdeaResponse()  // loads your JSON
            guard let firstIdea = ideaResponse.ideas.first else {
                scriptTextView.text = "No ideas found."
                return
            }
            self.idea = firstIdea
            loadScript()
        } catch {
            print("❌ Failed to load JSON:", error)
            scriptTextView.text = "Failed to load ideas."
        }
    }

    private func loadScript() {
        guard let idea = idea else { return }

        let fileName = idea.script.replacingOccurrences(of: ".html", with: "")
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "html") else {
            scriptTextView.text = "Script file not found."
            return
        }

        do {
            let htmlString = try String(contentsOf: fileURL, encoding: .utf8)
            let data = Data(htmlString.utf8)

            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 12
            attributedString.addAttribute(.paragraphStyle,
                                          value: paragraphStyle,
                                          range: NSRange(location: 0, length: attributedString.length))

            scriptTextView.attributedText = attributedString

        } catch {
            print("❌ Error loading HTML:", error)
            scriptTextView.text = "Failed to load script."
        }
    }
}

