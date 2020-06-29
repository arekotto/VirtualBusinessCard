//
//  UserProfileVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 28/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class UserProfileVC: AppViewController<UserProfileView, UserProfileVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        setupNavigationItem()
        viewModel.fetchData()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(testingAdd))
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    @objc func testingAdd() {
        let task = SampleBCUploadTask()
        task() {_ in }
    }
}

extension UserProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOrSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {       
        switch viewModel.rowType(at: indexPath) {
        case .item:
            let cell: UserProfileView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(viewModel.itemForRow(at: indexPath))
            return cell
        case .sectionOpening:
            let cell: RoundedInsetTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.configureRoundedCorners(mode: .top)
            return cell
        case .sectionClosing:
            let cell: RoundedInsetTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.configureRoundedCorners(mode: .bottom)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UserProfileView.TableHeader = tableView.dequeueReusableHeaderFooterView()
        header.title = viewModel.title(for: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.rowType(at: indexPath) {
        case .sectionOpening: return 12
        case .sectionClosing: return 12
        case .item: return 70
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserProfileVC: UserProfileVMDelegate {
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController.withTint(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    func presentAlertWithTextField(title: String?, message: String?, for row: UserProfileVM.Row) {
        let alert = UIAlertController.withTint(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = title
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            self.viewModel.didSetNewValue(alert.textFields?.first?.text ?? "", for: row)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    func reloadData() {
        contentView.tableView.reloadData()
    }
    
    
}
