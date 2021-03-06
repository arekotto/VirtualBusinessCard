//
//  TagsViewController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TagsVC: AppViewController<TagsView, TagsVM> {

    private lazy var nonEditingButtons = [
        UIBarButtonItem.add(target: self, action: #selector(didTapNewTagButton)),
        UIBarButtonItem(image: viewModel.sortControlImage, style: .plain, target: self, action: #selector(didTapSortButton))
    ]

    private lazy var doneButton = UIBarButtonItem.done(target: self, action: #selector(didTapDoneButton))
    private lazy var doneEditingButton = UIBarButtonItem.done(target: self, action: #selector(didTapDoneEditingButton))
    private lazy var cancelEditingButton = UIBarButtonItem.cancel(target: self, action: #selector(didTapCancelEditingButton))

    private lazy var tableViewDataSource = makeTableViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        viewModel.delegate = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = tableViewDataSource
        viewModel.fetchData()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.setRightBarButtonItems(nonEditingButtons, animated: false)
        navigationItem.setLeftBarButton(doneButton, animated: false)
    }

    private func makeTableViewDataSource() -> DataSource {
        let dataSource = DataSource(tableView: contentView.tableView) { tableView, indexPath, dataModel in
            let cell: TagTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.dataModel = dataModel
            return cell
        }
        dataSource.viewModel = viewModel
        return dataSource
    }
}

// MARK: - UITableViewDelegate

extension TagsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

// MARK: - Actions

@objc
private extension TagsVC {
    func didTapNewTagButton() {
        viewModel.didSelectNewTag()
    }

    func didTapDoneButton() {
        dismiss(animated: true)
    }
    
    func didTapSortButton() {
        contentView.tableView.setEditing(true, animated: true)
        navigationItem.setRightBarButtonItems([doneEditingButton], animated: true)
        navigationItem.setLeftBarButtonItems([cancelEditingButton], animated: true)
    }
    
    func didTapDoneEditingButton() {
        contentView.tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(nonEditingButtons, animated: true)
        navigationItem.setLeftBarButtonItems([doneButton], animated: true)
        viewModel.didApproveEditing()
    }
    
    func didTapCancelEditingButton() {
        contentView.tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(nonEditingButtons, animated: true)
        navigationItem.setLeftBarButtonItems([doneButton], animated: true)
        viewModel.didCancelEditing()
    }
}

// MARK: - TagsVMDelegate
    
extension TagsVC: TagsVMDelegate {
    func presentNewTagVC(with viewModel: EditTagVM) {
        let navVC = EditTagNC(editTagVM: viewModel)
        navVC.presentationController?.delegate = navVC.rootViewController
        present(navVC, animated: true)
    }
    
    func refreshData() {
        contentView.emptyStateView.isHidden = !viewModel.showsEmptyState
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
    }
}

// MARK: - DataSource

extension TagsVC {
    final class DataSource: UITableViewDiffableDataSource<TagsVM.Section, TagTableCell.DataModel> {

        weak var viewModel: TagsVM?

        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }

        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            viewModel?.didMoveItem(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
}
