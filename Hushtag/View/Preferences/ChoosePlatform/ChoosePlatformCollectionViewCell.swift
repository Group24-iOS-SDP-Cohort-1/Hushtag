//
//  ChoosePlatformCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit

class ChoosePlatformCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    
    @IBOutlet weak var innerCollectionView: UICollectionView!
    
    
    weak var delegate: PreferenceCardSelectionDelegate?
    var cardIndex: Int = -1
    
    var preferenceID: Int = 0
    var platformOptions: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
        setupCollectionView()
    }
    
    func setupCardDesign() {
        contentView.applyLiquidGlassEffect()
    }
    
    func setupCollectionView() {
        innerCollectionView.dataSource = self
        innerCollectionView.delegate = self
        innerCollectionView.allowsMultipleSelection = true
        innerCollectionView.backgroundColor = .clear
        innerCollectionView.alwaysBounceVertical = false
        innerCollectionView.bounces = false
        innerCollectionView.register(UINib(nibName: "ContentGoalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contentGoalCell")
    }
    
    func configureCell(with item: PreferenceItem) {
        let isFirstLoad = platformOptions.isEmpty
        
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        preferenceID = item.id
        
        if let firstSection = item.sections.first {
            platformOptions = firstSection.options
        }
        
        if isFirstLoad {
            innerCollectionView.collectionViewLayout = generatePlatformLayout()
            innerCollectionView.reloadData()
        }
    }
    
    func preselectOptions(selected: [String]) {
        innerCollectionView.layoutIfNeeded()
        
        for indexPath in innerCollectionView.indexPathsForSelectedItems ?? [] {
            innerCollectionView.deselectItem(at: indexPath, animated: false)
        }
        
        for (itemIndex, option) in platformOptions.enumerated() {
            if selected.contains(option.lowercased()) {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                innerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func updateSelection() {
        guard let selectedIndexPaths = innerCollectionView.indexPathsForSelectedItems else { return }
        
        let sortedPaths = selectedIndexPaths.sorted { $0.item < $1.item }
        let selectedValues = sortedPaths.map { platformOptions[$0.item] }
        
        let hasSelection = !selectedValues.isEmpty
        delegate?.preferenceCard(at: cardIndex, didChangeCompletion: hasSelection)
        delegate?.preferenceCard(at: "Platform", didUpdateSelection: selectedValues)
    }
}

extension ChoosePlatformCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return platformOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let optionText = platformOptions[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentGoalCell", for: indexPath) as! ContentGoalsCollectionViewCell
        cell.configureCell(with: optionText)
        
        if let selectedPaths = collectionView.indexPathsForSelectedItems, selectedPaths.contains(indexPath) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelection()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateSelection()
    }
}

func generatePlatformLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
    let subitems = Array(repeating: item, count: 1)
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    
    return UICollectionViewCompositionalLayout(section: section)
}
