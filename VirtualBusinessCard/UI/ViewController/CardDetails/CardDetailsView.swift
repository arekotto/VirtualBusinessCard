//
//  CardDetailsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsView: AppBackgroundView {
        
    static let contentInsetTop: CGFloat = 24

    let titleView = TitleView()
    
    let collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        this.registerReusableCell(CardImagesCell.self)
        this.registerReusableCell(TitleValueCollectionCell.self)
        this.registerReusableCell(TitleValueImageCollectionViewCell.self)
        this.registerReusableCell(TagCell.self)
        this.registerReusableCell(NoTagsCell.self)
        this.registerReusableCell(UpdateAvailableCell.self)
        this.registerReusableCell(DeleteCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.header.rawValue, RoundedCollectionCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.footer.rawValue, RoundedCollectionCell.self)
        this.alwaysBounceVertical = true
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [collectionView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainToEdgesOfSuperview()
    }
    
    override func configureColors() {
        super.configureColors()
        collectionView.backgroundColor = Asset.Colors.appBackground.color
    }
}

// MARK: - GroupedCardsView

extension CardDetailsView {

    enum SupplementaryElementKind: String {
        case header
        case footer
    }
}

// MARK: - Static functions

extension CardDetailsView {
    
    static func createCollectionViewLayoutCardImagesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(ReceivedCardsView.CollectionCell.defaultHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Self.contentInsetTop, leading: 0, bottom: 16, trailing: 0)
        return section
    }

    static func createCollectionViewLayoutDynamicSection() -> NSCollectionLayoutSection {
        let estimatedHeight = NSCollectionLayoutDimension.estimated(30)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: estimatedHeight
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let bottomOffset: CGFloat = 24
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: bottomOffset, trailing: 16)
        return section
    }

    static func createCollectionViewLayoutDetailsSection() -> NSCollectionLayoutSection {
        let estimatedHeight = NSCollectionLayoutDimension.estimated(50)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: estimatedHeight
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10))
        
        let section = NSCollectionLayoutSection(group: group)
        let bottomOffset: CGFloat = 24
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: bottomOffset, trailing: 16)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SupplementaryElementKind.header.rawValue,
                alignment: .top,
                absoluteOffset: .init(x: 0, y: 20)
            ),
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SupplementaryElementKind.footer.rawValue,
                alignment: .bottom,
                absoluteOffset: .init(x: 0, y: -bottomOffset)
            )
        ]
        return section
    }
}

// MARK: - TitleView

extension CardDetailsView {
    final class TitleView: AppView {

        var cardCornerRadiusHeightMultiplier: CGFloat = 0 {
            didSet { updateCornerRadius() }
        }
        
        private(set) var isVisible = false
        
        private var imageViewCenterConstraint: NSLayoutConstraint!
        private let imageView: UIImageView = {
            let this = UIImageView()
            this.clipsToBounds = true
            return this
        }()
        
        override func configureView() {
            super.configureView()
            clipsToBounds = true
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(imageView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            constrainSizeToBusinessCardDimensions(width: 64)
            imageView.constrainWidthEqualTo(self)
            imageView.constrainHeightEqualTo(self)
            imageView.constrainCenterXToSuperview()
            imageViewCenterConstraint = imageView.constrainCenterYToSuperview(offset: 50)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updateCornerRadius()
        }

        func setImageURL(_ url: URL?) {
            imageView.kf.setImage(with: url)
        }
        
        func animateSlideIn() {
            imageViewCenterConstraint.constant = 0
            isVisible = true
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1
                self.layoutIfNeeded()
            }
        }
        
        func animateSlideOut() {
            imageViewCenterConstraint.constant = 50
            isVisible = false
            UIView.animate(withDuration: 0.5) {
                self.alpha = 0
                self.layoutIfNeeded()
            }
        }

        private func updateCornerRadius() {
            imageView.layer.cornerRadius = imageView.frame.height * cardCornerRadiusHeightMultiplier
        }
    }
}

// MARK: - CardImagesCell

extension CardDetailsView {

    final class CardImagesCell: AppCollectionViewCell, Reusable {
                
        let cardFrontBackView = CardFrontBackView()
        
        private var cardFrontBackViewCompactHeightConstraint: NSLayoutConstraint!
        private var cardFrontBackViewCompactWidthConstraint: NSLayoutConstraint!
        
        private var cardFrontBackViewExtendedHeightConstraint: NSLayoutConstraint?
        private var cardFrontBackViewExtendedWidthConstraint: NSLayoutConstraint?
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(cardFrontBackView)
            cardFrontBackView.isHidden = true
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterToSuperview()
            cardFrontBackViewCompactWidthConstraint = cardFrontBackView.constrainWidthEqualTo(self,
                multiplier: ReceivedCardsView.CollectionCell.defaultWidthMultiplier
            )
            cardFrontBackViewCompactHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self,
                multiplier: ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            )
        }
        
        func extendWithAnimation(completion: @escaping () -> Void) {
            cardFrontBackView.lockScenesToCurrentHeights()

            cardFrontBackViewCompactHeightConstraint.isActive = false
            cardFrontBackViewCompactWidthConstraint.isActive = false
            
            let newWidth = UIScreen.main.bounds.width - 32
            let newOffset = newWidth - cardFrontBackView.frame.width
            
            cardFrontBackViewExtendedWidthConstraint = cardFrontBackView.constrainWidth(constant: newWidth)
            let multi = ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            cardFrontBackViewExtendedHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self, constant: newOffset, multiplier: multi)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
            }, completion: { _ in completion() })
        }
        
        func condenseWithAnimation(completion: @escaping () -> Void) {
            
            cardFrontBackViewExtendedWidthConstraint?.isActive = false
            cardFrontBackViewExtendedHeightConstraint?.isActive = false
            cardFrontBackViewCompactHeightConstraint.isActive = true
            cardFrontBackViewCompactWidthConstraint.isActive = true
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
            }, completion: { _ in completion() })
        }
    }
}

// MARK: - TagCell

extension CardDetailsView {

    final class TagCell: AppCollectionViewCell, Reusable {

        private var tagImageViewColor: UIColor? {
            didSet { tagImageView.tintColor = tagImageViewColor }
        }

        private let tagImageView: UIImageView = {
            let imageCong = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let image = UIImage(systemName: "tag.fill", withConfiguration: imageCong)
            let this = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
            this.contentMode = .scaleAspectFit
            return this
        }()

        let titleLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 16, weight: .semibold)
            return this
        }()

        private lazy var stackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [tagImageView, titleLabel])
            this.spacing = 4
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(stackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            stackView.constrainVerticallyToSuperview(topInset: 2, bottomInset: 2)
            titleLabel.constrainCenterX(to: contentView.centerXAnchor)
            stackView.constrainLeadingGreaterOrEqual(to: contentView.leadingAnchor, constant: 16)
            stackView.constrainTrailingLessOrEqual(to: contentView.trailingAnchor, constant: -16)
            stackView.constrainHeightGreaterThanOrEqualTo(constant: 30)
        }

        override func configureColors() {
            super.configureColors()
            tagImageView.tintColor = tagImageViewColor
        }
    }
}

extension CardDetailsView.TagCell {

    struct DataModel: Hashable {
        var tagID: BusinessCardTagID
        var title: String
        var tagColor: UIColor?
    }

    func setDataModel(_ dataModel: DataModel) {
        titleLabel.text = dataModel.title
        tagImageViewColor = dataModel.tagColor
    }
}

// MARK: - TagCell

extension CardDetailsView {

    final class NoTagsCell: AppCollectionViewCell, Reusable {

        let addTagsButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Add Tags", comment: ""), for: .normal)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let image = UIImage(systemName: "tag.fill", withConfiguration: imageConfig)
            this.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            this.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(addTagsButton)
        }

        override func configureConstraints() {
            super.configureConstraints()
            addTagsButton.constrainToEdgesOfSuperview()
            addTagsButton.constrainHeightGreaterThanOrEqualTo(constant: 20)
        }

        override func configureColors() {
            super.configureColors()
            addTagsButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
            addTagsButton.tintColor = Asset.Colors.appAccent.color
        }
    }
}

// MARK: - UpdateAvailableCell

extension CardDetailsView {

    final class UpdateAvailableCell: AppCollectionViewCell, Reusable {

        private let titleLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("Update Available", comment: "")
            this.font = .appDefault(size: 17, weight: .semibold)
            this.textAlignment = .center
            return this
        }()

        private let descriptionLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 13)
            this.text = NSLocalizedString(
                "The user who shared this card with you has issued an update to it. The update might contain changes to the card's appearance as well as changes to the contact information. You can choose to skip this update now and download it at a later time.",
                comment: ""
            )
            this.numberOfLines = 0
            this.lineBreakMode = .byWordWrapping
            this.textAlignment = .center
            return this
        }()

        let updateButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Download Update", comment: ""), for: .normal)
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, updateButton])
            this.spacing = 16
            this.axis = .vertical
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(mainStackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview()
            mainStackView.constrainHeightGreaterThanOrEqualTo(constant: 60)
        }

        override func configureColors() {
            super.configureColors()
            updateButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
            descriptionLabel.textColor = .secondaryLabel
        }
    }
}

// MARK: - DeleteCell

extension CardDetailsView {

    final class DeleteCell: AppCollectionViewCell, Reusable {

        let deleteButton: UIButton = {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            let image = UIImage(systemName: "trash.fill", withConfiguration: imageConfig)?.withRenderingMode(.alwaysTemplate)
            let this = UIButton()
            this.setImage(image, for: .normal)
            return this
        }()

        private let imageContainer: UIView = {
            let this = UIView()
            this.layer.cornerRadius = 12
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            imageContainer.addSubview(deleteButton)
            contentView.addSubview(imageContainer)
        }

        override func configureConstraints() {
            super.configureConstraints()

            deleteButton.constrainToEdgesOfSuperview(inset: 6)

            imageContainer.constrainCenterXToSuperview()
            imageContainer.constrainVerticallyToSuperview()
            imageContainer.constrainWidth(constant: 60)
            imageContainer.constrainHeight(to: imageContainer.widthAnchor)
        }

        override func configureColors() {
            super.configureColors()
            deleteButton.tintColor = Asset.Colors.appAccent.color
            imageContainer.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
        }
    }
}
