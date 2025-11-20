//
//  YoutubeAnalysis.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit

class YoutubeAnalysis: UIViewController {

    @IBOutlet weak var AnalysisCollectionView: UICollectionView!
    let values = ["6%", "3%", "24K"]
    let categories = ["Views", "Likes", "Subscribers"]
    
    var someProperty: String?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            AnalysisCollectionView.delegate = self
            AnalysisCollectionView.dataSource = self
        }

}

extension YoutubeAnalysis: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AnalysisCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AnalysisCollectionViewCell
        
        cell.ValueLabel.text = values[indexPath.row]
        cell.CategoryLabel.text = categories[indexPath.row]
        return cell
    }
    
    
}
