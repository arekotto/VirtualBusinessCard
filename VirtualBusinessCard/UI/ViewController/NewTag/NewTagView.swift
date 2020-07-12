//
//  NewTagView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Colorful

final class NewTagView: AppBackgroundView {
    
    let nameField: UITextField = {
        let this = UITextField()
        this.placeholder = NSLocalizedString("Enter tag name", comment: "")
        this.textAlignment = .center
        this.font = UIFont.appDefault(size: 18, weight: .medium, design: .default)
        this.tintColor = .appAccent
        return this
    }()
    
    let deleteButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Delete Tag", comment: ""), for: .normal)
        this.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        this.layer.cornerRadius = 12
        this.clipsToBounds = true
        this.isHidden = true
        return this
    }()
    
    let colorsCollectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        this.registerReusableCell(CollectionCell.self)
        this.backgroundColor = nil
        return this
    }()
    
    private let nameLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 13, weight: .medium, design: .rounded)
        this.text = NSLocalizedString("Name", comment: "")
        this.textAlignment = .center
        return this
    }()
    
    private let colorLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 13, weight: .medium, design: .rounded)
        this.text = NSLocalizedString("Color", comment: "")
        this.textAlignment = .center
        return this
    }()
    
    private lazy var nameStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [nameLabel, nameField])
        this.spacing = 4
        this.axis = .vertical
        return this
    }()
    
    private lazy var colorStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [colorLabel, colorsCollectionView])
        this.spacing = 4
        this.axis = .vertical
        this.distribution = .fillProportionally
        return this
    }()
    
    private let editableBackgroundView: UIView = {
        let this = UIView()
        this.layer.cornerRadius = 12
        this.clipsToBounds = true
        return this
    }()
    
    private var tagImagesViewWidthConstraint: NSLayoutConstraint!
    private let tagImageView: UIImageView = {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let this = UIImageView(image: UIImage(systemName: "tag.fill", withConfiguration: imgConfig)!.withRenderingMode(.alwaysTemplate))
        this.contentMode = .scaleAspectFit
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [editableBackgroundView, tagImageView, nameStackView, colorStackView, deleteButton].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()

        tagImageView.constrainHeight(constant: 100)
        tagImageView.constrainTopToSuperviewSafeArea(inset: 16)
        tagImagesViewWidthConstraint = tagImageView.constrainWidth(constant: 90)
        tagImageView.constrainCenterXToSuperview()
        
        nameLabel.constrainHeight(constant: 16)
        nameField.constrainHeight(constant: 24)
        nameStackView.constrainHorizontallyToSuperview(sideInset: 24)
        nameStackView.constrainTop(to: tagImageView.bottomAnchor, constant: 32)
        
        colorLabel.constrainHeight(constant: 16)
        colorsCollectionView.constrainHeight(constant: (UIScreen.main.bounds.width - 80) * 0.5)
        colorStackView.constrainTop(to: nameStackView.bottomAnchor, constant: 24)
        colorStackView.constrainHorizontallyToSuperview(sideInset: 16)

        editableBackgroundView.constrainTop(to: nameStackView.topAnchor, constant: -16)
        editableBackgroundView.constrainHorizontallyToSuperview(sideInset: 16)
        editableBackgroundView.constrainBottom(to: colorStackView.bottomAnchor, constant: 16)
        
        deleteButton.constrainCenterXToSuperview()
        deleteButton.constrainTop(to: editableBackgroundView.bottomAnchor, constant: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.textColor = .secondaryLabel
        colorLabel.textColor = .secondaryLabel
        editableBackgroundView.backgroundColor = .roundedTableViewCellBackground
        deleteButton.setTitleColor(.appAccent, for: .normal)
        deleteButton.backgroundColor = .roundedTableViewCellBackground
    }
    
    func setTagColor(_ color: UIColor, animated: Bool = false) {
        tagImageView.tintColor = color
        if animated {
            let bounceAmount: CGFloat = 10
            tagImagesViewWidthConstraint.constant += bounceAmount
            UIView.animate(withDuration: 0.1, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                self.tagImagesViewWidthConstraint.constant -= bounceAmount
                UIView.animate(withDuration: 0.1) {
                    self.layoutIfNeeded()
                }
            })
        }
    }
}

extension NewTagView {
    static func collectionViewLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
        

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    final class CollectionCell: AppCollectionViewCell, Reusable {
        
        var color: UIColor?
        
        override var isSelected: Bool {
            get { super.isSelected }
            set {
                super.isSelected = newValue
                contentView.backgroundColor = newValue ? .selectedCellBackgroundStrong : nil
            }
        }
        
        private let colorView: UIView = {
            let this = UIView()
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(colorView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            colorView.constrainToEdgesOfSuperview(inset: 8)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            colorView.backgroundColor = color
            contentView.backgroundColor = isSelected ? .selectedCellBackgroundStrong : nil
            roundCorners()
        }
        
        private func roundCorners() {
            colorView.layer.cornerRadius = colorView.frame.height / 2
            contentView.layer.cornerRadius = contentView.frame.height / 2
        }
    }
}
