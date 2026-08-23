import UIKit

class Details: UIViewController {
    @IBOutlet var detailsView: UICollectionView!
    var schedule: ScheduleItem?
    var onToggleDeliverable: ((Deal, Deliverable) -> Void)?
    var onToggleMainDeal: ((Deal) -> Void)?
    let dealsController = DealsController()

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.dataSource = self
        detailsView.setCollectionViewLayout(generateLayout(), animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsDidChange),
            name: .dealsDidChange,
            object: nil
        )
    }

    @objc private func handleDealsDidChange() {
        Task {
            do {
                let deals = try await dealsController.fetchDeals()
                if case let .deal(currentDeal, currentDeliverable) = self.schedule {
                    if let updatedDeal = deals.first(where: { $0.id == currentDeal.id }) {
                        let updatedDeliverable = currentDeliverable != nil ?
                            (updatedDeal.deliverables
                                .first(where: { $0.id == currentDeliverable!.id }) ?? currentDeliverable) : nil

                        await MainActor.run {
                            self.schedule = .deal(deal: updatedDeal, deliverable: updatedDeliverable)
                            self.detailsView.reloadData()
                        }
                    }
                }
            } catch {
                print("Failed to fetch deals: \(error)")
            }
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ in
            guard let self, let schedule = self.schedule else { return nil }

            if case .deal = schedule, section == 0 || section == 1 {
                return self.dealLayoutSection()
            }

            return self.defaultLayoutSection()
        }
    }

    private func dealLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .estimated(90)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    private func defaultLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 7, leading: 7, bottom: 7, trailing: 7)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    func performDelete(dealId: UUID) {
        Task {
            do {
                try await dealsController.deleteDeal(dealId)

                // Notify Schedule to reload
                NotificationCenter.default.post(
                    name: .dealsDidChange,
                    object: nil
                )

                await MainActor.run {
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Failed to Delete",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func performDeleteYouTubeUpload(upload: YouTubeUpload) {
        Task {
            do {
                try await YouTubeUploadController().deleteUpload(
                    uploadId: upload.id,
                    youtubeVideoId: upload.youtubeVideoId
                )

                // Notify Schedule to reload
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .scheduleDidChange,
                        object: nil
                    )
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Failed to Delete Video",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func handleDeliverableToggle(deal: Deal, deliverable: Deliverable) async {
        onToggleDeliverable?(deal, deliverable)
    }

    func handleMainDealToggle(deal: Deal) async {
        onToggleMainDeal?(deal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "editDeal" {
            if let nav = segue.destination as? UINavigationController,
               let dest = nav.topViewController as? AddDealsViewController,
               case let .deal(deal, _) = schedule {
                dest.editingDeal = deal
                dest.editingIndex = 0
                dest.delegate = self
            } else if let dest = segue.destination as? AddDealsViewController,
                      case let .deal(deal, _) = schedule {
                dest.editingDeal = deal
                dest.editingIndex = 0
                dest.delegate = self
            }
        }
    }
}
