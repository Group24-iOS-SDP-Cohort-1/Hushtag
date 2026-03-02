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
    
    func deleteAccountTap() {
            let alert = UIAlertController(
                title: "Delete Account",
                message: "Are you sure you want to permanently delete your account? This action cannot be undone.",
                preferredStyle: .alert // .alert is usually better for destructive actions than .actionSheet
            )
                        
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.performAccountDeletion()
            }))
                        
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
            self.present(alert, animated: true)
        }
    
    // MARK: - Manual Session Purge
        private func forceClearLocalSession() {
            // 1. Wipe the Keychain items (Supabase stores its auth tokens as generic passwords)
            let keychainQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword
            ]
            
            let status = SecItemDelete(keychainQuery as CFDictionary)
            if status == errSecSuccess || status == errSecItemNotFound {
                print("Keychain wiped successfully.")
            } else {
                print("Keychain wipe returned status: \(status)")
            }
            
            // 2. Wipe UserDefaults fallbacks (just in case the SDK fell back to standard defaults)
            let defaults = UserDefaults.standard
            for key in defaults.dictionaryRepresentation().keys {
                if key.lowercased().contains("supabase") || key.lowercased().contains("gotrue") {
                    defaults.removeObject(forKey: key)
                }
            }
            
            print("Nuclear option executed: Local session data destroyed.")
        }
            
    func performAccountDeletion() {
            Task { @MainActor in
                
                // BLOCK 1: Backend Deletion using RPC
                do {
                    try await SupabaseConfig.client.database.rpc("delete_user").execute()
                    print("Backend deletion executed.")
                } catch {
                    print("Backend deletion finished (expected auth error): \(error.localizedDescription)")
                }
                
                // BLOCK 2: Local Cleanup
                do {
                    // Try the graceful local sign out
                    try await SupabaseConfig.client.auth.signOut(scope: .local)
                    print("Graceful local sign out succeeded.")
                } catch {
                    // When the SDK throws the "sub claim" error, obliterate the keys manually
                    print("Graceful sign out failed. Applying manual purge...")
                    self.forceClearLocalSession()
                }
                
                // BLOCK 3: UI Navigation
                self.navigateToLoginScreen()
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
        }else if indexPath.section == 3 && indexPath.row == 1 {
            deleteAccountTap()
        }
    }

}

// MARK: - EditProfileDelegate
extension ProfileTableViewController: EditProfileDelegate {
    func profileDidUpdate() {
        fetchProfile()
    }
    
    
}
