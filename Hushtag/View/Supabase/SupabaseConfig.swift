import Foundation
import Supabase

enum SupabaseConfig {
    static let url: URL = {
        guard let url = URL(string: Keys.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        return url
    }()

    static let anonKey: String = Keys.anonKey

    static let client: SupabaseClient = .init(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}
