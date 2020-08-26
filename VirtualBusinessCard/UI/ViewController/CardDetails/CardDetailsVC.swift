//
//  CardDetailsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import MessageUI
import CoreMotion
import Kingfisher

final class CardDetailsVC: AppViewController<CardDetailsView, CardDetailsVM> {

    private(set) var mostRecentCardImagesCellSnapshot: UIView?

    private typealias DataSource = UICollectionViewDiffableDataSource<CardDetailsVM.SectionType, CardDetailsVM.Item>

    private lazy var downloadUpdatesButton = UIBarButtonItem(image: viewModel.downloadUpdatesButtonImage, style: .plain, target: self, action: #selector(didTapDownloadUpdatesButton))

    private lazy var collectionViewDataSource = makeDataSource()

    private var engine: HapticFeedbackEngine?

    private var hasCompletedAppearanceAnimation = SingleTimeToggleBool(ofInitialValue: false)
    private var hasAppeared = SingleTimeToggleBool(ofInitialValue: false)

    func cardImagesCellFrame(translatedTo targetView: UIView) -> CGRect? {
        let indexPathsForVisibleItems = contentView.collectionView.indexPathsForVisibleItems
        if !indexPathsForVisibleItems.contains(cardCellIndexPath) && !indexPathsForVisibleItems.isEmpty {
            return hiddenCardCellFrame()
        }
        guard let cell = cardImagesCell() else { return nil }
        return cell.contentView.convert(cell.contentView.bounds, to: targetView)
    }
    
    func estimatedCardImagesCellFrame() -> CGRect {
        let topInset = (navigationController?.navigationBar.frame.height ?? 0) + (contentView.statusBarHeight ?? 0)
        let origin = CGPoint(x: 0, y: CardDetailsView.contentInsetTop + topInset)
        return CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width, height: ReceivedCardsView.CollectionCell.defaultHeight))
    }
    
    func setCardImagesSectionHidden(_ isHidden: Bool) {
        cardImagesCell()?.contentView.isHidden = isHidden
    }

    private var cardCellIndexPath: IndexPath {
        IndexPath(item: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = collectionViewDataSource
        viewModel.delegate = self
        viewModel.fetchData()
        engine = HapticFeedbackEngine(sharpness: viewModel.hapticSharpness, intensity: 1)
        contentView.collectionView.setCollectionViewLayout(makeCollectionViewLayout(), animated: hasCompletedAppearanceAnimation.value)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared.toggle()
        cardImagesCell()?.extend(animated: true) {
            self.hasCompletedAppearanceAnimation.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.engine?.play()
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView = contentView.titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapCloseButton))

        downloadUpdatesButton.isEnabled = false
    }
    
    private func cardImagesCell() -> CardDetailsView.CardImagesCell? {
        contentView.collectionView.cellForItem(at: cardCellIndexPath) as? CardDetailsView.CardImagesCell
    }

    private func hiddenCardCellFrame() -> CGRect {
        let height = ReceivedCardsView.CollectionCell.defaultHeight
        let origin = CGPoint(x: 0, y: -height)
        return CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width, height: height))
    }

    private func makeDataSource() -> DataSource {
        let source = DataSource(collectionView: contentView.collectionView) { [weak self] collectionView, indexPath, item in
            switch item.dataModel {
            case .dataCell(let dataModel):
                let cell: TitleValueCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.setDataModel(dataModel)
                return cell
            case .cardImagesCell(let dataModel):
                let cell: CardDetailsView.CardImagesCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.dataModel = dataModel
                cell.contentView.isHidden = !(self?.hasAppeared.value ?? false)
                if !cell.isExtended && self?.hasCompletedAppearanceAnimation.value == true {
                    cell.layoutIfNeeded()
                }
                return cell
            case .dataCellImage(let dataModel):
                let cell: TitleValueImageCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.setDataModel(dataModel)
                return cell
            case .tagCell(let dataModel):
                let cell: CardDetailsView.TagCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.setDataModel(dataModel)
                return cell
            case .noTagsCell:
                let cell: CardDetailsView.NoTagsCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.addTagsButton.addTarget(self, action: #selector(self?.didTapTagsButton), for: .touchUpInside)
                return cell
            case .updateCell:
                let cell: CardDetailsView.UpdateAvailableCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.updateButton.addTarget(self, action: #selector(self?.didTapDownloadUpdatesButton), for: .touchUpInside)
                return cell
            case .deleteCell:
                let cell: CardDetailsView.DeleteCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.deleteButton.addTarget(self, action: #selector(self?.didTapDeleteButton), for: .touchUpInside)
                return cell
            }
        }
        source.supplementaryViewProvider = { collectionView, kind, indexPath in
            let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
            switch UserProfileView.SupplementaryElementKind(rawValue: kind)! {
            case .header: cell.configureRoundedCorners(mode: .top)
            case .footer: cell.configureRoundedCorners(mode: .bottom)
            }
            return cell
        }
        return source
    }

    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let sections = self?.collectionViewDataSource.snapshot().sectionIdentifiers else { return nil }
            switch sections[sectionIndex] {
            case .card: return CardDetailsView.createCollectionViewLayoutCardImagesSection()
            case .tags, .delete: return CardDetailsView.createCollectionViewLayoutDynamicSection()
            case .update: return CardDetailsView.createCollectionViewLayoutUpdateSection()
            default: return CardDetailsView.createCollectionViewLayoutDetailsSection()
            }
        }
    }

    private func prepareMockCardCell() -> UIView {
        let cell = CardDetailsView.CardImagesCell()
        if let motionData = viewModel.mostRecentMotionData {
            cell.updateMotionData(motionData, over: 0)
        }
        let dataModel = collectionViewDataSource.snapshot().itemIdentifiers(inSection: .card).first!.dataModel
        switch dataModel {
        case .cardImagesCell(let urlDataModel): cell.dataModel = urlDataModel
        default: break
        }
        return cell
    }
}

// MARK: - Actions

@objc
private extension CardDetailsVC {

    func didTapTagsButton() {
        presentEditCardTagsVC()
    }

    func didTapDeleteButton() {
        let title = NSLocalizedString("Delete Card", comment: "")
        let message = NSLocalizedString("Are you sure you want to delete this card from your collection? This cannot be undone.", comment: "")
        let alert = AppAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Card", comment: ""), style: .destructive) { _ in
            self.viewModel.deleteCard()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }

    func didTapDownloadUpdatesButton() {
        let title = NSLocalizedString("Update Card", comment: "")
        let message = NSLocalizedString(
            "Update this card to its newest version. The current version will be overwritten. Your notes and tags associated with the card will not be affected.",
            comment: ""
        )
        let alert = AppAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Update Card", comment: ""), style: .default) { _ in
            self.viewModel.saveLocalizationUpdates()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }

    func didTapCloseButton() {
        engine = HapticFeedbackEngine(sharpness: viewModel.hapticSharpness, intensity: 1)
        guard let cell = cardImagesCell() else {
            self.mostRecentCardImagesCellSnapshot = prepareMockCardCell()
            engine?.play()
            dismiss(animated: true)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.engine?.play()
        }
        cell.condenseWithAnimation {
            self.mostRecentCardImagesCellSnapshot = cell.snapshotView(afterScreenUpdates: false)
            self.dismiss(animated: true)
        }
    }
}

// MARK: - AlertController

private extension CardDetailsVC {

    func displayAlertController(with actions: [CardDetailsVM.Action], for indexPath: IndexPath) {
        guard !actions.isEmpty else { return }
        let alert = AppAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                self.viewModel.didSelect(action: action, at: indexPath)
            }
            alertAction.setValue(CardDetailsVM.iconImage(for: action), forKey: "image")
            alert.addAction(alertAction)
        }
        alert.addCancelAction()
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension CardDetailsVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CardDetailsView.CardImagesCell else { return }
        if hasCompletedAppearanceAnimation.value {
            cell.extend(animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        displayAlertController(with: viewModel.actions(for: indexPath), for: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTopInset = view.safeAreaInsets.top
        if scrollView.contentOffset.y > ReceivedCardsView.CollectionCell.defaultHeight + CardDetailsView.contentInsetTop - safeAreaTopInset {
            guard !contentView.titleView.isVisible else { return }
            contentView.titleView.animateSlideIn()
        } else {
            guard contentView.titleView.isVisible else { return }
            contentView.titleView.animateSlideOut()
        }
    }
}

// MARK: - CardDetailsVMDelegate

extension CardDetailsVC: CardDetailsVMDelegate {

    func dismissSelfWithSystemAnimation() {
        navigationController?.transitioningDelegate = nil
        dismiss(animated: true)
    }

    func presentErrorAlert(message: String) {
        super.presentErrorAlert(message: message)
    }

    func presentEditCardTagsVC() {
        guard let viewModel = viewModel.editCardTagsVM() else { return }
        let vc = EditCardTagsVC(viewModel: viewModel)
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.presentationController?.delegate = vc
        present(navVC, animated: true)
    }

    func presentEditCardNotesVC(viewModel: EditCardNotesVM) {
        let vc = EditCardNotesVC(viewModel: viewModel)
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.presentationController?.delegate = vc
        present(navVC, animated: true)
    }
    
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        cardImagesCell()?.updateMotionData(motion, over: timeFrame)
    }
    
    func presentSendEmailViewController(recipient: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([recipient])
        present(mailComposeVC, animated: true)
    }
    
    func reloadData() {
        contentView.titleView.setImageURL(viewModel.titleImageURL)
        contentView.titleView.cardCornerRadiusHeightMultiplier = viewModel.cardCornerRadiusHeightMultiplier
        collectionViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: hasCompletedAppearanceAnimation.value)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension CardDetailsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
