
import UIKit

class Ideate: UIViewController{


    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var plusCollectionView: UICollectionView!

    @IBOutlet weak var textBoxView: UIView!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var button: UIButton!

    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    //var selectedIdea: Idea?
    var isSearchMode = false
    var filteredIdeas: [Idea] = []
    var collectionViewHeightConstraint: NSLayoutConstraint?
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
        plusCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        plusCollectionView.dataSource = self
        plusCollectionView.delegate = self

        ideas = ideaResponse.ideas

        plusCollectionView.reloadData()
        plusCollectionView.clipsToBounds = false

        //registering cells
        plusCollectionView.register(UINib(nibName: "likedCells", bundle: nil), forCellWithReuseIdentifier: "likedCells")
        plusCollectionView.register(UINib(nibName: "IdeaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ideas_cell")
        plusCollectionView.register(UINib(nibName: "HeaderChevronView", bundle:nil ),forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_chevron")

        plusCollectionView.isScrollEnabled = false
        scrollView.isScrollEnabled = true
        collectionViewHeightConstraint =
        plusCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(ideas.count * 160))
        collectionViewHeightConstraint?.isActive = true
        scrollView.contentSize.width = contentView.frame.width
        scrollView.contentSize.height = plusCollectionView.frame.origin.y + plusCollectionView.frame.height + 30
    }

    //button change logic on input basis
    @objc func textDidChange() {
        if textField.text?.isEmpty ?? true {
                    isSearchMode = false
                    filteredIdeas.removeAll()
                    plusCollectionView.reloadData()
                }
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

            if self.isSearchMode {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(160)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(160)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 15
                section.orthogonalScrollingBehavior = .none
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

                return section

            }

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

    @IBAction func ideaSearch(_ sender: UIButton) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }

        filteredIdeas = ideas.filter { idea in
            idea.trending.lowercased().contains(text.lowercased())
        }
            print("Filtered ideas:", filteredIdeas.map { $0.title })

            isSearchMode = true

            updateCollectionViewHeight()

            plusCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
            plusCollectionView.reloadData()
    }

    func updateCollectionViewHeight() {
            let itemHeight: CGFloat = 160
            let itemCount = isSearchMode ? filteredIdeas.count : ideas.count
            collectionViewHeightConstraint?.constant = CGFloat(itemCount) * itemHeight
            view.layoutIfNeeded()
        }

    @IBAction func buttonTapped(_ sender: UIButton) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if isSearchMode {
                    isSearchMode = false
                    filteredIdeas.removeAll()
                    textField.text = ""
                    button.setImage(UIImage(systemName: "sparkles"), for: .normal)
                } else {
                    guard !text.isEmpty else { return }

                    filteredIdeas = ideas.filter { idea in
                        idea.trending.lowercased().contains(text.lowercased())
                    }

                    isSearchMode = true
                    button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
                }

                updateCollectionViewHeight()

                plusCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
                plusCollectionView.reloadData()
    }
}

extension Ideate: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearchMode ? 1 : 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        if isSearchMode {
            return filteredIdeas.count
        }

        if section == 0 {
            return 1 + ideas.count
        } else {
            return ideas.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if isSearchMode {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideas_cell", for: indexPath) as! IdeaCollectionViewCell
                        let idea = filteredIdeas[indexPath.row]
                        cell.configureCell(ideas: idea)
                        return cell
        }

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell",for: indexPath) as! PlusCollectionViewCell
                cell.configureCell()
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scripts_cell",for: indexPath) as! ScriptsCell
                let idea = ideas[indexPath.row - 1]
                cell.configureCell(idea: idea)
                return cell
            }
        }

        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "likedCells",for: indexPath) as! likedCells
        let idea = ideas[indexPath.row]
        cell.configureCell(idea: idea)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath: IndexPath) ->UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "header_chevron",
            for: indexPath
        ) as! HeaderChevronView

        if isSearchMode {
            headerView.configure(title: "Search Results")
        } else if indexPath.section == 0 {                                  //PASSING DATA FOR VIEWING ALL SCRIPTS
            headerView.configure(title: "Your Scripts")
            headerView.onTap = { [weak self] in
                guard let self = self else { return }
                let sb = UIStoryboard(name: "ViewScripts", bundle: nil)
                guard let navVC = sb.instantiateInitialViewController() as? UINavigationController else {
                        print("Error: Initial VC is not a Navigation Controller")
                        return
                }
                
                guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {
                        return
                }
                
                destinationVC.pageTitle = "Your Scripts"
                destinationVC.cellReuseIdentifier = "allScriptsCell"
                destinationVC.ideas = self.ideas
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        } else {                                                        //PASSING DATA FOR VIEWING ALL LIKED IDEAS
            headerView.configure(title: "Liked Ideas")
            headerView.onTap = { [weak self] in
                guard let self = self else { return }
                let sb = UIStoryboard(name: "ViewScripts", bundle: nil)
                guard let navVC = sb.instantiateInitialViewController() as? UINavigationController else {
                        print("Error: Initial VC is not a Navigation Controller")
                        return
                }
                
                guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {
                        return
                }
                
                destinationVC.pageTitle = "Liked Ideas"
                destinationVC.cellReuseIdentifier = "allScriptsCell"
                destinationVC.ideas = self.ideas
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }

        return headerView
    }
}

extension Ideate: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearchMode {
                    let idea = filteredIdeas[indexPath.row]
                    performSegue(withIdentifier: "toScriptedIdeas", sender: idea)
                    return
                }

        switch indexPath.section {

        case 0:
            if indexPath.row == 0 {
                let sb = UIStoryboard(name: "Chatbot", bundle: nil)
                let chatVC = sb.instantiateViewController(withIdentifier: "Chatbot")
                navigationController?.pushViewController(chatVC, animated: true)
                return }

            let idea = ideas[indexPath.row - 1]
            performSegue(withIdentifier: "toScriptedIdeas", sender: idea)

        //case 1:
        //let idea = ideas[indexPath.row]
        //performSegue(withIdentifier: "toScriptedIdeas", sender: idea)

        default:
            return
        }
    }


    }

extension Ideate: LikedCellDelegate {

    func didTapDraftScript(for idea: Idea) {

        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }

        // Passing the idea script text
        chatVC.autoSendMessage = "script"

        navigationController?.pushViewController(chatVC, animated: true)
    }
}



