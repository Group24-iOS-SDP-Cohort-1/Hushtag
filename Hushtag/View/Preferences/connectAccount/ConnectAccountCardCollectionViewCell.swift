//
//  ConnectAccountCardCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class ConnectAccountCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet weak var innerCollectionView: UICollectionView!
    
    var sections: [PreferenceSection] = []
    
    var preferenceID: Int = 0
    
    weak var delegate: PreferenceCardSelectionDelegate?
    var cardIndex: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupCardDesign()
        registerCells()
        
        innerCollectionView.dataSource = self
        
        //NEW
        innerCollectionView.delegate = self
        
        innerCollectionView.allowsMultipleSelection = true
        
        innerCollectionView.backgroundColor = .clear
        
        innerCollectionView.alwaysBounceVertical = false
        innerCollectionView.bounces = false
    }
    
    //NEW
    private func notifyCompletionIfNeeded() {
            // sum selected items across sections
            let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
            let completed = selectedCount > 0
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
        }
    
    
    func setupCardDesign() {
            // Corner Radius
//            self.layer.cornerRadius = 15
//            self.layer.cornerCurve = .continuous // iOS Modern "smooth" corners
//            
//            // Background Color (Ensure it's white, or the shadow won't look right)
//            self.backgroundColor = .white
//            
//            // Drop Shadow
//            self.layer.shadowColor = UIColor.black.cgColor
//            self.layer.shadowOpacity = 0.15  // 0.0 to 1.0 (0.15 is subtle and nice)
//            self.layer.shadowOffset = CGSize(width: 0, height: 0) // Vertical shift
//            self.layer.shadowRadius = 6 // How blurry the shadow is
//            
//            // CRITICAL: This must be false for shadows to appear outside the bounds
//            self.layer.masksToBounds = false
        
        contentView.applyLiquidGlassEffect()
    }
    
    
    func configureCell(with item: PreferenceItem){
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        preferenceID = item.id
        sections = item.sections
        
        innerCollectionView.collectionViewLayout = generateAccountLayout()
        
    }
    
    
    func registerCells(){
        innerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
    }

}


extension ConnectAccountCardCollectionViewCell: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if sections exist, use them; otherwise single section driven by `options`
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return options.count
        let s = sections[section]
        let baseCount = s.options.count
        
        return baseCount
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let s = sections[indexPath.section]
        //let optionCount = s.options.count
        
        let optionText: String = s.options[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionsCell", for: indexPath) as! OptionsCollectionViewCell
        cell.configureCell(with: optionText)
        return cell
    }
    
}


func generateAccountLayout() -> UICollectionViewLayout{
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45))
    
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 3)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .estimated(200))
    
    let subitems = Array(repeating: item, count: 3)
    
    
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: subitems)
    
    group.interItemSpacing = .fixed(12)

    let section = NSCollectionLayoutSection(group: group)
    
    //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    
    section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0.125,   // 12.5% of width
            bottom: 20,
            trailing: 0.125  // 12.5% of width
        )
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
}


extension ConnectAccountCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        notifyCompletionIfNeeded()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        notifyCompletionIfNeeded()
    }
}
