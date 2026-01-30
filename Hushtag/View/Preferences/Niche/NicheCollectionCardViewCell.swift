//
//  NicheCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class NicheCollectionCardViewCell: UICollectionViewCell {
    
    //NEW
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
    
    
    //NEW
    private func notifyCompletionIfNeeded() {
            // sum selected items across sections
            let selectedCount = innerCollectionView.indexPathsForSelectedItems?.count ?? 0
            let completed = selectedCount > 0
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
        }
    
    private func updateSelection() {
            guard let selectedIndexPaths = innerCollectionView.indexPathsForSelectedItems else { return }
            
            // Sort to keep order consistent
            let sortedPaths = selectedIndexPaths.sorted { $0.item < $1.item }
            
            var selectedValues: [String] = []
            
            for indexPath in sortedPaths {
                let optionText = sections[indexPath.section].options[indexPath.item]
                
                if optionText == otherOptionKey {
                    // Get the raw text
                    let rawText = textFieldOutlet.text ?? ""
                    
                    // 1. Split by comma
                    // 2. Trim whitespace from each resulting item
                    // 3. Filter out any empty strings (e.g., "Tech, , School")
                    let customItems = rawText.components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    if !customItems.isEmpty {
                        // Append all valid items individually
                        selectedValues.append(contentsOf: customItems)
                    } else {
                        // If the box is empty (or just spaces/commas), keep the placeholder "Other"
                        selectedValues.append(otherOptionKey)
                    }
                } else {
                    // Normal option (e.g., "Lifestyle")
                    selectedValues.append(optionText)
                }
            }

            delegate?.preferenceCard(at: "Niche", didUpdateSelection: selectedValues)
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
        
        //self.layer.cornerRadius = 12
        //self.layer.masksToBounds = false
        //self.layer.cornerCurve = .continuous
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
        
        
        
//        textFieldOutlet.layer.cornerRadius = 12    // adjust to your design
//        textFieldOutlet.layer.masksToBounds = true // IMPORTANT
//        textFieldOutlet.layer.borderWidth = 1
//        textFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    
    func registerCells(){
        innerCollectionView.register(UINib(nibName: "OptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
    }
    
}

extension NicheCollectionCardViewCell: UICollectionViewDataSource{
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


//NEW
extension NicheCollectionCardViewCell: UICollectionViewDelegate {
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
