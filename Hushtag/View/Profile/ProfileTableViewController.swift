//
//  ProfileTableViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit
import Supabase

final class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    private let profileController = ProfileController()
    private var profile: Profile?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        showInstantProfile()
        fetchProfile()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }

    // MARK: - Edit Profile
    @objc private func editButtonTapped() {
        guard let profile = profile else {
            showAlert(title: "Please wait", message: "Profile is still loading.")
            return
        }

        let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)

       
        if let editVC = storyboard.instantiateViewController(
            withIdentifier: "EditProfileViewController"
        ) as? EditProfileViewController {

            editVC.profile = profile
            editVC.delegate = self
            editVC.modalPresentationStyle = .fullScreen
            present(editVC, animated: true)
        }
    }

    // MARK: - Instant UI (no delay)
    private func showInstantProfile() {
        Task { @MainActor in
            do {
                let session = try await SupabaseConfig.client.auth.session
                let email = session.user.email ?? ""

                nameLabel.text = email
                emailLabel.text = email
                setInitialAvatar(from: email)
            } catch {
                // user not logged in
            }
        }
    }

    // MARK: - Fetch Profile from DB
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

    // MARK: - Update UI
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

    // MARK: - Helpers
    private func setInitialAvatar(from text: String) {
        let initial = text.first.map { String($0).uppercased() } ?? "U"
        profileImageView.image = generateInitialImage(initial)
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let image = UIImage(data: data)
            else { return }

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

    private func setupUI() {
        profileImageView.layer.cornerRadius = 75
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.systemGray4.cgColor

        title = "Profile"
    }
    
    func signOutTap(){
            let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
                        self.performSignOut()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
        }
        
        func performSignOut() {
            _Concurrency.Task { @MainActor in
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
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        // ✅ Section 3 → Sign Out
        if indexPath.section == 3 && indexPath.row == 0 {
            signOutTap()
        }
    }

}

// MARK: - EditProfileDelegate
extension ProfileTableViewController: EditProfileDelegate {
    func profileDidUpdate() {
        fetchProfile()
    }
    
    
}
