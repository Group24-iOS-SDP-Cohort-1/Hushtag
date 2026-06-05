import UIKit

extension CreatePostViewController {
    func setupDescriptionView() {
        descriptionContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

        descriptionTextView.backgroundColor = .clear
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        descriptionPlaceholder.text = "Enter post description..."
        descriptionPlaceholder.font = .systemFont(ofSize: 16)
        descriptionPlaceholder.textColor = .placeholderText
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        descriptionContainer.addSubview(descriptionTextView)
        descriptionContainer.addSubview(descriptionPlaceholder)

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainer.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor),
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 0)
        ])
    }

    func setupTitleView() {
        titleContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true

        titleTextView.backgroundColor = .clear
        titleTextView.font = .systemFont(ofSize: 16)
        titleTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        titleTextView.delegate = self
        titleTextView.translatesAutoresizingMaskIntoConstraints = false

        titlePlaceholder.text = "Enter post title"
        titlePlaceholder.font = .systemFont(ofSize: 16)
        titlePlaceholder.textColor = .placeholderText
        titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false

        titleContainer.addSubview(titleTextView)
        titleContainer.addSubview(titlePlaceholder)

        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleTextView.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titlePlaceholder.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 8),
            titlePlaceholder.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 0)
        ])
    }

    func setupTagsView() {
        tagsContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true

        tagsTextView.backgroundColor = .clear
        tagsTextView.font = .systemFont(ofSize: 16)
        tagsTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        tagsTextView.delegate = self
        tagsTextView.translatesAutoresizingMaskIntoConstraints = false

        tagsPlaceholder.text = "Add tags separated by commas"
        tagsPlaceholder.font = .systemFont(ofSize: 16)
        tagsPlaceholder.textColor = .placeholderText
        tagsPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        tagsContainer.addSubview(tagsTextView)
        tagsContainer.addSubview(tagsPlaceholder)

        NSLayoutConstraint.activate([
            tagsTextView.topAnchor.constraint(equalTo: tagsContainer.topAnchor),
            tagsTextView.leadingAnchor.constraint(equalTo: tagsContainer.leadingAnchor),
            tagsTextView.trailingAnchor.constraint(equalTo: tagsContainer.trailingAnchor),
            tagsTextView.bottomAnchor.constraint(equalTo: tagsContainer.bottomAnchor),
            tagsPlaceholder.topAnchor.constraint(equalTo: tagsContainer.topAnchor, constant: 8),
            tagsPlaceholder.leadingAnchor.constraint(equalTo: tagsContainer.leadingAnchor, constant: 0)
        ])
    }

    func buildLayout() {
        setupTitleView()
        setupDescriptionView()
        setupTagsView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.register(PostFieldCell.self, forCellReuseIdentifier: "PostFieldCell")
        tableView.register(PostMediaCell.self, forCellReuseIdentifier: "PostMediaCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
