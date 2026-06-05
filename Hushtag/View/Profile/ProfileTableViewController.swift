import Supabase
import UIKit

final class ProfileTableViewController: UITableViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    @IBOutlet var youtubeStatusLabel: UILabel!
    @IBOutlet var youtubeStatusDot: UIView!

    var profile: Profile?

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

    func fetchProfile(forceRefresh: Bool = false) {
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
            youtubeStatusLabel.text = "Connect"
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
