import GoogleSignIn
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        // force dark mode
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.overrideUserInterfaceStyle = .dark

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("❌ Google restore failed:", error)
            } else if user != nil {
                print("✅ Google user restored")
            }
        }

        _Concurrency.Task {
            do {
                _ = try await AuthManager.shared.getCurrentSession()

                await SessionManager.shared.restoreSession()

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                let endDate = formatter.string(from: Date())

                let startDate = formatter.string(
                    from: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                )

                await YouTubeController.shared.restoreYouTubeConnectionIfNeeded(
                    startDate: startDate,
                    endDate: endDate
                )

                let isComplete = await AuthManager.shared.hasCompletedOnboarding()

                DispatchQueue.main.async {
                    if isComplete {
                        self.navigateToHomeScreen()
                    } else {
                        self.navigateToPreferencesScreen()
                    }
                }

            } catch {
                print("No active session, staying on Login screen.")
                // Route to the login screen if the Supabase auth check fails
                DispatchQueue.main.async {
                    self.navigateToLoginScreen()
                }
            }
        }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }

        // "Hey Google SDK, this URL is for you. Did you handle it?"
        let handled = GIDSignIn.sharedInstance.handle(url)

        if handled {
            return
        }

        // If Google didn't want it, you can check other URLs here later
    }

    func navigateToHomeScreen() {
        // Ensure we are working with the Main Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Make sure this ID matches your TabBarController in Storyboard!
        guard let homeVC =
            storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                as? UITabBarController
        else {
            print("Error: Could not find MainTabBarController in Storyboard")
            return
        }

        // Swap the root controller
        // We use 'window' directly because we are inside SceneDelegate
        if let window = window {
            window.rootViewController = homeVC
            window.makeKeyAndVisible()

            // Optional: Add a smooth cross-dissolve animation
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    func navigateToLoginScreen() {
        // 1. Safely unwrap the window directly owned by SceneDelegate
        guard let window = window else { return }

        // 2. Load the Login/Signup Storyboard
        let storyboard = UIStoryboard(name: "login_signup", bundle: nil)

        // 3. Instantiate the Navigation Controller
        guard let loginNav =
            storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
                as? UINavigationController
        else {
            print("Error: Could not find LoginNavigationController in Storyboard")
            return
        }

        // 4. Swap the root view controller
        window.rootViewController = loginNav

        // 5. Add a smooth cross-dissolve animation
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)

        // 6. Make it visible
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func navigateToPreferencesScreen() {
        guard let window = window else { return }

        // 1. Load the Preferences Storyboard
        let storyboard = UIStoryboard(name: "Preferences", bundle: nil)

        // 2. Get the Initial View Controller
        guard let preferencesVC =
            storyboard.instantiateInitialViewController()
        else {
            print("Error: Could not find Initial View Controller in Preferences.storyboard")
            return
        }

        // 3. Swap the root view controller
        window.rootViewController = preferencesVC
        window.makeKeyAndVisible()

        // 4. Animation
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
