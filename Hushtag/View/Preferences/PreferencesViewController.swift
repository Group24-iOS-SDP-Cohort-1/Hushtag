import GoogleSignIn
import UIKit

protocol PreferenceCardSelectionDelegate: AnyObject {
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool)
    func preferenceCard(
        at key: String,
        didUpdateSelection selections: [String]
    )
}

class PreferencesViewController: UIViewController {
    @IBOutlet var preferencesCollectionView: UICollectionView!
    @IBOutlet var progessBarOutlet: UIProgressView!
    @IBOutlet var pageControlOutlet: UIPageControl!
    @IBOutlet var skipSubmitButton: UIBarButtonItem!

    var preferenceItems: [PreferenceItem] = PreferencesData.items
    private var completedStates: [Bool] = []
    var initialPreference: UserPreference? // Optional passed from Profile

    /// Store user's selected string options here.
    private var selectedOptions: [String: [String]] = [
        "Niche": [],
        "Platform": []
    ]

    let controller = PreferencesController()

    override func viewDidLoad() {
        super.viewDidLoad()

        completedStates = Array(repeating: false, count: preferenceItems.count)

        // If initial preferences are passed, prefill the options dictionary and completion states
        if let prefs = initialPreference {
            selectedOptions["Niche"] = prefs.niche.map { $0.rawValue }
            selectedOptions["Platform"] = prefs.platform.map {
                $0 == .x ? "x (twitter)" : $0.rawValue
            }

            if completedStates.count > 0 {
                completedStates[0] = !prefs.niche.isEmpty
                completedStates[1] = !prefs.platform.isEmpty
            }
        }

        registerCells()

        let layout = generateLayout()
        preferencesCollectionView.setCollectionViewLayout(layout, animated: true)

        preferencesCollectionView.dataSource = self
        preferencesCollectionView.clipsToBounds = false
        preferencesCollectionView.isPagingEnabled = false

        preferencesCollectionView.alwaysBounceVertical = false
        preferencesCollectionView.bounces = false

        pageControlOutlet.numberOfPages = preferenceItems.count
        pageControlOutlet.currentPage = 0

        UIView.performWithoutAnimation {
            updateSkipButton(for: 0)
            view.layoutIfNeeded()
        }

        updateProgressFromCompletedStates(animated: false)
    }

    @IBAction func submitButton(_: Any) {
        skipSubmitButton.isEnabled = false

        _Concurrency.Task { @MainActor in
            do {
                try await controller.savePreferences(
                    dict: selectedOptions
                )

                try await AuthManager.shared.completeOnboarding()

                // Only navigate away on success
                if let nav = self.navigationController, nav.viewControllers.count > 1 {
                    OpaqueLoadingScreen.shared
                        .show(message: "Loading...")
                    await SessionManager.shared.restoreSession()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"

                    let endDate = formatter.string(from: Date())

                    let startDate = formatter.string(
                        from: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                    )

                    await YouTubeController.shared.restoreYouTubeConnectionIfNeeded(
                        startDate: startDate,
                        endDate: endDate
                    )
                    OpaqueLoadingScreen.shared
                        .hide()
                    nav.popViewController(animated: true)
                } else {
                    OpaqueLoadingScreen.shared
                        .show(message: "Loading...")
                    await SessionManager.shared.restoreSession()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"

                    let endDate = formatter.string(from: Date())

                    let startDate = formatter.string(
                        from: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                    )

                    await YouTubeController.shared.restoreYouTubeConnectionIfNeeded(
                        startDate: startDate,
                        endDate: endDate
                    )
                    OpaqueLoadingScreen.shared
                        .hide()
                    self.navigateToHomeScreen()
                }

                self.skipSubmitButton.isEnabled = true

            } catch {
                print("Failed to update onboarding status or save preferences: \(error)")
                self.skipSubmitButton.isEnabled = true

                let alert = UIAlertController(
                    title: "Save Failed",
                    message: "We were unable to save your preferences. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func pageSelectorAction(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        preferencesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func updateProgressFromCompletedStates(animated: Bool = true) {
        let completedCount = completedStates.filter { $0 }.count
        let total = preferenceItems.count
        guard total > 0 else { return }

        let progress = Float(completedCount) / Float(total)
        progessBarOutlet.setProgress(progress, animated: animated)
    }

    func updateProgressAndPagination(forIndex index: Int) {
        pageControlOutlet.currentPage = index

        updateSkipButton(for: index)
    }

    func registerCells() {
        preferencesCollectionView.register(UINib(nibName: "NicheCollectionCardViewCell", bundle: nil), forCellWithReuseIdentifier: "nicheCard")
        preferencesCollectionView.register(UINib(nibName: "ChoosePlatformCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "platformCard")
    }

    func generateLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: size)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.95),
            heightDimension: .fractionalHeight(1.0)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        section.interGroupSpacing = 20

        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        section.visibleItemsInvalidationHandler = { [weak self] items, offset, env in
            guard let self = self else { return }

            let containerCenterX = offset.x + (env.container.contentSize.width / 2.0)

            let nearest = items.min { a, b in
                abs(a.frame.midX - containerCenterX) < abs(b.frame.midX - containerCenterX)
            }

            let page = nearest?.indexPath.item ?? 0

            DispatchQueue.main.async {
                self.pageControlOutlet.numberOfPages = max(1, self.preferenceItems.count)
                self.pageControlOutlet.currentPage = page

                UIView.performWithoutAnimation {
                    self.updateSkipButton(for: page)
                    self.view.layoutIfNeeded()
                }
            }
        }

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PreferencesViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return preferenceItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = preferenceItems[indexPath.item]

        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "platformCard", for: indexPath) as! ChoosePlatformCollectionViewCell
            cell.configureCell(with: item)

            // Preselect based on our fetched data
            if let selections = selectedOptions["Platform"] {
                cell.preselectOptions(selected: selections)
            }

            cell.delegate = self
            cell.cardIndex = indexPath.item

            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nicheCard", for: indexPath) as! NicheCollectionCardViewCell
        cell.configureCell(with: item)

        // Preselect based on our fetched data
        if let selections = selectedOptions["Niche"] {
            cell.preselectOptions(selected: selections)
        }

        cell.delegate = self
        cell.cardIndex = indexPath.item

        return cell
    }

    func updateSkipButton(for index: Int) {
        let lastIndex = preferenceItems.count - 1

        if index == lastIndex {
            skipSubmitButton.title = ""
            skipSubmitButton.image = UIImage(systemName: "checkmark")
        } else {
            skipSubmitButton.image = nil
            skipSubmitButton.title = "Skip"
        }
    }
}

extension PreferencesViewController: PreferenceCardSelectionDelegate {
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool) {
        guard index >= 0, index < completedStates.count else { return }

        if completedStates[index] != isCompleted {
            completedStates[index] = isCompleted
            updateProgressFromCompletedStates()
        }
    }

    func preferenceCard(at key: String, didUpdateSelection selections: [String]) {
        selectedOptions[key] = selections.map { $0.lowercased() }
        // print(selectedOptions[key])
        // print("\n\n\(selectedOptions)")
    }
}
