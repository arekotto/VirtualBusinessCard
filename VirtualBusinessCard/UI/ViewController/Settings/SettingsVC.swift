//
//  SettingsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class SettingsVC: AppViewController<SettingsView, SettingsVM> {

    private typealias DataSource = UITableViewDiffableDataSource<SettingsVM.Section, SettingsVM.Row>

    private lazy var tableViewDataSource = makeTableViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        hidesBottomBarWhenPushed = true
        viewModel.delegate = self
        contentView.tableView.dataSource = tableViewDataSource
        contentView.tableView.delegate = self
        setupNavigationItem()
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Test Data", style: .plain, target: self, action: #selector(testingAdd))
    }
    
    @objc
    func testingAdd() {
//        let task = SampleBCUploadTask()
//        task {_ in }

        let alert = AppAlertController(title: "Test", message: "", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Task 1", style: .default) { _ in
            UserTestingManager.task1()
        })

        alert.addAction(UIAlertAction(title: "Task 3", style: .default) { _ in
            UserTestingManager.task3()
        })

        alert.addAction(UIAlertAction(title: "Task 4", style: .default) { _ in
            UserTestingManager.task4()
        })

        alert.addAction(UIAlertAction(title: "Task 5.1", style: .default) { _ in
            UserTestingManager.task51()
        })

        alert.addAction(UIAlertAction(title: "Task 5.2", style: .default) { _ in
            UserTestingManager.task52()
        })

        alert.addAction(UIAlertAction(title: "Task 6", style: .default) { _ in
            UserTestingManager.task6()
        })

        alert.addCancelAction()

        present(alert, animated: true)
    }

    private func makeTableViewDataSource() -> DataSource {
        DataSource(tableView: contentView.tableView) { tableView, indexPath, row in
            let cell: TitleTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.dataModel = row.dataModel
            return cell
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsVC: UITableViewDelegate {
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
