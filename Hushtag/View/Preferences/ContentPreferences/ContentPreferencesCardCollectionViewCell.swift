//
//  ContentPreferencesCardCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class ContentPreferencesCardCollectionViewCell: UICollectionViewCell {

    //NEW
    weak var delegate: PreferenceCardSelectionDelegate?
        var cardIndex: Int = -1
    
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet weak var firstInnerCollectionView: UICollectionView!
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    @IBOutlet weak var secondInnerCollectionView: UICollectionView!
    
    var sections: [PreferenceSection] = []
    
    
    var vibeSection: PreferenceSection?
    
    var lengthSection: PreferenceSection?
    
    let otherOptionKey = "Other"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupCardDesign()
        
        firstInnerCollectionView.dataSource = self
        
        secondInnerCollectionView.dataSource = self
        
        
        //NEW
        firstInnerCollectionView.delegate = self
        secondInnerCollectionView.delegate = self
        
        registerCells()
        
        firstInnerCollectionView.allowsMultipleSelection = true
        
        secondInnerCollectionView.allowsMultipleSelection = true
        
        firstInnerCollectionView.backgroundColor = .clear
        secondInnerCollectionView.backgroundColor = .clear
        
        firstInnerCollectionView.alwaysBounceVertical = false
        firstInnerCollectionView.bounces = false
        
        secondInnerCollectionView.alwaysBounceVertical = false
        secondInnerCollectionView.bounces = false
        
        setupTextField()
    }
    
    func setupTextField() {
            textFieldOutlet.layer.cornerRadius = 12
            textFieldOutlet.layer.masksToBounds = true
            textFieldOutlet.layer.borderWidth = 1
            textFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
            
            // Initial State: Disabled and Dimmed
            textFieldOutlet.isEnabled = false
            textFieldOutlet.alpha = 0.5
            textFieldOutlet.placeholder = "Enter your niche"
            
            // Listen for typing events
            textFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            updateSelection()
        }

    
    func configureCell(with item: PreferenceItem){
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        
        sections = item.sections
        
        vibeSection = sections[0]
        lengthSection = sections[1]
        
        firstInnerCollectionView.collectionViewLayout = generateContentPreferencesLayout()
        
        secondInnerCollectionView.collectionViewLayout = generateContentPreferencesLayout()
        
        firstInnerCollectionView.reloadData()
        secondInnerCollectionView.reloadData()
        
        textFieldOutlet.text = ""
                textFieldOutlet.isEnabled = false
                textFieldOutlet.alpha = 0.5
        
//        textFieldOutlet.layer.cornerRadius = 12    // adjust to your design
//        textFieldOutlet.layer.masksToBounds = true // IMPORTANT
//        textFieldOutlet.layer.borderWidth = 1
//        textFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    //NEW
    private func notifyCompletionIfNeeded() {
            let firstSelected = firstInnerCollectionView.indexPathsForSelectedItems?.count ?? 0
            let secondSelected = secondInnerCollectionView.indexPathsForSelectedItems?.count ?? 0
            let completed = (firstSelected + secondSelected) > 0
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
        }
    
    
    private func updateSelection() {
        
        guard let selectedIndexPaths = firstInnerCollectionView.indexPathsForSelectedItems else { return }
        
        // Sort to keep order consistent
        let sortedPaths = selectedIndexPaths.sorted { $0.item < $1.item }
        
        var firstSelections: [String] = []
        
        for indexPath in sortedPaths {
            let optionText = sections[indexPath.section].options[indexPath.item]
            
            if optionText == otherOptionKey {
                // If "Other" is selected, use the text field value
                let rawText = textFieldOutlet.text ?? ""
                
                // 1. Split by comma
                // 2. Trim whitespace from each resulting item
                // 3. Filter out any empty strings (e.g., "Tech, , School")
                let customItems = rawText.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                if !customItems.isEmpty {
                    // Append all valid items individually
                    firstSelections.append(contentsOf: customItems)
                } else {
                    // Decide: Do you want to send "Other" if the box is empty?
                    // Currently, I'm sending "Other" as a placeholder so the user knows it's selected.
                    firstSelections.append(otherOptionKey)
                }
            } else {
                // Normal option (e.g., "Lifestyle", "Game")
                firstSelections.append(optionText)
            }
        }
        
        
        
        
        // selections from first (vibe)
//        let firstSelections =
//            firstInnerCollectionView.indexPathsForSelectedItems?
//            .sorted { $0.item < $1.item }
//            .compactMap { vibeSection?.options[$0.item] } ?? []

        // selections from second (length)
        let secondSelections =
            secondInnerCollectionView.indexPathsForSelectedItems?
            .sorted { $0.item < $1.item }
            .compactMap { lengthSection?.options[$0.item] } ?? []

        // merge them
        //let combined = firstSelections + secondSelections

        delegate?.preferenceCard(at: "Content Tone", didUpdateSelection: firstSelections)
        delegate?.preferenceCard(at: "Content Length", didUpdateSelection: secondSelections)
    }
    
    func toggleTextField(active: Bool) {
            textFieldOutlet.isEnabled = active
            
            UIView.animate(withDuration: 0.3) {
                self.textFieldOutlet.alpha = active ? 1.0 : 0.5
            }
            
            if active {
                // Automatically popup keyboard
                textFieldOutlet.becomeFirstResponder()
            } else {
                // Hide keyboard and clear text
                textFieldOutlet.resignFirstResponder()
                textFieldOutlet.text = ""
            }
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
        firstInnerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
        
        firstInnerCollectionView.register(UINib(nibName: "PreferencesHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
        
        secondInnerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
        
        secondInnerCollectionView.register(UINib(nibName: "PreferencesHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
    }
}


extension ContentPreferencesCardCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstInnerCollectionView{
            //print("Vibe Selected")
            return vibeSection?.options.count ?? 0
        }else if collectionView == secondInnerCollectionView{
            //print("Length Selected")
            return lengthSection?.options.count ?? 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var optionText: String = ""
        
        if collectionView == firstInnerCollectionView {
            let option = vibeSection?.options[indexPath.item]
            
            optionText = option ?? ""
        }else if collectionView == secondInnerCollectionView {
            let option = lengthSection?.options[indexPath.item]
            
            optionText = option ?? ""
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionsCell", for: indexPath) as! OptionsCollectionViewCell
        
        cell.configureCell(with: optionText)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_cell", for: indexPath) as! PreferencesHeaderView
        
        if collectionView == firstInnerCollectionView {
            headerView.configureHeader(text: vibeSection?.title ?? "")
        }else{
            headerView.configureHeader(text: lengthSection?.title ?? "")
        }
        
        return headerView
    }
    
    
}


func generateContentPreferencesLayout() -> UICollectionViewLayout{
    let layout = UICollectionViewCompositionalLayout { sectionIndex, env -> NSCollectionLayoutSection? in


        var headerSupplementary: NSCollectionLayoutBoundarySupplementaryItem? = nil
            // create header size (adjust height as needed)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            //header.supplementaryRequestMode = .absolute // optional
        headerSupplementary = header
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(45))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 3, bottom: 0, trailing: 3)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        
        let subitems = Array(repeating: item, count: 3)
        
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)

        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        if let header = headerSupplementary {
            section.boundarySupplementaryItems = [header]
        }

        return section
    }

    return layout
}



//NEW
extension ContentPreferencesCardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = sections[indexPath.section].options[indexPath.item]
        
        // If user tapped "Other", enable the text field
        if selectedOption == otherOptionKey {
            toggleTextField(active: true)
        }
        
        updateSelection()
        notifyCompletionIfNeeded()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedOption = sections[indexPath.section].options[indexPath.item]
        
        // If user tapped "Other" to deselect it, disable the text field
        if deselectedOption == otherOptionKey {
            toggleTextField(active: false)
        }
        
        updateSelection()
        notifyCompletionIfNeeded()
    }
}
