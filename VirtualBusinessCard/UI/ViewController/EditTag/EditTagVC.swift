//
//  EditTagVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditTagVC: AppViewController<EditTagView, EditTagVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupCollectionView()
        setupContentView()
        contentView.setTagColor(viewModel.selectedColor)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: #selector(didTapDoneEditingButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: #selector(didTapCancelEditingButton))
    }
}

// MARK: - Actions

@objc
private extension EditTagVC {
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

extension EditTagVC: NewTagVMDelegate {
    func presentDeleteAlert() {
        let title = NSLocalizedString("Delete Tag", comment: "")

        let message = NSLocalizedString("Are you sure you want to delete this tag?", comment: "")
        let alert = AppAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Tag", style: .destructive) { _ in
            self.viewModel.didConfirmDelete()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }

    func presentErrorAlert(message: String) {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                super.presentErrorAlert(message: message)
            }
        } else {
            super.presentErrorAlert(message: message)
        }
    }

    func presentErrorAlert(title: String?, message: String) {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                super.presentErrorAlert(title: title, message: message)
            }
        } else {
            super.presentErrorAlert(title: title, message: message)
        }
    }
    
    func dismissSelf() {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    func applyNewTagColor(_ color: UIColor) {
        contentView.setTagColor(color, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension EditTagVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditTagView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.color = viewModel.itemForCell(at: indexPath)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - UITextFieldDelegate

extension EditTagVC: UITextFieldDelegate {
    
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

extension EditTagVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        viewModel.isAllowedDragToDismiss
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        viewModel.didAttemptDismiss()
    }
}
