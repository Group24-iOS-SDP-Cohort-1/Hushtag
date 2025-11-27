//
//  ScriptedIdeas.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class ScriptedIdeas: UIViewController {

    @IBOutlet weak var script: UITextView!

    var idea: Idea?

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let idea = idea else {
            label.text = "No idea received."
            script.text = "No idea received."
            return
        }

       
        let titleLabel = UILabel()
        titleLabel.text = idea.title
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.titleView = titleLabel

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: view.bounds.width - 100)
        ])

        label.text = idea.title
        loadHTMLFile(for: idea)
    }

    private func loadHTMLFile(for idea: Idea) {
        let fileName = idea.script.replacingOccurrences(of: ".html", with: "")
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "html") else {
            script.text = "HTML file not found."
            return
        }
        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            let attributed = try NSAttributedString(
                data: Data(html.utf8),
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            script.attributedText = attributed
        } catch {
            script.text = "Error loading HTML."
        }
    }

  }
