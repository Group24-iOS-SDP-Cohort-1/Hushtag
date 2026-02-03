import Foundation

// We don't need 'import Supabase' here because we are doing it manually.
// This ensures no hidden SDK logic interferes.

struct GeminiResponse: Decodable, Sendable {
    let response: String
}

class GeminiManager {
    static let shared = GeminiManager()
    
    // ⚠️ COPY THESE EXACTLY FROM YOUR WORKING CURL COMMAND ⚠️
    // URL format: https://<project_ref>.supabase.co/functions/v1/<function_name>
    private let functionURL = "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/chat-with-gemini"
    
    // Use the exact same key you used in the successful curl command
    private let anonKey = SupabaseConfig.anonKey

    private init() {}

    func generateContent(prompt: String, completion: @escaping (String?) -> Void) {
        
        guard let url = URL(string: functionURL) else {
            print("❌ Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 1. HEADER: Content-Type
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. HEADER: Authorization
        // We manually add "Bearer" + Key, just like the curl command
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        // 3. BODY: JSON Payload
        let body = ["prompt": prompt]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON Error: \(error)")
            completion(nil)
            return
        }
        
        print("🚀 Sending request to \(functionURL)...")
        
        // 4. SEND REQUEST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Check for Network Error
            if let error = error {
                print("❌ Network Error: \(error)")
                DispatchQueue.main.async { completion("Error: \(error.localizedDescription)") }
                return
            }
            
            // Check for HTTP Error
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    // Try to print server error message
                    if let data = data, let errorText = String(data: data, encoding: .utf8) {
                        print("❌ Server Error Body: \(errorText)")
                    }
                    DispatchQueue.main.async { completion("Error: Server returned \(httpResponse.statusCode)") }
                    return
                }
            }
            
            // Success: Parse Data
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(GeminiResponse.self, from: data)
                print("✅ Gemini Response: \(result.response)")
                DispatchQueue.main.async {
                    completion(result.response)
                }
            } catch {
                print("❌ JSON Parse Error: \(error)")
                // Print the raw string to see what actually came back
                let rawString = String(data: data, encoding: .utf8)
                print("Raw Response was: \(rawString ?? "nil")")
                
                DispatchQueue.main.async { completion("Error: Invalid Data Format") }
            }
        }
        task.resume()
    }
}
