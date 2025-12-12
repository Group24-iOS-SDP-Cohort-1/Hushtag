//
//  NotesCell.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import Foundation
import UIKit

import UIKit

final class NotesCell: UICollectionViewCell {
    // public label we will set from the data source
    let label: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // keep the cell background clear; the section card or surrounding layout should handle background
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
