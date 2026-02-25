//
//  ScriptedIdeas.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

extension Notification.Name {
    static let scriptDeleted = Notification.Name("scriptDeleted")
}

class ScriptedIdeas: UIViewController {

    @IBOutlet weak var script: UITextView!

    var idea: ScriptedIdea?

    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var scriptTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var descriptionStack: UIStackView!
    @IBOutlet weak var scriptStack: UIStackView!
    @IBOutlet weak var popupButton: UIButton!


    @IBOutlet weak var optionsBarButton: UIBarButtonItem!
    
    private let dbController = ScriptedIdeasController()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        scriptStack.isHidden = true
        descriptionStack.isHidden = true
        imageStack.isHidden = true
        
        guard let idea = idea else {
            script.text = "No idea received."
            return
        }
        
        
        setupNavigationTitle(with: idea.title)
        setupDescription(with: idea.description)
        setupScriptContent(with: idea.script)
        setupThumbnail(with: idea.thumbnailURL)
        
        setupMenu()
    }
    
    private func setupMenu() {
        // Option 1: View Chat History
        let chatAction = UIAction(title: "View Chat History", image: UIImage(systemName: "bubble.left.and.bubble.right.fill")) { [weak self] _ in
            //self?.navigateToChat()
        }
        
        // Option 2: Delete Script (Destructive)
        let deleteAction = UIAction(title: "Delete Script", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.confirmDelete()
        }
        
        // Attach menu to the bar button
        let menu = UIMenu(title: "", children: [chatAction, deleteAction])
        optionsBarButton.menu = menu
    }
    
//    private func navigateToChat() {
//            guard let idea = self.idea else { return }
//            
//            let storyboard = UIStoryboard(name: "Chatbot", bundle: nil) // Ensure this matches your Storyboard name
//            if let chatVC = storyboard.instantiateViewController(withIdentifier: "Chatbot") as? Chatbot {
//                
//                // Pass the current script to the chatbot so it loads history
//             
//                
//                self.navigationController?.pushViewController(chatVC, animated: true)
//            }
//        }
    
    private func confirmDelete() {
        let alert = UIAlertController(title: "Delete Script", message: "Are you sure? This cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete()
        }))
        
        present(alert, animated: true)
    }
        
    private func performDelete() {
        guard let id = idea?.id else { return }
        
        Task {
            do {
                // Call Supabase to delete
                //try await dbController.deleteScript(id)
                
                NotificationCenter.default.post(
                    name: .scriptDeleted,
                    object: nil,
                    userInfo: ["deletedID": id]
                )
                
                await MainActor.run {
                    // Navigate back to the list
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error deleting script: \(error)")
                // Optional: Show error alert
            }
        }
    }
    
    private func setupNavigationTitle(with title: String?) {
            let titleText = title ?? "Untitled Script"
            
            let titleLabel = UILabel()
            titleLabel.text = titleText
            titleLabel.numberOfLines = 3
            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.navigationItem.titleView = titleLabel
            
            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: view.bounds.width - 150)
            ])
        }
        
        private func setupDescription(with description: String?) {
            guard let desc = description, !desc.isEmpty else {
                descriptionStack.isHidden = true
                return
            }
            
            descriptionStack.isHidden = false
            descriptionTitle.text = "Description"
            Description.text = desc
            Description.numberOfLines = 0 // Allow unlimited lines
        }
        
        private func setupScriptContent(with scriptContent: String?) {
            // If script is nil or empty, hide the stack
            guard let content = scriptContent, !content.isEmpty else {
                scriptStack.isHidden = true
                return
            }
            
            scriptStack.isHidden = false
            scriptTitle.text = "Script"
            
            // Styling the script text directly
            script.attributedText = content.toStyledScript()
            //script.font = UIFont.systemFont(ofSize: 16)
            script.textColor = .label // Adapts to Dark/Light mode automatically
            script.isEditable = false
        }
        
        private func setupThumbnail(with urlString: String?) {
            // Safe check: Is the string valid?
            guard let imageName = urlString, !imageName.isEmpty else {
                imageStack.isHidden = true
                return
            }
            
            // Check if image exists in Assets (Local)
            if let localImage = UIImage(named: imageName) {
                imageStack.isHidden = false
                imageView.image = localImage
            }
            // Logic for Remote URL (Placeholder for when you implement image downloading later)
            else {
                // print("Image URL found but not in assets: \(imageName)")
                // Here you would use Kingfisher or URLSession to download the image
                imageStack.isHidden = true
            }
        }
    
    
    

    @IBAction func schedule(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddPostViewController", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "AddPostNavVC")
        modalVC.modalPresentationStyle = .pageSheet
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)


    }
}
