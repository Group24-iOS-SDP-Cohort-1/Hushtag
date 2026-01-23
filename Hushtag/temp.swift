//
//  temp.swift
//  Hushtag
//
//  Created by SDC-USER on 22/01/26.
//

import UIKit
import Supabase

class temp: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
        }

        @IBAction func testConnection(_ sender: UIButton) {
            _Concurrency.Task {
                await pingSupabase()
            }
        }

        func pingSupabase() async {
            do {

                           try await SupabaseConfig.client.database
                               .from("test_ping")
                               .insert(["message": "CONNECTED FROM IOS ✅"])
                               .execute()

                           print("✅ CONNECTED TO SUPABASE")
                       } catch {
                           print("❌ NOT CONNECTED:", error)
                       }
        }

}
