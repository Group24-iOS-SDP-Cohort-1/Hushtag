import UIKit

extension AddDealsViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 70
    }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0.1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sec = Section(rawValue: section) else { return nil }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        if sec == .deliverables {
            titleLabel.text = "Deliverables"

            let addButton = UIButton(type: .system)
            addButton.setTitle("+ Add Deliverable", for: .normal)
            addButton.titleLabel?.font = .systemFont(ofSize: 16)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(addDeliverableTapped), for: .touchUpInside)
            headerView.addSubview(addButton)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),

                addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                addButton.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor)
            ])

            return headerView
        }

        if sec == .mainFields {
            titleLabel.text = "Deal Details"

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 32),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12)
            ])

            return headerView
        }

        return nil
    }

    override func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
        return nil
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.section == Section.deliverables.rawValue, editingStyle == .delete {
            currentDeliverables.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(
        _: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return section == Section.mainFields.rawValue
            ? fieldPlaceholders.count
            : currentDeliverables.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let sec = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sec {
        case .mainFields:
            return configureMainFieldCell(for: tableView, at: indexPath)

        case .deliverables:
            return configureDeliverableCell(for: tableView, at: indexPath)
        }
    }

    private func configureMainFieldCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: "MainFieldCell", for: indexPath) as? MainFieldCell
        else {
            return UITableViewCell()
        }

        let placeholder = fieldPlaceholders[indexPath.row]
        cell.textField.placeholder = placeholder

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: true)

        setupInputView(for: cell.textField, placeholder: placeholder, toolbar: toolbar)

        return cell
    }

    private func setupInputView(for textField: UITextField, placeholder: String, toolbar: UIToolbar) {
        switch placeholder {
        case "Platform":
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)

            let actions = Platform.allCases.map { platform in
                UIAction(title: platform.rawValue.capitalized) { _ in
                    textField.text = platform.rawValue.capitalized
                }
            }

            let menu = UIMenu(children: actions)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true

            textField.rightView = button
            textField.rightViewMode = .always
        case "Payment":
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.keyboardType = .decimalPad
        case "Phone number":
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.keyboardType = .phonePad
        case "Email":
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.keyboardType = .emailAddress
        case "Deadline":
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.inputView = deadlinePicker
            textField.inputAccessoryView = toolbar
        case "Reminder":
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.inputView = reminderPicker
            textField.inputAccessoryView = toolbar
        default:
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.keyboardType = .default
        }
    }
    private func configureDeliverableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: "DynamicItemCell", for: indexPath) as? DynamicItemCell
        else {
            return UITableViewCell()
        }

        let deliverable = currentDeliverables[indexPath.row]
        cell.configure(title: deliverable.name, placeholder: "Deliverable title", date: deliverable.deadline)

        cell.titleChanged = { [weak self] newTitle in
            self?.currentDeliverables[indexPath.row].name = newTitle
        }

        cell.dateChanged = { [weak self] newDate in
            self?.currentDeliverables[indexPath.row].deadline = newDate
        }

        return cell
    }
}
