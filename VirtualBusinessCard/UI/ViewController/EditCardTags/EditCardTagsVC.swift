//
//  EditCardTagsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardTagsVC: AppViewController<EditCardTagsView, EditCardTagsVM> {

    private typealias DataSource = UITableViewDiffableDataSource<EditCardTagsVM.Section, EditCardTagsVM.DataModel>

    private lazy var tableViewDataSource = makeTableViewDataSource()

    private var hasAppearedAtLeastOnce = SingleTimeToggleBool(ofInitialValue: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        viewModel.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = tableViewDataSource
        viewModel.fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppearedAtLeastOnce.toggle()
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem.done(target: self, action: #selector(didTapDoneButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: #selector(didTapCancelButton))
        navigationController?.setToolbarHidden(false, animated: false)
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.add(target: self, action: #selector(didTapAddButton)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
    }

    private func makeTableViewDataSource() -> DataSource {
        let dataSource = DataSource(tableView: contentView.tableView) { tableView, indexPath, dataModel in
            let cell: TagTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.dataModel = dataModel
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension EditCardTagsVC: UITableViewDelegate {

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

    func didTapAddButton() {
        let editTagVC = EditTagVC(viewModel: viewModel.editTagVM())
        let navVC = AppNavigationController(rootViewController: editTagVC)
        navVC.presentationController?.delegate = editTagVC
        present(navVC, animated: true)
    }
}

// MARK: - EditCardTagsVMDelegate

extension EditCardTagsVC: EditCardTagsVMDelegate {
    func refreshData() {
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: hasAppearedAtLeastOnce.value)
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
