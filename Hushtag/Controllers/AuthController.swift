@MainActor
final class AuthController {

    private let service = AuthService()

    func login(email: String, password: String) async -> Bool {
        do {
            try await service.signIn(email: email, password: password)
            await AuthSession.shared.refresh()   
            return true
        } catch {
            return false
        }
    }

    func signup(email: String, password: String) async -> Bool {
        do {
            try await service.signUp(email: email, password: password)
            await AuthSession.shared.refresh()
            return true
        } catch {
            return false
        }
    }

    func logout() async {
        do {
            try await service.signOut()
            await AuthSession.shared.refresh()
        } catch {}
    }
}
