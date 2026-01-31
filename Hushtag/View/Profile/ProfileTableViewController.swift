//
//  ProfileTableViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit
import Auth
import Supabase

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var emailLabel: UILabel!
    
    private let profileController = ProfileController()
    private var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        showInstantProfile()
        fetchProfile()
        
    }
    
    private func showInstantProfile() {
        Task {
            do {
                let session = try await SupabaseConfig.client.auth.session
                let email = session.user.email ?? ""

                nameLabel.text = email
                emailLabel.text = email
                setInitialAvatar(from: email)
            } catch {
                // User not logged in yet — do nothing
            }
        }
    }
    
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
                    self.performSignOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
    }
    
    
    func performSignOut() {
        _Concurrency.Task {
                do {
                    // 1. Tell Supabase to kill the session
                    try await AuthManager.shared.signOut()
                    print("User signed out successfully")
                    
                    // 2. Navigate back to Login Screen
                    self.navigateToLoginScreen()
                    
                } catch {
                    print("Error signing out: \(error)")
                    self.showAlert(title: "Error", message: "Could not sign out. Please try again.")
                }
            }
        }
    
    
    
    private func fetchProfile() {
        Task {
            do {
                let profile = try await profileController.fetchProfile()
                self.profile = profile
                
                await MainActor.run {
                    self.updateUI(with: profile)
                }
            } catch {
                print("Failed to fetch profile:", error)
            }
        }
    }
    
    private func updateUI(with profile: Profile) {
        nameLabel.text = profile.fullName
        emailLabel.text = profile.email
        
        if let urlString = profile.avatarURL,
           let url = URL(string: urlString) {
            
            loadImage(from: url)
        } else {
            setInitialAvatar(from: profile.fullName)
        }
    }
    
    private func setInitialAvatar(from text: String) {
        let initial = text.first.map { String($0).uppercased() } ?? "U"
        profileImageView.image = generateInitialImage(initial)
    }
    
    
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }.resume()
    }
    
    private func generateInitialImage(_ initial: String) -> UIImage {
        let size = profileImageView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            UIColor.systemBlue.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: size.width / 2, weight: .semibold)
            ]
            
            let textSize = initial.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            initial.draw(in: rect, withAttributes: attributes)
        }
    }
    
    
    func setupUI() {
        profileImageView.layer.cornerRadius = 75
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        
        title = "Profile"
    }
}
