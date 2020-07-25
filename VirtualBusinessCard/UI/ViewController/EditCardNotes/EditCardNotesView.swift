//
//  EditCardNotesView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardNotesView: AppBackgroundView {

    static let defaultTableViewContentInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

    let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.estimatedRowHeight = 100
        this.registerReusableCell(TextCollectionCell.self)
        this.contentInset = defaultTableViewContentInsets
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        addSubview(tableView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()
    }

    override func configureColors() {
        super.configureColors()
        tableView.backgroundColor = backgroundColor
    }
}

extension EditCardNotesView {
    final class TextCollectionCell: AppTableViewCell, Reusable {
        let notesTextView: UITextView = {
            let this = UITextView()
            this.font = .appDefault(size: 15)
            this.isScrollEnabled = false
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(notesTextView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            notesTextView.constrainToEdgesOfSuperview(inset: 16)
        }

        override func configureColors() {
            super.configureColors()
            notesTextView.tintColor = .appAccent
            contentView.backgroundColor = notesTextView.backgroundColor
        }
    }
}
