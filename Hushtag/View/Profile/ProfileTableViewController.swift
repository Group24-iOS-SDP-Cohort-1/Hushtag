import Supabase
import UIKit

final class ProfileTableViewController: UITableViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    @IBOutlet var youtubeStatusLabel: UILabel!
    @IBOutlet var youtubeStatusDot: UIView!

    private var profile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        if let cachedProfile = SessionManager.shared.currentProfile {
            profile = cachedProfile
            Task {
                let appUser = try? await AuthManager.shared.getCurrentSession()
                await MainActor.run {
                    updateUI(with: cachedProfile, image: SessionManager.shared.profileImageCache, appUser: appUser)
                }
            }
        } else {
            showInstantProfile()
        }

        fetchProfile()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdate),
            name: .didUpdateProfile,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdate),
            name: .didUpdateProfile,
            object: nil
        )
    }

    private func showInstantProfile() {
        Task { @MainActor in
            do {
                let appUser = try await AuthManager.shared.getCurrentSession()
                let email = appUser.email ?? ""
                let name = appUser.fullName ?? "Add your name"

                nameLabel.text = name
                emailLabel.text = email
                setInitialAvatar(from: appUser.fullName ?? email)
            } catch {
                // user not logged in
            }
        }
    }

    @objc private func handleProfileUpdate() {
        fetchProfile(forceRefresh: false)
    }

    private func fetchProfile(forceRefresh: Bool = false) {
        Task {
            do {
                async let profileTask = SessionManager.shared.getProfileAndAvatar(forceRefresh: forceRefresh)
                async let userTask = AuthManager.shared.getCurrentSession()

                let (profileAndAvatar, appUser) = try await (profileTask, userTask)

                await MainActor.run {
                    self.profile = profileAndAvatar.0
                    self.updateUI(with: profileAndAvatar.0, image: profileAndAvatar.1, appUser: appUser)
                }
            } catch {
                // print("Failed to fetch profile:", error)
            }
        }
    }

    private func updateUI(with profile: Profile, image: UIImage?, appUser: AppUser?) {
        var displayName = appUser?.fullName ?? ""
        if displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            displayName = "Add your name"
        }

        nameLabel.text = displayName
        emailLabel.text = profile.email

        if let image = image {
            profileImageView.image = image
        } else if let urlString = profile.avatarURL, let url = URL(string: urlString) {
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
                SessionManager.shared.profileImageCache = image
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

        if let container = profileImageView.superview {
            let editBadge = UIImageView(image: UIImage(systemName: "pencil.circle.fill"))
            editBadge.tintColor = .systemBlue
            editBadge.backgroundColor = .white
            editBadge.layer.cornerRadius = 15
            editBadge.clipsToBounds = true
            editBadge.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(editBadge)
            NSLayoutConstraint.activate([
                editBadge.widthAnchor.constraint(equalToConstant: 30),
                editBadge.heightAnchor.constraint(equalToConstant: 30),
                editBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
                editBadge.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5)
            ])
        }

        profileImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)

        nameLabel.isUserInteractionEnabled = true
        let nameDoubleTap = UITapGestureRecognizer(target: self, action: #selector(nameLabelDoubleTapped))
        nameDoubleTap.numberOfTapsRequired = 2
        nameLabel.addGestureRecognizer(nameDoubleTap)

        title = "Profile"
        youtubeStatusDot.layer.cornerRadius = youtubeStatusDot.frame.width / 2
        youtubeStatusDot.clipsToBounds = true
    }

    func signOutTap() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            self?.performSignOut()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    func performSignOut() {
        _Concurrency.Task { @MainActor in
            do {
                try await AuthManager.shared.signOut()
                // print("User signed out successfully")

                SessionManager.shared.clearSession()
                self.navigateToLoginScreen()

            } catch {
                // print("Error signing out: \(error)")
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

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.performAccountDeletion()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    private func forceClearLocalSession() {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            // print("Keychain wiped successfully.")
        } else {
            // print("Keychain wipe returned status: \(status)")
        }

        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            if key.lowercased().contains("supabase") || key.lowercased().contains("gotrue") {
                defaults.removeObject(forKey: key)
            }
        }

        // print("Nuclear option executed: Local session data destroyed.")
    }

    func performAccountDeletion() {
        Task { @MainActor in
            do {
                try await SupabaseConfig.client.database.rpc("delete_user").execute()
                // print("Backend deletion executed.")
            } catch {
                // print("Backend deletion finished (expected auth error): \(error.localizedDescription)")
            }

            do {
                try await SupabaseConfig.client.auth.signOut(scope: .local)
                // print("Graceful local sign out succeeded.")
            } catch {
                // print("Graceful sign out failed. Applying manual purge...")
                self.forceClearLocalSession()
            }

            SessionManager.shared.clearSession()
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
                    // print("Failed to connect YouTube: \(error)")
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
        if let preferencesVC = storyboard
            .instantiateViewController(withIdentifier: "PreferenceVC") as? PreferencesViewController {
            preferencesVC.initialPreference = preferences
            navigationController?.pushViewController(preferencesVC, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1, indexPath.row == 0 {
            handleYouTubeTap()
        } else if indexPath.section == 2, indexPath.row == 0 {
            // Settings
        } else if indexPath.section == 2, indexPath.row == 1 {
            prepareAndNavigateToPreferences()
        } else if indexPath.section == 3, indexPath.row == 0 {
            signOutTap()
        } else if indexPath.section == 3, indexPath.row == 1 {
            deleteAccountTap()
        }
    }
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            uploadImage(image)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func uploadImage(_ selectedImage: UIImage) {
        Task {
            do {
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else { return }

                let session = try await SupabaseConfig.client.auth.session
                let userId = session.user.id.uuidString.lowercased()

                let fileName = "\(userId).jpg"
                let path = "\(fileName)"

                try await SupabaseConfig.client.storage
                    .from("user-avatars")
                    .upload(
                        path: path,
                        file: imageData,
                        options: .init(upsert: true)
                    )

                let publicURL = try SupabaseConfig.client.storage
                    .from("user-avatars")
                    .getPublicURL(path: path)

                let avatarURLToSave = publicURL.absoluteString

                let profileController = ProfileController()
                _ = try await profileController.updateProfile(
                    fullName: self.profile?.fullName ?? "",
                    avatarURL: avatarURLToSave
                )

                self.fetchProfile(forceRefresh: true)
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: "Failed to upload profile picture.")
                }
            }
        }
    }

    @objc private func nameLabelDoubleTapped() {
        let alert = UIAlertController(title: "Edit Name", message: "Enter your full name", preferredStyle: .alert)

        alert.addTextField { textField in
            let currentName = self.nameLabel.text
            if currentName != "Add your name" {
                textField.text = currentName
            }
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alert.textFields?.first?.text,
                  !newName.trimmingCharacters(in: .whitespaces).isEmpty
            else {
                return
            }

            self.updateName(newName)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)

        present(alert, animated: true)
    }

    private func updateName(_ newName: String) {
        Task {
            do {
                try await AuthManager.shared.updateFullName(newName: newName)

                await MainActor.run {
                    self.nameLabel.text = newName
                }

                let profileController = ProfileController()
                _ = try await profileController.updateProfile(
                    fullName: newName,
                    avatarURL: self.profile?.avatarURL
                )

                self.fetchProfile(forceRefresh: true)
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: "Failed to update name.")
                }
            }
        }
    }
}
