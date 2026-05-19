import Foundation
import Supabase

enum SupabaseConfig {

    static let url: URL = {
        guard let url = URL(string: "https://juuuwuydlgjhgwwabswy.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        return url
    }()

    static let anonKey: String = {
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1dXV3dXlkbGdqaGd3d2Fic3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMTEwMzAsImV4cCI6MjA4NDU4NzAzMH0.qTJ2zoIj3uBR5tSOp8-J-dU0ZPJIE_XKkw23zP4-sRg"
    }()

    static let client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }()
}
