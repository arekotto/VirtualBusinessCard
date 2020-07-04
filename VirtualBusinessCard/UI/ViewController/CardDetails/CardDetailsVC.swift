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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        hidesBottomBarWhenPushed = true
//        extendedLayoutIncludesOpaqueBars = true
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardImagesCell()?.extendWithAnimation()
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView = contentView.titleView
    }
    
    private func cardImagesCell() -> CardDetailsView.CardImagesCell? {
        contentView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CardDetailsView.CardImagesCell
    }
}

// MARK: - Actions

private extension CardDetailsVC {
    func displayAlertController(with actions: [CardDetailsVM.Action], for indexPath: IndexPath) {
        guard !actions.isEmpty else { return }
        let controller = UIAlertController.withTint(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                self.viewModel.didSelect(action: action, at: indexPath)
            }
            alertAction.setValue(CardDetailsVM.iconImage(for: action), forKey: "image")
            controller.addAction(alertAction)
        }
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        present(controller, animated: true)
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
        if scrollView.contentOffset.y > CardDetailsView.CardImagesCell.defaultHeight + 16 {
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
