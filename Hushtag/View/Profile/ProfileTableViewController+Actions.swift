import UIKit
import Supabase

extension ProfileTableViewController {
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
                SessionManager.shared.clearSession()
                self.navigateToLoginScreen()
            } catch {
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
            // Keychain wiped successfully.
        }

        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            if key.lowercased().contains("supabase") || key.lowercased().contains("gotrue") {
                defaults.removeObject(forKey: key)
            }
        }
    }

    func performAccountDeletion() {
        Task { @MainActor in
            do {
                try await SupabaseConfig.client.database.rpc("delete_user").execute()
            } catch {}

            do {
                try await SupabaseConfig.client.auth.signOut(scope: .local)
            } catch {
                self.forceClearLocalSession()
            }

            SessionManager.shared.clearSession()
            self.navigateToLoginScreen()
        }
    }

    func handleYouTubeTap() {
        guard let profile = self.value(forKey: "profile") as? Profile else { return }

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

                    let confirmedState = await YouTubeController.shared.verifyYouTubeConnectionState(
                        expectedState: true
                    )
                    SessionManager.shared.currentProfile?.isYouTubeConnected = confirmedState

                    self.perform(NSSelectorFromString("fetchProfileWithForceRefresh:"), with: true)
                } catch {
                    self.perform(NSSelectorFromString("fetchProfileWithForceRefresh:"), with: true)
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

                let confirmedState = await YouTubeController.shared.verifyYouTubeConnectionState(
                    expectedState: false
                )
                SessionManager.shared.currentProfile?.isYouTubeConnected = confirmedState

                self.perform(NSSelectorFromString("fetchProfileWithForceRefresh:"), with: true)
            } catch {
                self.perform(NSSelectorFromString("fetchProfileWithForceRefresh:"), with: true)
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
