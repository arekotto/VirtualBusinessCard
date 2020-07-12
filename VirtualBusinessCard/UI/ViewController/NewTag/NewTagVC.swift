//
//  NewTagVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Colorful

final class NewTagVC: AppViewController<NewTagView, NewTagVM> {
    
    private lazy var doneEditingButton = UIBarButtonItem(title: viewModel.doneEditingButtonTitle, style: .done, target: self, action: #selector(didTapDoneEditingButton))
    private lazy var cancelEditingButton = UIBarButtonItem(title: viewModel.cancelEditingButtonTitle, style: .plain, target: self, action: #selector(didTapCancelEditingButton))
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupCollectionView()
        setupContentView()
        applyNewTagColor(viewModel.selectedColor)
        viewModel.delegate = self
    }
    
    private func setupCollectionView() {
        contentView.colorsCollectionView.delegate = self
        contentView.colorsCollectionView.dataSource = self
        if let selectedItem = viewModel.selectedItem {
            contentView.colorsCollectionView.selectItem(at: selectedItem, animated: false, scrollPosition: .top)
        }
    }
    
    private func setupContentView() {
        contentView.nameField.text = viewModel.tagName
        contentView.nameField.delegate = self
        if viewModel.allowsDelete {
            contentView.deleteButton.isHidden = false
            contentView.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.leftBarButtonItem = cancelEditingButton
    }
}

// MARK: - Actions

@objc
private extension NewTagVC {
    func didTapDoneEditingButton() {
        contentView.endEditing(true)
        viewModel.didSelectDone()
    }
    
    func didTapCancelEditingButton() {
        contentView.endEditing(true)
        viewModel.didSelectCancel()
    }
    
    func didTapDeleteButton() {
        contentView.endEditing(true)
        viewModel.didSelectDelete()
    }
}

// MARK: - NewTagVMDelegate

extension NewTagVC: NewTagVMDelegate {
    
    func presentDeleteAlert() {
        let title = NSLocalizedString("Delete Tag", comment: "")

        let message = NSLocalizedString("Are you sure you want to delete this tag?", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Tag", style: .destructive) { _ in
            self.viewModel.didConfirmDelete()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }
    
    func presentSaveOfflineAlert() {
        let title = NSLocalizedString("Save Offline", comment: "")
        let message = NSLocalizedString("Your device appears to be disconnected from internet. You can still save the tag offline, and we'll sync it when the connection is restored.", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save Offline", style: .default) { _ in
            self.viewModel.didSelectSaveOffline()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep Editing", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    func presentSaveErrorAlert(title: String) {
        let alert = UIAlertController.accentTinted(title: title, message: nil, preferredStyle: .alert)
        alert.addOkAction()
        present(alert, animated: true)
    }
    
    func presentDismissAlert() {
        let title = NSLocalizedString("Are you sure you want to discard?", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.dismissSelf()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep Editing", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    func dismissSelf() {
        dismiss(animated: true)
    }
    
    func applyNewTagColor(_ color: UIColor) {
        contentView.setTagColor(color, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension NewTagVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NewTagView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.color = viewModel.itemForCell(at: indexPath)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - UITextFieldDelegate

extension NewTagVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString = textField.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.tagName = textField.text ?? ""
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension NewTagVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        viewModel.isAllowedDragToDismiss
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        viewModel.didAttemptDismiss()
    }
}
