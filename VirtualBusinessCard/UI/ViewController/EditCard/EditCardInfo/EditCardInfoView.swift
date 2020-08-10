//
//  EditCardInfoView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

enum EditCardInfoView {
    static let defaultTableViewContentInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
}

// MARK: - TextFieldTableCell

extension EditCardInfoView {
    final class TextFieldTableCell: AppTableViewCell, Reusable {

        let textField = EditCardInfoTextField()

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(textField)
        }

        override func configureConstraints() {
            super.configureConstraints()
            textField.constrainVerticallyToSuperview(topInset: 5, bottomInset: 5)
            textField.constrainHorizontallyToSuperview()
        }

        override func configureColors() {
            super.configureColors()
            textField.tintColor = Asset.Colors.appAccent.color
            textField.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
            backgroundColor = .clear
        }
    }
}

extension EditCardInfoView.TextFieldTableCell {

    struct DataModel {
        let title: String
        let returnKeyType: UIReturnKeyType
        let keyboardType: UIKeyboardType
        let autocapitalizationType: UITextAutocapitalizationType
    }

    func setRow(_ row: EditCardInfoVM.Row, indexPath: IndexPath, textValue: String?) {
        let dataModel = row.cellDataModel()
        textField.text = textValue
        textField.placeholder = dataModel.title
        textField.returnKeyType = dataModel.returnKeyType
        textField.keyboardType = dataModel.keyboardType
        textField.autocapitalizationType = dataModel.autocapitalizationType
        textField.row = row
        textField.indexPath = indexPath
    }
}

// MARK: - EditCardInfoTextField

extension EditCardInfoView {
    final class EditCardInfoTextField: UITextField {

        var row: EditCardInfoVM.Row?
        var indexPath: IndexPath?

        let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        init() {
            super.init(frame: .zero)
            layer.cornerRadius = 10
            autocorrectionType = .no
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            bounds.inset(by: padding)
        }

        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            bounds.inset(by: padding)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            bounds.inset(by: padding)
        }
    }
}

// MARK: - HeaderView

extension EditCardInfoView {
    final class HeaderView: AppView {

        private var labelWidthConstraint: NSLayoutConstraint!

        let label: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 19, weight: .medium)
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(label)
        }

        override func configureConstraints() {
            super.configureConstraints()
            label.constrainVerticallyToSuperview()
            label.constrainCenterXToSuperview()
            label.constrainWidthEqualTo(self)
        }

        override func configureColors() {
            super.configureColors()
            label.textColor = .secondaryLabel
        }

        func setSideInsets(_ insets: CGFloat) {
            labelWidthConstraint.constant = -2 * insets
        }
    }
}
