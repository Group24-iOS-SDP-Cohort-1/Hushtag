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

    @IBOutlet weak var tagIdea: UIButton!

    @IBOutlet weak var descriptionTitle: UILabel!

    @IBOutlet weak var Description: UILabel!


    @IBOutlet weak var scriptTitle: UILabel!


    @IBOutlet weak var imageView: UIImageView!


    @IBOutlet weak var imageStack: UIStackView!


    @IBOutlet weak var descriptionStack: UIStackView!


    @IBOutlet weak var scriptStack: UIStackView!


    @IBOutlet weak var popupButton: UIButton!

    var onFilterSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        scriptStack.isHidden = true
        descriptionStack.isHidden = true
        guard let idea = idea else {
            script.text = "No idea received."
            return
        }

        setupPopupMenu()
        // Navigation title
        let titleLabel = UILabel()
        titleLabel.text = idea.title
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.titleView = titleLabel
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: view.bounds.width - 150)
        ])

        // Description
        if idea.description.isEmpty {
            descriptionStack.isHidden = true

        } else {
            descriptionStack.isHidden = false
            descriptionTitle.text = "Description"
            Description.text = idea.description
            Description.numberOfLines = 10
        }

        // Image
        if idea.thumbnail.isEmpty || UIImage(named: idea.thumbnail) == nil {
            imageStack.isHidden = true
        } else {
            imageStack.isHidden = false
            imageView.image = UIImage(named: idea.thumbnail)
        }

        // Script
        loadHTMLFile(for: idea)
    }
    private func loadHTMLFile(for idea: Idea) {
        // Hide by default
        scriptStack.isHidden = true

        // Check if idea.script exists
        let scriptName = idea.script.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !scriptName.isEmpty else {
            return
        }

        let fileName = scriptName.replacingOccurrences(of: ".html", with: "")
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "html") else {
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

            // Only show if the HTML actually has content
            if !attributed.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                script.attributedText = attributed
                scriptTitle.text = "Script"
                scriptStack.isHidden = false
            }
        } catch {
            print("Error loading HTML: \(error.localizedDescription)")
        }
    }

    func applyFilter(_ filter: String) {

        switch filter {
        case "Week":
            print("Showing past week analysis")


        case "month":
            print("Showing past month analysis")

        case "3weeks":
            print("Showing past 3 weeks analysis")


        default:
            break
        }



    }

    func setupPopupMenu() {

        let option1 = UIAction(title: "Past week") { _ in
            self.popupButton.setTitle("Past week", for: .normal)
            self.onFilterSelected?("week")
        }

        let option2 = UIAction(title: "Past month") { _ in
            self.popupButton.setTitle("Past month", for: .normal)
            self.onFilterSelected?("month")
        }

        let option3 = UIAction(title: "Past 3 weeks") { _ in
            self.popupButton.setTitle("Past month", for: .normal)
            self.onFilterSelected?("3weeks")
        }

        popupButton.menu = UIMenu(title: "", children: [option1, option2, option3])
        popupButton.showsMenuAsPrimaryAction = true
    }
}
