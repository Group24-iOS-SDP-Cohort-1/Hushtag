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
    //var selectedIdea: Idea?
   // var isSearchMode = false


    override func viewDidLoad() {

        super.viewDidLoad()

        //text box view for generate
        textBoxView.layer.borderWidth = 0.8
        textBoxView.layer.borderColor = UIColor.accent.cgColor
        textBoxView.layer.cornerRadius = 10

        //button of textbox generate
        button.tintColor = .accent
        button.setImage(UIImage(systemName: "sparkles"), for: .normal)
     
        //textfield of textbox generate
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your keyword", attributes: [NSAttributedString.Key.foregroundColor: UIColor.accent])
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        //generate layout
        let layout = generateLayout()
        PlusCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        PlusCollectionView.dataSource = self
        PlusCollectionView.delegate = self


        ideas = ideaResponse.ideas

        PlusCollectionView.reloadData()
        PlusCollectionView.clipsToBounds = false

        //registering cells
        PlusCollectionView.register(UINib(nibName: "likedCells", bundle: nil), forCellWithReuseIdentifier: "likedCells")
        PlusCollectionView.register(UINib(nibName: "HeaderChevronView", bundle:nil ),forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_chevron")

        PlusCollectionView.isScrollEnabled = false
        ScrollView.isScrollEnabled = true
        PlusCollectionView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }

    //button change logic on input basis
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
//        if let text = textField.text, !text.isEmpty {
//              isSearchMode = true
//          } else {
//              isSearchMode = false
//          }
//
//          PlusCollectionView.reloadData()
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

            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(180),
                    heightDimension: .absolute(160)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(180),
                    heightDimension: .absolute(160)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                group.interItemSpacing = .fixed(10)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [header]
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 10, leading: 10, bottom: 10, trailing: 10
                )

                return section
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(180),
                heightDimension: .absolute(190)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(180),
                heightDimension: .absolute(190)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(10)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 10, bottom: 10, trailing: 10
            )

            return section
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScriptedIdeas",
           let destinationVC = segue.destination as? ScriptedIdeas,
           let idea = sender as? Idea {
            destinationVC.idea = idea
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
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_chevron", for: indexPath) as! HeaderChevronView
        if indexPath.section == 0 {
            headerView.configure(title: "Your Scripts")

        } else  {
            headerView.configure(title: "Liked Ideas")
        }
        return headerView
    }
}

extension Ideate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 { return }
            let idea = ideas[indexPath.row - 1]
            performSegue(withIdentifier: "toScriptedIdeas", sender: idea)

        case 1:
//            let idea = ideas[indexPath.row]
//            performSegue(withIdentifier: "toScriptedIdeas", sender: idea)
            return
        default:
            return
        }


    }
}
