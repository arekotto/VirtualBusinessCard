//
//  SettingsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class SettingsVC: AppViewController<SettingsView, SettingsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        hidesBottomBarWhenPushed = true
        viewModel.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Test Data", style: .plain, target: self, action: #selector(testingAdd))
    }
    
    @objc
    func testingAdd() {
        let task = SampleBCUploadTask()
        task() {_ in }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.itemForRow(at: indexPath)
        let cell: TitleTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.dataModel = item.dataModel
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SettingsVMDelegate

extension SettingsVC: SettingsVMDelegate {
    func presentLogoutAlertController(title: String, actionTitle: String) {
        let alert = AppAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in
            self.viewModel.didSelectLogoutAction()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }
    
    func presentUserProfileVC(with viewModel: UserProfileVM) {
        show(UserProfileVC(viewModel: viewModel), sender: nil)
    }
    
    func presentTagsVC(with viewModel: TagsVM) {
        show(TagsVC(viewModel: viewModel), sender: nil)
    }
}
