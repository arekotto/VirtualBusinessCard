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
        UIBarButtonItem(image: viewModel.newTagImage, style: .plain, target: self, action: #selector(didTapNewTagButton)),
        UIBarButtonItem(image: viewModel.sortControlImage, style: .plain, target: self, action: #selector(didTapSortButton))
    ]
    
    private lazy var doneEditingButton = UIBarButtonItem(title: viewModel.doneEditingButtonTitle, style: .done, target: self, action: #selector(didTapDoneEditingButton))
    private lazy var cancelEditingButton = UIBarButtonItem(title: viewModel.cancelEditingButtonTitle, style: .plain, target: self, action: #selector(didTapCancelEditingButton))

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
        navigationItem.rightBarButtonItems = nonEditingButtons
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TagsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagsView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.dataModel = viewModel.itemForRow(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // TODO: add styling here
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.didMoveItem(from: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
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
    
    func didTapSortButton() {
        contentView.tableView.setEditing(true, animated: true)
        navigationItem.setRightBarButtonItems([doneEditingButton], animated: true)
        navigationItem.setLeftBarButtonItems([cancelEditingButton], animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func didTapDoneEditingButton() {
        contentView.tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(nonEditingButtons, animated: true)
        navigationItem.setLeftBarButtonItems([], animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
        viewModel.didApproveEditing()
    }
    
    func didTapCancelEditingButton() {
        contentView.tableView.setEditing(false, animated: true)
        navigationItem.setRightBarButtonItems(nonEditingButtons, animated: true)
        navigationItem.setLeftBarButtonItems([], animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
        viewModel.didCancelEditing()
    }
}

// MARK: - TagsVMDelegate
    
extension TagsVC: TagsVMDelegate {
    func presentNewTagVC(with viewModel: EditTagVM) {
        let editTagVC = EditTagVC(viewModel: viewModel)
        let navVC = AppNavigationController(rootViewController: editTagVC)
        navVC.presentationController?.delegate = editTagVC
        present(navVC, animated: true)
    }
    
    func refreshData() {
        contentView.tableView.reloadData()
    }
}
