//
//  ContentGoalsCardCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class ContentGoalsCardCollectionViewCell: UICollectionViewCell {

    //NEW
    weak var delegate: PreferenceCardSelectionDelegate?
    var cardIndex: Int = -1
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet weak var innerCollectionView: UICollectionView!
    
    var sections: [PreferenceSection] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        innerCollectionView.dataSource = self
        
        //NEW
        innerCollectionView.delegate = self
        
        registerCells()
        
        setupCardDesign()
        
        innerCollectionView.allowsMultipleSelection = true
        
        innerCollectionView.backgroundColor = .clear
        
        innerCollectionView.alwaysBounceVertical = false
        innerCollectionView.bounces = false
    }
    
    
    func configureCell(with item: PreferenceItem){
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        
        sections = item.sections
        
        innerCollectionView.collectionViewLayout = generateGoalsInnerLayout()
    }
    
    
    //NEW
    private func notifyCompletionIfNeeded() {
            let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: selectedCount > 0)
        }
    
    private func updateSelection() {
        let selected = innerCollectionView.indexPathsForSelectedItems?
            .sorted { $0.item < $1.item }
            .map { sections[$0.section].options[$0.item] } ?? []

        delegate?.preferenceCard(at: "Content Goals", didUpdateSelection: selected)
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
    
    func registerCells(){
        innerCollectionView.register(UINib(nibName: "ContentGoalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contentGoalsCell")
    }

}


extension ContentGoalsCardCollectionViewCell: UICollectionViewDataSource {
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
        
        let optionText: String = s.options[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentGoalsCell", for: indexPath) as! ContentGoalsCollectionViewCell
        cell.configureCell(with: optionText)
        return cell
    }
    
    
}


func generateGoalsInnerLayout() -> UICollectionViewLayout{
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
    
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
}



//NEW
extension ContentGoalsCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelection()
        notifyCompletionIfNeeded()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateSelection()
        notifyCompletionIfNeeded()
    }
}
