import UIKit

protocol DealsInfoDelegate: AnyObject {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int)
    func dealsInfo(_ controller: DealsInfo, didDeleteDeal dealId: UUID)
}

class DealsInfo: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var delete: UIBarButtonItem!

    var deals: Deal!
    var dealIndex: Int = -1
    var selectedIdeas: [ScriptedIdea] = []
    weak var delegate: DealsInfoDelegate?

    private let cardBackgroundKind = "card-background"

    private let brandDealIdeasController = BrandDealIdeasController()
    private let scriptedIdeasController = ScriptedIdeasController()

    @IBOutlet var completeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = deals.name
        view.backgroundColor = .black

        configureCollectionView()
        configureLayout()

        completeButton.layer.cornerRadius = 12
        updateButtonState()

        fetchLinkedIdeas()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealTagChanged),
            name: .dealTagChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScriptDeleted),
            name: .scriptDeleted,
            object: nil
        )
    }

    @objc private func handleDealTagChanged() {
        fetchLinkedIdeas()
    }

    @objc private func handleScriptDeleted() {
        fetchLinkedIdeas()
    }

    func fetchLinkedIdeas() {
        // We use Task to run the async network calls
        Task {
            do {
                // Step A: Get the mappings for this specific deal
                let mappings = try await brandDealIdeasController.fetchScriptsForDeal(dealId: deals.id)

                // Extract just the UUIDs from the mappings
                let ideaIds = mappings.map { $0.scriptedIdeaId }

                // If there are no linked ideas, just reload the empty section and exit
                guard !ideaIds.isEmpty else {
                    self.selectedIdeas = []
                    await MainActor.run { self.collectionView.reloadData() }
                    return
                }

                // Step B: Fetch the actual ScriptedIdea content using the extracted IDs
                let fetchedIdeas = try await scriptedIdeasController.fetchScripts(byIds: ideaIds)

                // Step C: Update the UI on the main thread
                await MainActor.run {
                    self.selectedIdeas = fetchedIdeas
                    self.collectionView.reloadData()
                }

            } catch {
                print("❌ Failed to fetch linked ideas:", error)
                // Optional: Handle the error gracefully in your UI here
            }
        }
    }

    func updateButtonState() {
        if !deals.deliverables.isEmpty {
            completeButton.isHidden = true
            return
        }

        completeButton.isHidden = false

        let isCompleted = deals.isManuallyCompleted
        let title = isCompleted ? "Marked" : "Mark as Completed"

        completeButton.setTitle(title, for: .normal)
    }

    @IBAction func toggleCompletionStatus(_: Any) {
        let newStatus = !deals.isManuallyCompleted
        deals.isManuallyCompleted = newStatus
        updateButtonState()

        _Concurrency.Task {
            do {
                try await DealsController().updateDealStatus(dealId: deals.id, isCompleted: newStatus)

                await MainActor.run {
                    self.delegate?.dealsInfo(self, didUpdateDeal: self.deals, at: self.dealIndex)
                    NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                }
            } catch {
                // print("❌ Failed to update deal status:", error)
                deals.isManuallyCompleted = !newStatus
                updateButtonState()
            }
        }
    }

    @IBAction func editModal(_: Any) {
        let storyboard = UIStoryboard(name: "BrandDeals", bundle: nil)

        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "AddDealsViewController"
        ) as? AddDealsViewController else { return }

        viewController.editingDeal = deals
        viewController.editingIndex = dealIndex

        viewController.title = deals.name

        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet

        present(nav, animated: true)
    }

    @IBAction func deleteDeal(_: UIButton) {
        let alert = UIAlertController(
            title: "Delete Deal",
            message: "This deal will be permanently deleted.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteDeal()
        })

        present(alert, animated: true)
    }

    private func deleteDeal() {
        let dealId = deals.id

        _Concurrency.Task {
            do {
                try await DealsController().deleteDeal(dealId)

                await MainActor.run {
                    self.delegate?.dealsInfo(self, didDeleteDeal: dealId)
                    self.navigationController?.popViewController(animated: true)
                }

            } catch {
                // print("❌ Delete failed:", error)
            }
        }
    }
}

extension DealsInfo {
    var sections: [Section] {
        var result: [Section] = [.details]

        if !deals.deliverables.isEmpty {
            result.append(.deliverables)
        }

        // Check the array instead of a single optional
        if !selectedIdeas.isEmpty {
            result.append(.selectedIdeas)
        }

        return result
    }
}

extension DealsInfo {
    enum Section {
        case details
        case deliverables
        case selectedIdeas
    }
}

extension DealsInfo {
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "DetailsCell", bundle: nil),
            forCellWithReuseIdentifier: "DetailsCell"
        )

        collectionView.register(
            UINib(nibName: "DeliverableCell", bundle: nil),
            forCellWithReuseIdentifier: DeliverableCell.reuseId
        )

        collectionView.register(
            UINib(nibName: "ScriptsCell1", bundle: nil),
            forCellWithReuseIdentifier: "selectedIdeaCell"
        )

        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
        )
    }

    private func configureLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.sections[sectionIndex]

            if section == .details {
                return self.makeCardSection(estimatedItemHeight: 56)
            } else if section == .deliverables {
                return self.makeCardSection(estimatedItemHeight: 64)
            } else {
                // Apply the modification below
                return self.makeOrthogonalSection(estimatedItemHeight: 150)
            }
        }

        layout.register(
            CardBackgroundView.self,
            forDecorationViewOfKind: cardBackgroundKind
        )

        collectionView.collectionViewLayout = layout
    }

    /// Kept for Details and Deliverables sections
    private func makeCardSection(estimatedItemHeight: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedItemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]

        let background = NSCollectionLayoutDecorationItem.background(
            elementKind: cardBackgroundKind
        )
        background.contentInsets = .init(top: 38, leading: 16, bottom: 16, trailing: 16)
        section.decorationItems = [background]

        return section
    }

    /// UPDATED FUNCTION: Renamed and modified to remove background for ideas
    private func makeOrthogonalSection(estimatedItemHeight: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .estimated(estimatedItemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)

        // 1. Change behavior to groupPaging (aligns to leading edge instead of center)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 12

        // 2. Add back the leading margin (16) so it aligns with your headers/other cards
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        // Adjust header to 0 since the section now handles the 16pt left margin
        header.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]

        return section
    }
}

// MARK: - CollectionView and Delegate extensions moved to DealsInfo+Extensions.swift
