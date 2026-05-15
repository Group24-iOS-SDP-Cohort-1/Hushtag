import UIKit
import Supabase

final class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var youtubeStatusLabel: UILabel!
    @IBOutlet weak var youtubeStatusDot: UIView!
    
    
    private let profileController = ProfileController()
    private var profile: Profile?
    
    
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
    
    
    private func showInstantProfile() {
        Task { @MainActor in
            do {
                let appUser = try await AuthManager.shared.getCurrentSession()
                let email = appUser.email ?? ""
                let name = appUser.fullName ?? email
                
                nameLabel.text = name
                emailLabel.text = email
                setInitialAvatar(from: name)
            } catch {
                // user not logged in
            }
        }
    }
    
    
    private func fetchProfile() {
        Task {
            do {
                let profile = try await profileController.fetchProfile()
                let appUser = try await AuthManager.shared.getCurrentSession()
                
                await MainActor.run {
                    self.profile = profile
                    self.updateUI(with: profile, appUser: appUser)
                }
            } catch {
                //print("Failed to fetch profile:", error)
            }
        }
    }
    
    
    private func updateUI(with profile: Profile, appUser: AppUser) {
        let displayName = appUser.fullName ?? profile.fullName
        nameLabel.text = displayName
        emailLabel.text = appUser.email ?? profile.email
        
        if let urlString = profile.avatarURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            setInitialAvatar(from: displayName)
        }
        
        if profile.isYouTubeConnected {
            youtubeStatusLabel.text = "Connected"
            youtubeStatusDot.backgroundColor = .systemGreen
        } else {
            youtubeStatusLabel.text = "Not Connected"
            youtubeStatusDot.backgroundColor = .systemRed
        }
    }
    
    
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
        youtubeStatusDot.layer.cornerRadius = youtubeStatusDot.frame.width / 2
        youtubeStatusDot.clipsToBounds = true
    }
    
    func signOutTap(){
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: {[weak self] _ in
            self?.performSignOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func performSignOut() {
        _Concurrency.Task { @MainActor in
            do {
                
                try await AuthManager.shared.signOut()
                //print("User signed out successfully")
                
                
                self.navigateToLoginScreen()
                
            } catch {
                //print("Error signing out: \(error)")
                self.showAlert(title: "Error", message: "Could not sign out. Please try again.")
            }
        }
    }
    
    func deleteAccountTap() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            self?.performAccountDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    private func forceClearLocalSession() {
        
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            //print("Keychain wiped successfully.")
        } else {
            //print("Keychain wipe returned status: \(status)")
        }
        
        
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            if key.lowercased().contains("supabase") || key.lowercased().contains("gotrue") {
                defaults.removeObject(forKey: key)
            }
        }
        
        //print("Nuclear option executed: Local session data destroyed.")
    }
    
    func performAccountDeletion() {
        Task { @MainActor in
            
            
            do {
                try await SupabaseConfig.client.database.rpc("delete_user").execute()
                //print("Backend deletion executed.")
            } catch {
                //print("Backend deletion finished (expected auth error): \(error.localizedDescription)")
            }
            
            
            do {
                
                try await SupabaseConfig.client.auth.signOut(scope: .local)
                //print("Graceful local sign out succeeded.")
            } catch {
                
                //print("Graceful sign out failed. Applying manual purge...")
                self.forceClearLocalSession()
            }
            
            
            self.navigateToLoginScreen()
        }
    }
    
    private func handleYouTubeTap() {
            guard let profile = profile else { return }
            
            if profile.isYouTubeConnected {
                let alert = UIAlertController(
                    title: "Disconnect YouTube",
                    message: "Are you sure you want to disconnect your YouTube account? You will stop receiving analytics.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { [weak self] _ in
                    self?.performYouTubeDisconnect()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true)
                
            } else {
                Task { @MainActor in
                    do {
                        
                        self.youtubeStatusLabel.text = "Connecting..."
                        self.youtubeStatusDot.backgroundColor = .systemYellow
                        
                        let signInModel = SignInModel()
                        try await signInModel.connectYouTube()
                        
                        self.fetchProfile()
                    } catch {
                        //print("Failed to connect YouTube: \(error)")
                        self.fetchProfile()
                    }
                }
            }
        }
        
        private func performYouTubeDisconnect() {
            Task { @MainActor in
                do {
                    
                    self.youtubeStatusLabel.text = "Disconnecting..."
                    self.youtubeStatusDot.backgroundColor = .systemYellow
                    
                    try await YouTubeController.shared.disconnectYouTubeBackend()
                    
                    let signInModel = SignInModel()
                    signInModel.disconnectYouTube()
                    
                    self.fetchProfile()
                    
                } catch {
                    print("Failed to disconnect YouTube backend: \(error)")
                    self.fetchProfile()
                }
            }
        }
    
    func prepareAndNavigateToPreferences() {
        Task { @MainActor in
            do {
                let preferencesController = PreferencesController()
                let preferences = try await preferencesController.fetchPreferences()
                
                navigateToPreferences(with: preferences)
            } catch {
                // If no preferences found or error, just navigate with nil
                navigateToPreferences(with: nil)
            }
        }
    }
    
    private func navigateToPreferences(with preferences: UserPreference?) {
        let storyboard = UIStoryboard(name: "Preferences", bundle: nil)
        if let preferencesVC = storyboard.instantiateViewController(withIdentifier: "PreferenceVC") as? PreferencesViewController {
            preferencesVC.initialPreference = preferences
            navigationController?.pushViewController(preferencesVC, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            handleYouTubeTap()
        }else if indexPath.section == 2 && indexPath.row == 0 {
            // Settings
        }else if indexPath.section == 2 && indexPath.row == 1 {
            prepareAndNavigateToPreferences()
        }else if indexPath.section == 3 && indexPath.row == 0 {
            signOutTap()
        }else if indexPath.section == 3 && indexPath.row == 1 {
            deleteAccountTap()
        }
    }
    
}


extension ProfileTableViewController: EditProfileDelegate {
    func profileDidUpdate() {
        fetchProfile()
    }
    
    
}
