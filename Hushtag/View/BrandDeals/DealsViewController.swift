import PostgREST
import Supabase
import UIKit

class DealsViewController: UIViewController {
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!

    var selectedDeal: Deal?
    var deals: [Deal] = []
    private var isSearching = false
    private var searchText = ""
    private let dealsController = DealsController()

    private let noDealsStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .center
        stackview.spacing = 15
        stackview.isHidden = true
        return stackview
    }()

    private let noDealsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tag.fill")
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let noDealsLabel: UILabel = {
        let label = UILabel()
        label.text = "No deals added"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    var completedDeals: [Deal] {
        deals.filter { $0.isCompleted }
    }

    var ongoingDeals: [Deal] {
        return deals.filter { !$0.isCompleted }
    }

    private var selectedSegmentIndex = 0

    var displayedDeals: [Deal] {
        let baseDeals = selectedSegmentIndex == 0 ? ongoingDeals : completedDeals

        guard isSearching, !searchText.isEmpty else {
            return baseDeals
        }

        let query = searchText.lowercased()

        return baseDeals.filter {
            $0.name.lowercased().contains(query) ||
                $0.email.lowercased().contains(query) ||
                $0.platform.contains(where: {
                    $0.rawValue.lowercased().contains(query)
                })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        setupNoDealsLabel()
        Task {
            do {
                _ = try await SupabaseConfig.client.auth.session
                // print("Logged in UID:", session.user.id)
                // print("SESSION ACCESS TOKEN:", session.accessToken.prefix(20))

            } catch {
                // print("❌ No auth session:", error)
            }
        }

        fetchDeals()

        // print(deals.count)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        segmentControl.selectedSegmentIndex = 0

        selectedSegmentIndex = 0
        let grayColor = UIColor.darkGray

        segmentControl.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsDidChange),
            name: .dealsDidChange,
            object: nil
        )
    }

    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        collectionView.reloadData()
        updateEmptyState()
    }

    @objc private func handleDealsDidChange() {
        fetchDeals()
    }

    private func fetchDeals() {
        _Concurrency.Task {
            do {
                let fetchedDeals = try await dealsController.fetchDeals()

                await MainActor.run {
                    self.deals = fetchedDeals
                    self.selectedSegmentIndex = self.segmentControl.selectedSegmentIndex
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                // print("Supabase insert failed:")
                dump(error)
            }
        }
    }

    func registerCell() {
        collectionView.register(
            UINib(nibName: "DealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ongoing_deal_cell"
        )
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] _, _ in
            let isCompleted = (self?.selectedSegmentIndex == 1)

            let estimatedHeight: CGFloat = isCompleted ? 100 : 200

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
            return section
        }
    }

    private func setupNoDealsLabel() {
        view.addSubview(noDealsStackView)
        noDealsStackView.addArrangedSubview(noDealsImageView)
        noDealsStackView.addArrangedSubview(noDealsLabel)

        noDealsStackView.translatesAutoresizingMaskIntoConstraints = false
        noDealsImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            noDealsStackView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            noDealsStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),

            noDealsImageView.widthAnchor.constraint(equalToConstant: 80),
            noDealsImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func updateEmptyState() {
        noDealsStackView.isHidden = !displayedDeals.isEmpty
    }
}

extension DealsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        return displayedDeals.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let deal = displayedDeals[indexPath.item]
        let isCompletedTab = (selectedSegmentIndex == 1)

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ongoing_deal_cell",
            for: indexPath
        ) as? DealsCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: deal, isCompleted: isCompletedTab)
        cell.onTap = { [weak self] in
            self?.performSegue(withIdentifier: "info_page", sender: deal)
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
           let addVC = nav.viewControllers.first as? AddDealsViewController {
            addVC.delegate = self
        } else if let addVC = segue.destination as? AddDealsViewController {
            addVC.delegate = self
        }

        if segue.identifier == "info_page",
           let deal = sender as? Deal,
           let dealsInfoVC = segue.destination as? DealsInfo {
            dealsInfoVC.deals = deal
            if let idx = deals.firstIndex(where: { $0.id == deal.id }) {
                dealsInfoVC.dealIndex = idx
                dealsInfoVC.delegate = self
            } else {
                dealsInfoVC.dealIndex = -1
            }
        }
    }
}

extension DealsViewController: DealsInfoDelegate {
    func dealsInfo(_: DealsInfo, didUpdateDeal deal: Deal, at _: Int) {
        if let idx = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[idx] = deal
            fetchDeals()
        }
    }

    func dealsInfo(_: DealsInfo, didDeleteDeal dealId: UUID) {
        if let index = deals.firstIndex(where: { $0.id == dealId }) {
            deals.remove(at: index)
        }

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        updateEmptyState()
    }
}

extension DealsViewController: AddDealsDelegate {
    func addDealsViewController(
        _: AddDealsViewController,
        didUpdateDeal deal: Deal,
        at _: Int
    ) {
        if let realIndex = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[realIndex] = deal
        }

        selectedSegmentIndex = segmentControl.selectedSegmentIndex
        fetchDeals()
    }

    func addDealsViewController(
        _: AddDealsViewController,
        didCreateDeal _: Deal
    ) {
        fetchDeals()
    }
}

extension DealsViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        isSearching = !searchText.isEmpty
        collectionView.reloadData()
        updateEmptyState()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        collectionView.reloadData()
        updateEmptyState()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
