//
//  ViewIdea.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ViewIdea: UIViewController {
    

    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var hashtagLabel: UILabel!
    
    var ideas: Idea?
    var ideaResponse = IdeaResponse()
    var idea: [Idea] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        idea = ideaResponse.ideas

            // Pick a random idea
                descriptionLabel.text = "hi"
                hashtagLabel.text = "222"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
