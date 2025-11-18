//
//  YoutubeAnalysis.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit

class YoutubeAnalysis: UIViewController {

    var someProperty: String?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            print("Received: \(someProperty ?? "nil")")
        }

}
