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

    private var engine: HapticFeedbackEngine!
    
    func imageCellFrame(translatedTo targetView: UIView) -> CGRect? {
        guard let cell = cardImagesCell() else { return nil }
        return cell.contentView.convert(cell.contentView.bounds, to: targetView)
    }
    
    func estimatedImageCellFrame(estimatedTopSafeAreaInset: CGFloat) -> CGRect {
        let origin = CGPoint(x: 0, y: CardDetailsView.contentInsetTop + estimatedTopSafeAreaInset)
        return CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width, height: ReceivedCardsView.CollectionCell.defaultHeight))
    }
    
    func setImageSectionHidden(_ isHidden: Bool) {
        cardImagesCell()?.cardFrontBackView.isHidden = isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        viewModel.delegate = self
        viewModel.fetchData()
        engine = HapticFeedbackEngine(sharpness: viewModel.hapticSharpness, intensity: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardImagesCell()?.extendWithAnimation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.engine.play()
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView = contentView.titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapCloseButton))
    }
    
    private func cardImagesCell() -> CardDetailsView.CardImagesCell? {
        contentView.collectionView.cellForItem(at: IndexPath(item: 0)) as? CardDetailsView.CardImagesCell
    }
}

// MARK: - Actions

@objc
private extension CardDetailsVC {
    func didTapCloseButton() {
        viewModel.didTapCloseButton()
    }
}

// MARK: - AlertController

private extension CardDetailsVC {
    func displayAlertController(with actions: [CardDetailsVM.Action], for indexPath: IndexPath) {
        guard !actions.isEmpty else { return }
        let alert = UIAlertController.accentTinted(title: nil, message: nil, preferredStyle: .actionSheet)
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension CardDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOrSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.item(at: indexPath).dataModel {
        case .dataCell(let dataModel):
            let cell: TitleValueCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        case .cardImagesCell(let dataModel):
            let cell: CardDetailsView.CardImagesCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.cardFrontBackView.setDataModel(dataModel)
            return cell
        case .dataCellImage(let dataModel):
            let cell: TitleValueImageCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
        switch UserProfileView.SupplementaryElementKind(rawValue: kind)! {
        case .header: cell.configureRoundedCorners(mode: .top)
        case .footer: cell.configureRoundedCorners(mode: .bottom)
        }
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        displayAlertController(with: viewModel.item(at: indexPath).actions, for: indexPath)
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
    func presentErrorAlert(message: String) {
        super.presentErrorAlert(message: message)
    }

    func presentEditCardTagsVC(viewModel: EditCardTagsVM) {
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

    func dismissSelf() {
        guard let cell = cardImagesCell() else {
            dismiss(animated: false)
            return
        }
        cell.condenseWithAnimation() {
            self.dismiss(animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.engine.play()
        }
    }
    
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        cardImagesCell()?.cardFrontBackView.updateMotionData(motion, over: timeFrame)
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
        contentView.collectionView.reloadData()
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension CardDetailsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
