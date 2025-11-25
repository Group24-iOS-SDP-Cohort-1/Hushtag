//
//  Ideate.swift
//  Hushtag
//
//  Created by SDC-USER on 20/11/25.
//


import UIKit

class Ideate: UIViewController{




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
        
       // ScrollView.contentSize = CGSize(width: 700, height: 147)


//            Cards()

        ideas = ideaResponse.ideas
        PlusCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        PlusCollectionView.dataSource = self
        print("Ideas loaded: \(ideas.count)")   // debug
       PlusCollectionView.reloadData()
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

            //define the size of the compositional layout item
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )

            //create item using size
            let item = NSCollectionLayoutItem(layoutSize: size)

            //create size of the group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            //create the group
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            //add spacing between the items of the group
            group.interItemSpacing = .fixed(10)

            let section = NSCollectionLayoutSection(group: group)
           section.orthogonalScrollingBehavior = .groupPagingCentered

            //add spacing between the horizontal groups
            section.interGroupSpacing = 20

            //give padding to the sections
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 10,
                bottom: 0,
                trailing: 10
            )

            let layout = UICollectionViewCompositionalLayout(section: section)

            return layout

        }






}

extension Ideate: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ideas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell", for: indexPath) as! PlusCollectionViewCell
        let ideas = self.ideas[indexPath.row]
        cell.configureCell(idea : ideas)
        return cell
    }


}
