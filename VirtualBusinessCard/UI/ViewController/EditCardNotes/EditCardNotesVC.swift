//
//  EditCardNotesVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardNotesVC: AppViewController<EditCardNotesView, EditCardNotesVM> {

    private lazy var doneEditingButton = UIBarButtonItem(title: viewModel.doneEditingButtonTitle, style: .done, target: self, action: #selector(didTapDoneButton))
    private lazy var cancelEditingButton = UIBarButtonItem(title: viewModel.cancelEditingButtonTitle, style: .plain, target: self, action: #selector(didTapCancelButton))

    private var notesCell: EditCardNotesView.TextCollectionCell? {
        contentView.tableView.visibleCells.first as? EditCardNotesView.TextCollectionCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        viewModel.delegate = self
        contentView.tableView.dataSource = self
        let keyboardHideNotification = UIResponder.keyboardWillHideNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: keyboardHideNotification, object: nil)
        let keyboardChangeFrameNotification = UIResponder.keyboardDidChangeFrameNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: keyboardChangeFrameNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notesCell?.becomeFirstResponder()
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.leftBarButtonItem = cancelEditingButton
    }
}

// MARK: - UITableViewDataSource

extension EditCardNotesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditCardNotesView.TextCollectionCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.notesTextView.text = viewModel.notes
        cell.notesTextView.delegate = self
        return cell
    }
}

// MARK: - EditCardNotesVMDelegate

extension EditCardNotesVC: EditCardNotesVMDelegate {
    func dismissSelf() {
        dismiss(animated: true)
    }
}

extension EditCardNotesVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.notes = textView.text
        contentView.tableView.beginUpdates()
        contentView.tableView.endUpdates()
    }
}

// MARK: - Actions

@objc
private extension EditCardNotesVC {

    func keyboardWillHide(_ notification: Notification) {
        contentView.tableView.contentInset = EditCardNotesView.defaultTableViewContentInsets
    }

    func keyboardDidChangeFrame(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var newInsets = EditCardNotesView.defaultTableViewContentInsets
            newInsets.bottom = keyboardHeight
            contentView.tableView.contentInset = newInsets
        }
    }

    func didTapDoneButton() {
        viewModel.didApproveEdit()
    }

    func didTapCancelButton() {
        viewModel.didDiscardEdit()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension EditCardNotesVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        viewModel.isAllowedDragToDismiss
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        viewModel.didAttemptDismiss()
    }
}
