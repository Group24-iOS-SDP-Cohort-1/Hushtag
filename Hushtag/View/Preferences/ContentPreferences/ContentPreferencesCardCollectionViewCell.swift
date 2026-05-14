//import UIKit
//
//class ContentPreferencesCardCollectionViewCell: UICollectionViewCell {
//    
//    
//    weak var delegate: PreferenceCardSelectionDelegate?
//    var cardIndex: Int = -1
//    
//    
//    @IBOutlet weak var headingLabel: UILabel!
//    
//    @IBOutlet weak var subheadingLabel: UILabel!
//    
//    @IBOutlet weak var firstInnerCollectionView: UICollectionView!
//    
//    @IBOutlet weak var textFieldOutlet: UITextField!
//    
//    @IBOutlet weak var secondInnerCollectionView: UICollectionView!
//    
//    var sections: [PreferenceSection] = []
//    
//    
//    var vibeSection: PreferenceSection?
//    
//    var lengthSection: PreferenceSection?
//    
//    let otherOptionKey = "Other"
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        setupCardDesign()
//        
//        firstInnerCollectionView.dataSource = self
//        
//        secondInnerCollectionView.dataSource = self
//        
//        firstInnerCollectionView.delegate = self
//        secondInnerCollectionView.delegate = self
//        
//        registerCells()
//        
//        firstInnerCollectionView.allowsMultipleSelection = true
//        
//        secondInnerCollectionView.allowsMultipleSelection = true
//        
//        firstInnerCollectionView.backgroundColor = .clear
//        secondInnerCollectionView.backgroundColor = .clear
//        
//        firstInnerCollectionView.alwaysBounceVertical = false
//        firstInnerCollectionView.bounces = false
//        
//        secondInnerCollectionView.alwaysBounceVertical = false
//        secondInnerCollectionView.bounces = false
//        
//        setupTextField()
//    }
//    
//    func setupTextField() {
//        textFieldOutlet.layer.cornerRadius = 12
//        textFieldOutlet.layer.masksToBounds = true
//        textFieldOutlet.layer.borderWidth = 1
//        textFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
//        
//        textFieldOutlet.isEnabled = false
//        textFieldOutlet.alpha = 0.5
//        textFieldOutlet.placeholder = "Enter your niche"
//        
//        textFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//    }
//    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        updateSelection()
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
//        vibeSection = sections[0]
//        lengthSection = sections[1]
//        
//        if isFirstLoad {
//            firstInnerCollectionView.collectionViewLayout = generateContentPreferencesLayout()
//            secondInnerCollectionView.collectionViewLayout = generateContentPreferencesLayout()
//            
//            firstInnerCollectionView.reloadData()
//            secondInnerCollectionView.reloadData()
//        }
//        
//        textFieldOutlet.text = ""
//        textFieldOutlet.isEnabled = false
//        textFieldOutlet.alpha = 0.5
//        
//    }
//    
//    func preselectOptions(vibeSelected: [String], lengthSelected: [String]) {
//        firstInnerCollectionView.layoutIfNeeded()
//        secondInnerCollectionView.layoutIfNeeded()
//        
//        for indexPath in firstInnerCollectionView.indexPathsForSelectedItems ?? [] {
//            firstInnerCollectionView.deselectItem(at: indexPath, animated: false)
//        }
//        for indexPath in secondInnerCollectionView.indexPathsForSelectedItems ?? [] {
//            secondInnerCollectionView.deselectItem(at: indexPath, animated: false)
//        }
//        
//        var otherItems: [String] = []
//        
//        if let vibeOptions = vibeSection?.options {
//            for (itemIndex, option) in vibeOptions.enumerated() {
//                if option != otherOptionKey && vibeSelected.contains(option.lowercased()) {
//                    let indexPath = IndexPath(item: itemIndex, section: 0)
//                    firstInnerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//                }
//            }
//            
//            let allVibesLowercased = vibeOptions.map { $0.lowercased() }
//            otherItems = vibeSelected.filter { !allVibesLowercased.contains($0) }
//            
//            if !otherItems.isEmpty {
//                if let itemIndex = vibeOptions.firstIndex(of: otherOptionKey) {
//                    let indexPath = IndexPath(item: itemIndex, section: 0)
//                    firstInnerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//                    
//                    toggleTextField(active: true)
//                    textFieldOutlet.text = otherItems.joined(separator: ", ")
//                }
//            }
//        }
//        
//        if let lengthOptions = lengthSection?.options {
//            for (itemIndex, option) in lengthOptions.enumerated() {
//                if lengthSelected.contains(option.lowercased()) {
//                    let indexPath = IndexPath(item: itemIndex, section: 0)
//                    secondInnerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//                }
//            }
//        }
//    }
//    
//    
//    private func notifyCompletionIfNeeded() {
//        let firstSelected = firstInnerCollectionView.indexPathsForSelectedItems?.count ?? 0
//        let secondSelected = secondInnerCollectionView.indexPathsForSelectedItems?.count ?? 0
//        let completed = (firstSelected + secondSelected) > 0
//        delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
//    }
//    
//    
//    private func updateSelection() {
//        
//        guard let selectedIndexPaths = firstInnerCollectionView.indexPathsForSelectedItems else { return }
//        
//        let sortedPaths = selectedIndexPaths.sorted { $0.item < $1.item }
//        
//        var firstSelections: [String] = []
//        
//        for indexPath in sortedPaths {
//            let optionText = sections[indexPath.section].options[indexPath.item]
//            
//            if optionText == otherOptionKey {
//                let rawText = textFieldOutlet.text ?? ""
//                
//                let customItems = rawText.components(separatedBy: ",")
//                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                    .filter { !$0.isEmpty }
//                
//                if !customItems.isEmpty {
//                    
//                    firstSelections.append(contentsOf: customItems)
//                } else {
//                    
//                    firstSelections.append(otherOptionKey)
//                }
//            } else {
//                firstSelections.append(optionText)
//            }
//        }
//        
//        
//        
//        let secondSelections =
//        secondInnerCollectionView.indexPathsForSelectedItems?
//            .sorted { $0.item < $1.item }
//            .compactMap { lengthSection?.options[$0.item] } ?? []
//        
//        
//        delegate?.preferenceCard(at: "Content Tone", didUpdateSelection: firstSelections)
//        delegate?.preferenceCard(at: "Content Length", didUpdateSelection: secondSelections)
//    }
//    
//    func toggleTextField(active: Bool) {
//        textFieldOutlet.isEnabled = active
//        
//        UIView.animate(withDuration: 0.3) {
//            self.textFieldOutlet.alpha = active ? 1.0 : 0.5
//        }
//        
//        if active {
//            
//            textFieldOutlet.becomeFirstResponder()
//        } else {
//            
//            textFieldOutlet.resignFirstResponder()
//            textFieldOutlet.text = ""
//        }
//    }
//    
//    
//    
//    func setupCardDesign() {
//        
//        contentView.applyLiquidGlassEffect()
//    }
//    
//    func registerCells(){
//        firstInnerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
//        
//        firstInnerCollectionView.register(UINib(nibName: "PreferencesHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
//        
//        secondInnerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
//        
//        secondInnerCollectionView.register(UINib(nibName: "PreferencesHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
//    }
//}
//
//
//extension ContentPreferencesCardCollectionViewCell: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == firstInnerCollectionView{
//            //print("Vibe Selected")
//            return vibeSection?.options.count ?? 0
//        }else if collectionView == secondInnerCollectionView{
//            //print("Length Selected")
//            return lengthSection?.options.count ?? 0
//        }else{
//            return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var optionText: String = ""
//        
//        if collectionView == firstInnerCollectionView {
//            let option = vibeSection?.options[indexPath.item]
//            
//            optionText = option ?? ""
//        }else if collectionView == secondInnerCollectionView {
//            let option = lengthSection?.options[indexPath.item]
//            
//            optionText = option ?? ""
//        }
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionsCell", for: indexPath) as! OptionsCollectionViewCell
//        
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
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard kind == UICollectionView.elementKindSectionHeader else {
//            return UICollectionReusableView()
//        }
//        
//        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_cell", for: indexPath) as! PreferencesHeaderView
//        
//        if collectionView == firstInnerCollectionView {
//            headerView.configureHeader(text: vibeSection?.title ?? "")
//        }else{
//            headerView.configureHeader(text: lengthSection?.title ?? "")
//        }
//        
//        return headerView
//    }
//    
//    
//}
//
//
//func generateContentPreferencesLayout() -> UICollectionViewLayout{
//    let layout = UICollectionViewCompositionalLayout { sectionIndex, env -> NSCollectionLayoutSection? in
//        
//        
//        var headerSupplementary: NSCollectionLayoutBoundarySupplementaryItem? = nil
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        headerSupplementary = header
//        
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(45))
//        
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = .init(top: 10, leading: 3, bottom: 0, trailing: 3)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
//        
//        let subitems = Array(repeating: item, count: 3)
//        
//        
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)
//        
//        let section = NSCollectionLayoutSection(group: group)
//        
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
//        
//        if let header = headerSupplementary {
//            section.boundarySupplementaryItems = [header]
//        }
//        
//        return section
//    }
//    
//    return layout
//}
//
//
//
//extension ContentPreferencesCardCollectionViewCell: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedOption = sections[indexPath.section].options[indexPath.item]
//        
//        if selectedOption == otherOptionKey {
//            toggleTextField(active: true)
//        }
//        
//        updateSelection()
//        notifyCompletionIfNeeded()
//    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let deselectedOption = sections[indexPath.section].options[indexPath.item]
//        
//        if deselectedOption == otherOptionKey {
//            toggleTextField(active: false)
//        }
//        
//        updateSelection()
//        notifyCompletionIfNeeded()
//    }
//}
