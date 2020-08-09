//
//  PersonalCardVersionsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class PersonalCardVersionsVC: AppViewController<PersonalCardVersionsView, PersonalCardVersionsVM> {

    private typealias DataSource = UITableViewDiffableDataSource<PersonalCardVersionsVM.Section, PersonalCardVersionsView.TableCell.DataModel>

    private lazy var tableViewDataSource = makeTableViewDataSource()

    private var coordinator: Coordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupNavigationItem()
        extendedLayoutIncludesOpaqueBars = true
        viewModel.delegate = self
        viewModel.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = contentView.tableView.indexPathForSelectedRow {
            contentView.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func setupContentView() {
        contentView.tableView.dataSource = tableViewDataSource
        contentView.tableView.delegate = self
    }

    private func setupNavigationItem() {
        navigationItem.title = NSLocalizedString("Card Localization", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: viewModel.newBusinessCardImage, style: .plain, target: self, action: #selector(didTapNewVersionButton))

    }

    private func makeTableViewDataSource() -> DataSource {
        DataSource(tableView: contentView.tableView) { tableView, indexPath, dataModel in
            let cell: PersonalCardVersionsView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        }
    }

    private func startCoordinator() {
        coordinator?.start { [weak self] result in
            guard let self = self, let navController = self.coordinator?.navigationController else { return }
            switch result {
            case .success:
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            case .failure:
                self.presentErrorAlert()
            }
        }
    }

    private func presentDeleteAlert(with title: String, for indexPath: IndexPath) {
        let alert = AppAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            self.viewModel.deleteLocalization(at: indexPath)
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }
}

// MARK: - Actions

@objc
private extension PersonalCardVersionsVC {
    func didTapNewVersionButton() {
        coordinator = viewModel.newVersionCardCoordinator(root: AppNavigationController())
        startCoordinator()
    }
}

// MARK: - UITableViewDelegate

extension PersonalCardVersionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let config = viewModel.actionConfig(for: indexPath) else { return }

        let alert = AppAlertController(title: config.title, message: nil, preferredStyle: .actionSheet)
        if !config.isDefault {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Make Default", comment: ""), style: .default) { _ in
                // TODO: make default
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Change Localization Language", comment: ""), style: .default) { _ in
            // TODO: change lang
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { [self] _ in
            coordinator = viewModel.editCardCoordinator(for: indexPath, root: AppNavigationController())
            startCoordinator()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            self.presentDeleteAlert(with: config.deleteTitle, for: indexPath)
        })
        alert.addCancelAction { _ in tableView.deselectRow(at: indexPath, animated: true) }
        present(alert, animated: true)
    }
}

// MARK: - PersonalCardVersionsVMDelegate

extension PersonalCardVersionsVC: PersonalCardVersionsVMDelegate {
    func refreshData() {
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
    }
}
