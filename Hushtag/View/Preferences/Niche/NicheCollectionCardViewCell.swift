import UIKit

class NicheCollectionCardViewCell: UICollectionViewCell {
    
    
    weak var delegate: PreferenceCardSelectionDelegate?
    var cardIndex: Int = -1
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet weak var innerCollectionView: UICollectionView!
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    var sections: [PreferenceSection] = []
    
    var preferenceID: Int = 0
    
    let otherOptionKey = "Other"
    
    
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
        
        setupTextField()
    }
    
    func setupTextField() {
        textFieldOutlet.layer.cornerRadius = 12
        textFieldOutlet.layer.masksToBounds = true
        textFieldOutlet.layer.borderWidth = 1
        textFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
        
        
        textFieldOutlet.isEnabled = false
        textFieldOutlet.alpha = 0.5
        textFieldOutlet.placeholder = "Enter your niche"
        
        
        textFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSelection()
    }
    
    
    
    private func notifyCompletionIfNeeded() {
        
        let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
        let completed = selectedCount > 0
        delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
    }
    
    private func updateSelection() {
        guard let selectedIndexPaths = innerCollectionView.indexPathsForSelectedItems else { return }
        
        
        let sortedPaths = selectedIndexPaths.sorted { $0.item < $1.item }
        
        var selectedValues: [String] = []
        
        for indexPath in sortedPaths {
            let optionText = sections[indexPath.section].options[indexPath.item]
            
            if optionText == otherOptionKey {
                
                let rawText = textFieldOutlet.text ?? ""
                
                
                let customItems = rawText.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                if !customItems.isEmpty {
                    
                    selectedValues.append(contentsOf: customItems)
                } else {
                    
                    selectedValues.append(otherOptionKey)
                }
            } else {
                
                selectedValues.append(optionText)
            }
        }
        
        delegate?.preferenceCard(at: "Niche", didUpdateSelection: selectedValues)
    }
    
    
    func setupCardDesign() {
        contentView.applyLiquidGlassEffect()
    }
    
    
    
    func configureCell(with item: PreferenceItem){
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        preferenceID = item.id
        sections = item.sections
        
        innerCollectionView.collectionViewLayout = generateNicheLayout()
        innerCollectionView.reloadData()
        
        textFieldOutlet.text = ""
        textFieldOutlet.isEnabled = false
        textFieldOutlet.alpha = 0.5
        
    }
    
    func preselectOptions(selected: [String]) {
        // Clear existing selections just in case
        for indexPath in innerCollectionView.indexPathsForSelectedItems ?? [] {
            innerCollectionView.deselectItem(at: indexPath, animated: false)
        }
        
        var otherItems: [String] = []
        
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, option) in section.options.enumerated() {
                // If it's the "Other" option in the UI, we handle it below if there are unmatched strings
                if option != otherOptionKey && selected.contains(option.lowercased()) {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    innerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
        
        // Find items that don't match standard options
        let allOptionsLowercased = sections.flatMap { $0.options }.map { $0.lowercased() }
        otherItems = selected.filter { !allOptionsLowercased.contains($0) }
        
        if !otherItems.isEmpty {
            // Find "Other" index to select it
            if let sectionIndex = sections.firstIndex(where: { $0.options.contains(otherOptionKey) }),
               let itemIndex = sections[sectionIndex].options.firstIndex(of: otherOptionKey) {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                innerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                
                toggleTextField(active: true)
                textFieldOutlet.text = otherItems.joined(separator: ", ")
            }
        }
    }
    
    
    func registerCells(){
        innerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
    }
    
}

extension NicheCollectionCardViewCell: UICollectionViewDataSource{
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
        
        // Force the visual update for pre-selected cells
        if let selectedPaths = collectionView.indexPathsForSelectedItems, selectedPaths.contains(indexPath) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
        return cell
    }
    
    
    func toggleTextField(active: Bool) {
        textFieldOutlet.isEnabled = active
        
        UIView.animate(withDuration: 0.3) {
            self.textFieldOutlet.alpha = active ? 1.0 : 0.5
        }
        
        if active {
            textFieldOutlet.becomeFirstResponder()
        } else {
            textFieldOutlet.resignFirstResponder()
            textFieldOutlet.text = ""
        }
    }
    
}


func generateNicheLayout() -> UICollectionViewLayout{
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(45))
    
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 10, leading: 3, bottom: 0, trailing: 3)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
    
    let subitems = Array(repeating: item, count: 3)
    
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
}



extension NicheCollectionCardViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = sections[indexPath.section].options[indexPath.item]
        
        
        if selectedOption == otherOptionKey {
            toggleTextField(active: true)
        }
        
        updateSelection()
        notifyCompletionIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedOption = sections[indexPath.section].options[indexPath.item]
        
        
        if deselectedOption == otherOptionKey {
            toggleTextField(active: false)
        }
        
        updateSelection()
        notifyCompletionIfNeeded()
    }
}
