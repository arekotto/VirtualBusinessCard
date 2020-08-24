//
//  LanguagesVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol LanguagesTVCDelegate: class {
    func languagesTVC(_ viewController: LanguagesTVC, didFinishWith localeID: String?)
}

final class LanguagesTVC: AppTableViewController<LanguagesVM> {

    private typealias DataSource = UITableViewDiffableDataSource<LanguagesVM.Section, LanguagesView.TableCell.DataModel>

    weak var delegate: LanguagesTVCDelegate?

    var mode: LanguagesVM.Mode { viewModel.mode }

    private lazy var tableViewDataSource = makeTableViewDataSource()

    init(viewModel: LanguagesVM) {
        super.init(viewModel: viewModel, style: .insetGrouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupTableView()
        setupNavigationItem()
        viewModel.delegate = self
        viewModel.loadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectRow(at: indexPath)
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func setupTableView() {
        tableView.dataSource = tableViewDataSource
        tableView.separatorInset = UIEdgeInsets(vertical: 0, horizontal: 16)
        tableView.registerReusableCell(LanguagesView.TableCell.self)
        tableView.backgroundColor = Asset.Colors.appBackground.color
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.keyboardDismissMode = .onDrag
    }

    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = NSLocalizedString("Choose Language", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.doneButtonTitle, style: .done, target: self, action: #selector(didTapDoneEditingButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem.cancel(target: self, action: #selector(didTapCancelEditingButton))
        navigationItem.searchController = {
            let controller = UISearchController()
            controller.searchResultsUpdater = self
            controller.delegate = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            return controller
        }()
    }

    private func makeTableViewDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, dataModel in
            let cell: LanguagesView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        }
    }
}

// MARK: - Actions

@objc
private extension LanguagesTVC {
    func didTapDoneEditingButton() {
        if navigationItem.searchController?.isActive == true {
            navigationItem.searchController?.isActive = false
        }
        dismiss(animated: true) { [self] in
            delegate?.languagesTVC(self, didFinishWith: viewModel.newSelectedLanguageCode)
        }
    }

    func didTapCancelEditingButton() {
        if navigationItem.searchController?.isActive == true {
            navigationItem.searchController?.isActive = false
        }
        dismiss(animated: true) { [self] in
            delegate?.languagesTVC(self, didFinishWith: nil)
        }
    }
}

// MARK: - UISearchResultsUpdating, UISearchControllerDelegate

extension LanguagesTVC: UISearchResultsUpdating, UISearchControllerDelegate {

    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.search(for: "")
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(for: searchController.searchBar.text ?? "")
    }
}

// MARK: - LanguagesVMDelegate

extension LanguagesTVC: LanguagesVMDelegate {
    func viewModelDidLoadData() {
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
    }

    func viewModelDidRefreshData() {
        tableViewDataSource.apply(viewModel.dataSnapshot())
    }
}
