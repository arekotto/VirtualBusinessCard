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

    private var testDataCounter = 0

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testDataCounter = 0
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Test Data", style: .plain, target: self, action: #selector(showTestDataAlert))
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

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let button = UIButton()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        button.setTitle("Version \(appVersion)", for: .normal)
        button.setTitleColor(Asset.Colors.defaultText.color, for: .normal)
        button.titleLabel?.font = .appDefault(size: 15)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(didTapVersionButton), for: .touchUpInside)
        return button
    }
}

// MARK: - Actions

@objc
private extension SettingsVC {

    func showTestDataAlert() {
        //        let task = SampleBCUploadTask()
        //        task {_ in }

        let alert = AppAlertController(title: "User Testing", message: "", preferredStyle: .actionSheet)

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

    func didTapVersionButton() {
        testDataCounter += 1
        if testDataCounter == 9 {
            showTestDataAlert()
        }
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
