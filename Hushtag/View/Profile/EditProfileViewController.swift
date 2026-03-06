//
//  EditProfileViewController.swift
//  Hushtag
//

import UIKit
import Supabase

protocol EditProfileDelegate: AnyObject {
    func profileDidUpdate()
}

final class EditProfileViewController: UIViewController,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var profile: Profile?
    weak var delegate: EditProfileDelegate?
    
    private var selectedImage: UIImage?
    private let profileController = ProfileController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = profile?.fullName
        loadAvatar()
        setupImageTap()
    }
    
    
    private func setupImageTap() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(profileImageTapped)
        )
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        applyProfileImageStyling()
    }
    
    private func loadAvatar() {
        guard let urlString = profile?.avatarURL,
              let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let fullName = nameTextField.text, !fullName.isEmpty else {
            showAlert(title: "Error", message: "Please enter your full name.")
            return
        }
        
        sender.isEnabled = false
        
        Task {
            do {
                var avatarURLToSave = profile?.avatarURL
                
                
                if let selectedImage = selectedImage,
                   let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                    
                    let session = try await SupabaseConfig.client.auth.session
                    let userId = session.user.id.uuidString.lowercased()
                    
                    let fileName = "\(userId).jpg"
                    let path = "\(fileName)"
                    print(path)
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
                    
                    avatarURLToSave = publicURL.absoluteString
                }
                
                
                _ = try await profileController.updateProfile(
                    fullName: fullName,
                    avatarURL: avatarURLToSave
                )
                
                await MainActor.run {
                    self.delegate?.profileDidUpdate()
                    self.dismiss(animated: true)
                }
                
            } catch {
                print("❌ PROFILE UPDATE FAILED:", error)
                await MainActor.run {
                    self.showAlert(
                        title: "Error",
                        message: "Failed to update profile."
                    )
                }
            }
        }
    }
    
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
            selectedImage = image
            profileImageView.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    private func applyProfileImageStyling() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
