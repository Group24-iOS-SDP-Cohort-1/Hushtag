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
        
        setupCardDesign()
        registerCells()
        
        innerCollectionView.dataSource = self
        
        innerCollectionView.delegate = self
        
        innerCollectionView.allowsMultipleSelection = true
        
        innerCollectionView.backgroundColor = .clear
        
        innerCollectionView.alwaysBounceVertical = false
        innerCollectionView.bounces = false
    }
    
    private func notifyCompletionIfNeeded() {
            let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
            let completed = selectedCount > 0
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
        }
    
    
    func setupCardDesign() {
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
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let s = sections[section]
        let baseCount = s.options.count
        
        return baseCount
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let s = sections[indexPath.section]
        
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
    
    section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0.125,
            bottom: 20,
            trailing: 0.125
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
