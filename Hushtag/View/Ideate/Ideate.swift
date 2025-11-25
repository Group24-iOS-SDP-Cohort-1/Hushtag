//
//  Ideate.swift
//  Hushtag
//
//  Created by SDC-USER on 20/11/25.
//


import UIKit

class Ideate: UIViewController{


    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var ContentView: UIView!

    @IBOutlet weak var ScrollView: UIScrollView!

    @IBOutlet weak var PlusCollectionView: UICollectionView!

    @IBOutlet weak var textBoxView: UIView!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var button: UIButton!

    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []

    override func viewDidLoad() {

        super.viewDidLoad()

        textBoxView.layer.borderWidth = 0.8
        textBoxView.layer.borderColor = UIColor.accent.cgColor
        textBoxView.layer.cornerRadius = 10

        let layout = generateLayout()
        PlusCollectionView.setCollectionViewLayout(layout, animated: true)
        button.tintColor = .accent
        button.setImage(UIImage(systemName: "sparkles"), for: .normal)
     

        textField.attributedPlaceholder = NSAttributedString(string: "Enter your keyword", attributes: [NSAttributedString.Key.foregroundColor: UIColor.accent])
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        ideas = ideaResponse.ideas
        PlusCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        PlusCollectionView.dataSource = self
        print("Ideas loaded: \(ideas.count)")
       PlusCollectionView.reloadData()
        PlusCollectionView.clipsToBounds = false

        PlusCollectionView.register(UINib(nibName: "likedCells", bundle: nil), forCellWithReuseIdentifier: "likedCells")
        PlusCollectionView.register(UINib(nibName: "HeaderView", bundle:nil ),forSupplementaryViewOfKind: "header", withReuseIdentifier: "headerCell")
        PlusCollectionView.isScrollEnabled = false
        ScrollView.isScrollEnabled = true
        PlusCollectionView.heightAnchor.constraint(equalToConstant: 400).isActive = true
//      

    }

    @objc func textDidChange() {
 let isEmpty = textField.text?.isEmpty ?? true

        if isEmpty {


            button.setImage(UIImage(systemName: "sparkles"), for: .normal)
        } else {


            button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        }
    }

    @IBAction func cleartext(_ sender: UIButton) {
        textField.text = ""
        textDidChange()
    }

    

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )

            // Common item size
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(180),
                heightDimension: .absolute(150)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group size
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(180), // same as item
                heightDimension: .absolute(150)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(10)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.boundarySupplementaryItems = [header]

            // Section-specific content insets
            if sectionIndex == 0 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            } else {
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            }

            return section
        }
    }





}

extension Ideate: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
             if section == 0 {
                 return 1 + ideas.count
             } else {
                 return ideas.count
             }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell", for: indexPath) as! PlusCollectionViewCell
                cell.configureCell()
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scripts_cell", for: indexPath) as! scriptsCell
                let idea = ideas[indexPath.row - 1]
                cell.configureCell(idea: idea)
                return cell
            }
        } else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "likedCells", for: indexPath) as! likedCells
            let idea = ideas[indexPath.row]
            cell.configureCell(idea: idea)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //create header view


        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "headerCell", for: indexPath) as! HeaderView
        if indexPath.section == 0 {
            headerView.configureHeader(text: "Your Scripts")

        } else  {
            headerView.configureHeader(text: "Liked Ideas")
        }


        return headerView
    }


}
