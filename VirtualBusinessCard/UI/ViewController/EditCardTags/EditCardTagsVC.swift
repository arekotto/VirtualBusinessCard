//
//  EditCardTagsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardTagsVC: AppViewController<EditCardTagsView, EditCardTagsVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        viewModel.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        viewModel.fetchData()
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: #selector(didTapDoneButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: #selector(didTapCancelButton))
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension EditCardTagsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.dataModel = viewModel.itemForRow(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Actions

@objc
private extension EditCardTagsVC {
    func didTapDoneButton() {
        viewModel.didApproveSelection()
    }

    func didTapCancelButton() {
        viewModel.didDiscardSelection()
    }
}

// MARK: - EditCardTagsVMDelegate

extension EditCardTagsVC: EditCardTagsVMDelegate {
    func refreshRowAnimated(at indexPath: IndexPath) {
        contentView.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func refreshData() {
        contentView.tableView.reloadData()
    }

    func dismiss() {
        dismiss(animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension EditCardTagsVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        viewModel.isAllowedDragToDismiss
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        viewModel.didAttemptDismiss()
    }
}
