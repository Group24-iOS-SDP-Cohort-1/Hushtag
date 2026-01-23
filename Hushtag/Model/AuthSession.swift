import Supabase

@MainActor
final class AuthSession {

    static let shared = AuthSession()

    private let client = SupabaseConfig.client
    private(set) var user: User?

    private init() {} 

    func refresh() async {
        do {
            let session = try await client.auth.session
            user = session.user
        } catch {
            user = nil
            print("❌ Failed to fetch session:", error)
        }
    }

    func isLoggedIn() -> Bool {
        user != nil
    }
}
