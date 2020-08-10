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
    private var isFirstAppearance = SingleTimeToggleBool(ofInitialValue: true)

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
        contentView.tableView.deselectSelectedRows(animated: true)
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

    private func presentConfirmDeleteAlert(for indexPath: IndexPath) {
        let config = viewModel.confirmDeleteConfig(for: indexPath)
        let alert = AppAlertController(title: config.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: config.deleteActionTitle, style: .destructive) { _ in
            self.viewModel.deleteLocalization(at: indexPath)
        })
        alert.addCancelAction { _ in self.contentView.tableView.deselectRow(at: indexPath, animated: true) }
        present(alert, animated: true)
    }

    private func presentLanguagesVC(viewModel: LanguagesVM) {
        let vc = LanguagesTVC(viewModel: viewModel)
        vc.delegate = self
        present(AppNavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - Actions

@objc
private extension PersonalCardVersionsVC {
    func didTapNewVersionButton() {
        presentLanguagesVC(viewModel: viewModel.newLocalizationLanguageVM())
    }
}

// MARK: - UITableViewDelegate

extension PersonalCardVersionsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let config = viewModel.actionConfig(for: indexPath) else { return }

        let alert = AppAlertController(title: config.title, message: nil, preferredStyle: .actionSheet)
        if !config.isDefault {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Make Default", comment: ""), style: .default) { _ in
                self.viewModel.setDefaultLocalization(at: indexPath)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Change Localization Language", comment: ""), style: .default) { [self] _ in
            guard let vm = viewModel.languagesVM(for: indexPath) else { return }
            presentLanguagesVC(viewModel: vm)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { [self] _ in
            coordinator = viewModel.editCardCoordinator(for: indexPath, root: AppNavigationController())
            startCoordinator()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            self.presentConfirmDeleteAlert(for: indexPath)
        })
        alert.addCancelAction { _ in tableView.deselectRow(at: indexPath, animated: true) }
        present(alert, animated: true)
    }
}

// MARK: - PersonalCardVersionsVMDelegate

extension PersonalCardVersionsVC: PersonalCardVersionsVMDelegate {
    func presentErrorAlert(message: String) {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                super.presentErrorAlert(message: message)
            }
        } else {
            super.presentErrorAlert(message: message)
        }
    }

    func popSelf() {
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func refreshData() {
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: !isFirstAppearance.value)
        isFirstAppearance.toggle()
    }
}

// MARK: - LanguagesTVCDelegate

extension PersonalCardVersionsVC: LanguagesTVCDelegate {
    func languagesTVC(_ viewController: LanguagesTVC, didFinishWith languageCode: String?) {
        contentView.tableView.deselectSelectedRows(animated: true)
        guard let code = languageCode, code != "" else { return }
        switch viewController.mode {
        case .newLocalization:
            coordinator = viewModel.newVersionCardCoordinator(root: AppNavigationController(), forLanguageCode: code)
            startCoordinator()
        case .editLocalization(let versionID, _):
            viewModel.setLanguage(code: code, cardVersionID: versionID)
        }
    }
}
