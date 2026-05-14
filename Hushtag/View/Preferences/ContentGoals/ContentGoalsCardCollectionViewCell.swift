//import UIKit
//
//class ContentGoalsCardCollectionViewCell: UICollectionViewCell {
//    
//    weak var delegate: PreferenceCardSelectionDelegate?
//    var cardIndex: Int = -1
//    
//    @IBOutlet weak var headingLabel: UILabel!
//    
//    @IBOutlet weak var subheadingLabel: UILabel!
//    
//    @IBOutlet weak var innerCollectionView: UICollectionView!
//    
//    var sections: [PreferenceSection] = []
//    
////    let goalMapping: [String: ContentGoal] = [
////        "Grow Audience": .growth,
////        "Boost Engagement": .engagement,
////        "Post More Consistently": .consistency,
////        "Experiment with Trends": .creativity,
////        "Strengthen My Brand": .branding
////    ]
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        innerCollectionView.dataSource = self
//        
//        innerCollectionView.delegate = self
//        
//        registerCells()
//        
//        applyLiquidGlassEffect()
//        
//        innerCollectionView.allowsMultipleSelection = true
//        
//        innerCollectionView.backgroundColor = .clear
//        
//        innerCollectionView.alwaysBounceVertical = false
//        innerCollectionView.bounces = false
//    }
//    
//    
//    func configureCell(with item: PreferenceItem){
//        let isFirstLoad = sections.isEmpty
//        
//        headingLabel.text = item.title
//        subheadingLabel.text = item.subheading
//        
//        sections = item.sections
//        
//        if isFirstLoad {
//            innerCollectionView.collectionViewLayout = generateGoalsInnerLayout()
//            innerCollectionView.reloadData()
//        }
//    }
//    
//    func preselectOptions(selected: [String]) {
//        innerCollectionView.layoutIfNeeded()
//        
//        for indexPath in innerCollectionView.indexPathsForSelectedItems ?? [] {
//            innerCollectionView.deselectItem(at: indexPath, animated: false)
//        }
//        
////        for (sectionIndex, section) in sections.enumerated() {
////            for (itemIndex, optionTitle) in section.options.enumerated() {
////                if let rawValue = goalMapping[optionTitle]?.rawValue,
////                   selected.contains(rawValue.lowercased()) {
////                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
////                    innerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
////                }
////            }
////        }
//    }
//    
//    
//    private func notifyCompletionIfNeeded() {
//        let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
//        delegate?.preferenceCard(at: cardIndex, didChangeCompletion: selectedCount > 0)
//    }
//    
//    private func updateSelection() {
//        
//        let selectedTitles = innerCollectionView.indexPathsForSelectedItems?
//            .sorted { $0.item < $1.item }
//            .map { sections[$0.section].options[$0.item] } ?? []
//        
////        let selectedRawValues: [String] = selectedTitles.compactMap { title in
////            goalMapping[title]?.rawValue
////        }
//        
////        delegate?.preferenceCard(
////            at: "Content Goals",
////            didUpdateSelection: selectedRawValues
////        )
//    }
//    
//    
//    func registerCells(){
//        innerCollectionView.register(UINib(nibName: "ContentGoalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contentGoalsCell")
//    }
//    
//}
//
//
//extension ContentGoalsCardCollectionViewCell: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return sections.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let s = sections[section]
//        let baseCount = s.options.count
//        
//        return baseCount
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let s = sections[indexPath.section]
//        
//        let optionText: String = s.options[indexPath.item]
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentGoalsCell", for: indexPath) as! ContentGoalsCollectionViewCell
//        cell.configureCell(with: optionText)
//        
//        // Force the visual update for pre-selected cells
//        if let selectedPaths = collectionView.indexPathsForSelectedItems, selectedPaths.contains(indexPath) {
//            cell.isSelected = true
//        } else {
//            cell.isSelected = false
//        }
//        
//        return cell
//    }
//    
//    
//}
//
//
//func generateGoalsInnerLayout() -> UICollectionViewLayout{
//    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
//    
//    let item = NSCollectionLayoutItem(layoutSize: itemSize)
//    
//    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
//    
//    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//    
//    let section = NSCollectionLayoutSection(group: group)
//    
//    let layout = UICollectionViewCompositionalLayout(section: section)
//    
//    return layout
//}
//
//
//
//extension ContentGoalsCardCollectionViewCell: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        updateSelection()
//        notifyCompletionIfNeeded()
//    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        updateSelection()
//        notifyCompletionIfNeeded()
//    }
//}
