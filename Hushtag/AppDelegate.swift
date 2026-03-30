import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let iosClientId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String {
            
            let config = GIDConfiguration(
                clientID: iosClientId, // Automatically pulls from your Info.plist
                
                // 👇 THIS IS THE MISSING PUZZLE PIECE 👇
                serverClientID: "55478698081-2s20u2tclej3t956shpvbbfn48e6hkeb.apps.googleusercontent.com"
            )
            
            GIDSignIn.sharedInstance.configuration = config
        }
        
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == "com.learningxcode.Hushtag.youtube.background.upload" {
            YouTubeUploadManager.shared.backgroundCompletionHandler = completionHandler
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
