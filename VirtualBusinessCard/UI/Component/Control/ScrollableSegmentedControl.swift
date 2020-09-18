//
//  ScrollableSegmentedControl.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class ScrollableSegmentedControl: AppControl {

    weak var delegate: ScrollableSegmentedControlDelegate?
    
    let staticHeight: CGFloat?
    
    var selectedIndex: Int? {
        mainComponent.selectedIndex
    }
    
    var items: [String] {
        get { mainComponent.items }
        set { mainComponent.items = newValue }
    }
    
    private let mainComponent = MainComponent()
    
    internal init(staticHeight: CGFloat? = nil) {
        self.staticHeight = staticHeight
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        staticHeight = nil
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        mainComponent.onSelection = { [unowned self] index in
            self.delegate?.scrollableSegmentedControl(self, didSelectItemAt: index)
        }
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(mainComponent)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        mainComponent.constrainToSuperview()
        if let height = self.staticHeight {
            mainComponent.constrainHeight(constant: height)
        }
    }

    func setInsets(sideInsets: CGFloat, bottomInset: CGFloat) {
        mainComponent.updateInsets(sideInsets: sideInsets, bottomInset: bottomInset)
    }
}

extension ScrollableSegmentedControl {
    
    private final class MainComponent: AppControl, UICollectionViewDataSource, UICollectionViewDelegate {
                
        private static func collectionViewLayout(sideInset: CGFloat, bottomInset: CGFloat) -> UICollectionViewLayout {

            let widthDimension = NSCollectionLayoutDimension.estimated(100)

            let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
            let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: sideInset, bottom: 4 + bottomInset, trailing: sideInset)
            section.orthogonalScrollingBehavior = .continuous
            return UICollectionViewCompositionalLayout(section: section)
        }
        
        var items = [String]() {
            didSet { didSetItems() }
        }
        
        var onSelection: ((Int) -> Void)?

        var selectedIndex: Int? {
            selectedIndexPath?.item
        }
        
        private var hasPerformedInitialLayout = SingleTimeToggleBool(ofInitialValue: false)

        private var selectionIndicatorConstraints = [NSLayoutConstraint]()
        
        private let selectionIndicator: UIView = {
            let this = UIView()
            this.layer.cornerRadius = 14
            this.clipsToBounds = true
            return this
        }()
        
        private lazy var collectionView: UICollectionView = {
            let this = UICollectionView(frame: .zero, collectionViewLayout: Self.collectionViewLayout(sideInset: 0, bottomInset: 8))
            this.registerReusableCell(CollectionCell.self)
            this.dataSource = self
            this.delegate = self
            this.backgroundColor = nil
            this.showsVerticalScrollIndicator = false
            this.showsHorizontalScrollIndicator = false
            return this
        }()
        
        private var selectedIndexPath: IndexPath? {
            collectionView.indexPathsForSelectedItems?.first
        }

        override func configureView() {
            clipsToBounds = true
        }

        override func configureSubviews() {
            super.configureSubviews()
            [selectionIndicator, collectionView].forEach { addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            collectionView.constrainToEdgesOfSuperview()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            selectionIndicator.backgroundColor = Asset.Colors.scrollableSegmentedControlSelectionBackground.color
            hasPerformedInitialLayout.toggle()
            if !items.isEmpty && (collectionView.indexPathsForSelectedItems ?? []).isEmpty {
                collectionView.selectItem(at: IndexPath(item: 0), animated: false, scrollPosition: .left)
            }
        }

        func updateInsets(sideInsets: CGFloat, bottomInset: CGFloat) {
            collectionView.setCollectionViewLayout(Self.collectionViewLayout(sideInset: sideInsets, bottomInset: bottomInset), animated: false)
        }
        
        // MARK: UICollectionViewDataSource, UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell: CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.title = items[indexPath.item]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard collectionView.indexPathsForSelectedItems?.contains(indexPath) == true else { return }
            moveSelectionIndicator(to: cell)
        }

        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard collectionView.indexPathsForSelectedItems?.contains(indexPath) == true else { return }
            selectionIndicator.isHidden = true
        }
            
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            let cellFrame = cell.convert(cell.contentView.bounds, to: collectionView)
            if cellFrame.maxX > collectionView.frame.maxX {
                collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            } else if cellFrame.minX < collectionView.frame.minX {
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
            moveSelectionIndicator(to: cell, animated: true)
            onSelection?(indexPath.item)
        }
        
        // MARK: Private Methods
        
        private func didSetItems() {
            collectionView.reloadData()
            if items.isEmpty, let selectedIndexPath = selectedIndexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: false)
                selectionIndicator.isHidden = true
            } else if hasPerformedInitialLayout.value {
                collectionView.selectItem(at: IndexPath(item: 0), animated: false, scrollPosition: .left)
            }
        }
        
        private func moveSelectionIndicator(to selectedCell: UICollectionViewCell, animated: Bool = false) {
            NSLayoutConstraint.deactivate(selectionIndicatorConstraints)
            selectionIndicator.isHidden = false

            selectionIndicatorConstraints = [
                selectionIndicator.constrainTop(to: selectedCell.contentView.topAnchor),
                selectionIndicator.constrainLeading(to: selectedCell.contentView.leadingAnchor),
                selectionIndicator.constrainTrailing(to: selectedCell.contentView.trailingAnchor),
                selectionIndicator.constrainBottom(to: selectedCell.contentView.bottomAnchor)
            ]
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.layoutIfNeeded()
                })
            } else {
                layoutIfNeeded()
            }
        }
    }
}

extension ScrollableSegmentedControl {
    
    private final class CollectionCell: AppCollectionViewCell, Reusable {
        
        var title: String? {
            get { titleLabel.text }
            set { titleLabel.text = newValue }
        }
        
        let titleLabel: UILabel = {
            let this = UILabel()
            this.textAlignment = .center
            this.font = .appDefault(size: 15, weight: .medium, design: .rounded)
            return this
        }()
        
        override var isSelected: Bool {
            get { super.isSelected }
            set {
                super.isSelected = newValue
                updateTitleTextColor()
            }
        }
        
        override func configureCell() {
            super.configureCell()
            backgroundColor = nil
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            [titleLabel].forEach { contentView.addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            titleLabel.constrainToSuperview(topInset: 10, leadingInset: 12, bottomInset: 10, trailingInset: 12)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateTitleTextColor()
        }
        
        private func updateTitleTextColor() {
            if isSelected {
                titleLabel.textColor = Asset.Colors.scrollableSegmentedControlSelectionText.color
            } else {
                titleLabel.textColor = .systemGray
            }
        }
    }
}

struct SingleTimeToggleBool {
    private(set) var value = false

    private var hasPerformedToggle = false

    init(ofInitialValue value: Bool) {
        self.value = value
    }
    
    mutating func toggle() {
        guard !hasPerformedToggle else { return }
        hasPerformedToggle = true
        value.toggle()
    }
}
