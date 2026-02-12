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

//    func generateContent(prompt: String, completion: @escaping (String?) -> Void) {
//        
//        guard let url = URL(string: functionURL) else {
//            print("❌ Error: Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // 1. HEADER: Content-Type
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // 2. HEADER: Authorization
//        // We manually add "Bearer" + Key, just like the curl command
//        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
//        
//        // 3. BODY: JSON Payload
//        let body = ["prompt": prompt]
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            print("❌ JSON Error: \(error)")
//            completion(nil)
//            return
//        }
//        
//        
//        print("🚀 Sending request to \(functionURL)...")
//        
//        // 4. SEND REQUEST
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            
//            // Check for Network Error
//            if let error = error {
//                print("❌ Network Error: \(error)")
//                DispatchQueue.main.async { completion("Error: \(error.localizedDescription)") }
//                return
//            }
//            
//            // Check for HTTP Error
//            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 Status Code: \(httpResponse.statusCode)")
//                
//                if httpResponse.statusCode != 200 {
//                    // Try to print server error message
//                    if let data = data, let errorText = String(data: data, encoding: .utf8) {
//                        print("❌ Server Error Body: \(errorText)")
//                    }
//                    DispatchQueue.main.async { completion("Error: Server returned \(httpResponse.statusCode)") }
//                    return
//                }
//            }
//            
//            // Success: Parse Data
//            guard let data = data else { return }
//            
//            do {
//                let result = try JSONDecoder().decode(GeminiResponse.self, from: data)
//                print("✅ Gemini Response: \(result.response)")
//                DispatchQueue.main.async {
//                    completion(result.response)
//                }
//            } catch {
//                print("❌ JSON Parse Error: \(error)")
//                // Print the raw string to see what actually came back
//                let rawString = String(data: data, encoding: .utf8)
//                print("Raw Response was: \(rawString ?? "nil")")
//                
//                DispatchQueue.main.async { completion("Error: Invalid Data Format") }
//            }
//        }
//        task.resume()
//    }
    
//    func generateContent(prompt: String, completion: @escaping (String?) -> Void) {
//            
//            // 1. Simulate a short network delay (makes it feel real)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                
//                let lowerPrompt = prompt.lowercased()
//                var mockResponse = ""
//                
//                // 2. Determine response based on input
//                if lowerPrompt.contains("generate title") {
//                    mockResponse = "Indian Sweet dish made with love "
//                }
//                else if lowerPrompt.contains("generate description") {
//                    mockResponse = """
//                    Milk simmering slowly, cardamom in the air, and sweets made with patience and love. Indian mithai isn’t just dessert—it’s emotion, culture, and celebration in every bite. 🤍✨
//                        #IndianSweets #MithaiLove #DesiFood #SweetTradition #IndianDesserts #FoodReels #InstaFood #HomeCooking #ReelItFeelIt
//                    """
//                }
//                else if lowerPrompt.contains("generate thumbnail") {
//                    mockResponse = "https://via.placeholder.com/300?text=Mock+Thumbnail" // Returns a dummy image URL
//                }
//                else {
//                    // Default assumes it's a script request
//                    mockResponse = """
//                    Okay, here's a 30-second gym reel script designed for quick cuts, high energy, and motivational impact.
//
//                    ---
//
//                    **GYM REEL SCRIPT: "EARN IT"**
//
//                    **Goal:** Inspire viewers to hit the gym, showcase dedication, and project a strong, positive vibe.
//                    **Music:** Upbeat, driving instrumental track (e.g., electronic, rock, or hip-hop beat) – license-free or popular trending audio.
//
//                    **(0-2 seconds)**
//                    *   **VISUAL:** Quick, high-energy shot. Close-up of shoes hitting the gym floor, or a hand gripping a barbell.
//                    *   **TEXT OVERLAY:** **"IT STARTS NOW."** (Bold, impactful font)
//                    *   **SOUND:** Music drops in strong.
//
//                    **(2-5 seconds)**
//                    *   **VISUAL:** Rapid montage (1 second each)
//                        *   Walking into the gym, focused expression.
//                        *   Quick dynamic stretch (e.g., arm circles, leg swings).
//                        *   Loading heavy plates onto a barbell.
//                    *   **TEXT OVERLAY:** **"NO EXCUSES."**
//
//                    **(5-15 seconds)**
//                    *   **VISUAL:** Action montage – fast cuts, varying angles. Show effort and form.
//                        *   **5-7s:** Powerful squat or deadlift (1-2 reps, focused on explosion).
//                        *   **7-9s:** Intense bench press or overhead press (1-2 reps).
//                        *   **9-11s:** High-intensity cardio burst (e.g., sprinting on treadmill, rowing machine, battle ropes).
//                        *   **11-13s:** Dumbbell exercise (e.g., bicep curls, shoulder press, or lunges).
//                        *   **13-15s:** Close-up of muscle contraction, sweat dripping, determined facial expression.
//                    *   **TEXT OVERLAYS (flash quickly, interspersed):**
//                        *   **"ONE REP AT A TIME."**
//                        *   **"EARN YOUR RESULTS."**
//                        *   **"DISCIPLINE."**
//                    *   **SOUND:** Music maintains energy. Add subtle SFX: clanking weights, heavy breathing, grunts (if appropriate).
//
//                    **(15-20 seconds)**
//                    *   **VISUAL:** Slightly slower, more deliberate shot of completing a challenging set.
//                        *   Finishing a final rep, a moment of struggle, then a look of triumph and satisfaction.
//                        *   Wiping sweat, a genuine smile, or a fist pump.
//                    *   **TEXT OVERLAY:** **"THE WORK PAYS OFF."** ✨
//
//                    **(20-25 seconds)**
//                    *   **VISUAL:** Cool-down or post-workout shot.
//                        *   Stretching, or walking out of the gym with a confident stride.
//                        *   A quick shot of a water bottle/protein shake.
//                    *   **TEXT OVERLAY:** **"FEEL THE PROGRESS."**
//
//                    **(25-30 seconds)**
//                    *   **VISUAL:** Final impactful shot.
//                        *   Flexing a bicep/tricep, or a confident pose looking into the camera.
//                        *   Optional: A quick shot of the gym's name or your own gym attire brand.
//                    *   **TEXT OVERLAY:**
//                        *   **"WHAT ARE YOU WAITING FOR?"** 💪
//                        *   **[@YourInstagramHandle]** (smaller, at the bottom)
//                        *   **#GymMotivation #Workout #FitnessJourney** (smaller, at the bottom)
//                    *   **SOUND:** Music builds to a climax and fades out sharply.
//
//                    ---
//
//                    **Tips for Filming:**
//
//                    *   **Vary your angles:** Wide shots, close-ups, low angles for power.
//                    *   **Good Lighting:** Utilize natural light if possible, or gym lighting that makes muscles pop.
//                    *   **Smooth Transitions:** Use quick cuts, maybe a few subtle whip pans or jump cuts.
//                    *   **Authenticity:** Show real effort and genuine emotion.
//                    *   **Use a tripod or stabilizer:** For steady, professional-looking shots.
//                    *   **High-Quality Audio:** Even if it's just music, make sure it's clear and at the right volume.
//                    *   **Trending Audio:** Often the key to reach on Reels, so pick something popular that fits the mood.
//                    """
//                }
//                
//                // 3. Return the data
//                completion(mockResponse)
//            }
//        }
    
    
    func generateContent(prompt: String, completion: @escaping (String?) -> Void) {
        print("🚀 Sending request to Gemini (SIMULATION)...")

        // Simulate a 1-second network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("❌ Simulating Gemini Failure (Returning nil)")
            
            // Return nil to trigger the fallback logic in Chatbot.swift
            completion(nil)
        }
    }
}
