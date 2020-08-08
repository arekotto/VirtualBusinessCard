//
//  EditCardInfoVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardInfoVCDelegate: class {
    func editCardInfoVC(_ viewController: EditCardInfoVC, didFinishWith transformedData: EditCardInfoVM.TransformableData)
}

final class EditCardInfoVC: AppTableViewController<EditCardInfoVM> {

    weak var delegate: EditCardInfoVCDelegate?

    private typealias DataSource = UITableViewDiffableDataSource<EditCardInfoVM.Section, EditCardInfoVM.Row>

    private lazy var tableViewDataSource = makeTableViewDataSource()

    private lazy var nextButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(didTapDoneButton))

    init(viewModel: EditCardInfoVM) {
        super.init(viewModel: viewModel, style: .insetGrouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupNavigationItem()
        setupTableView()
        tableViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: false)
        view.backgroundColor = Asset.Colors.appBackground.color
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EditCardInfoView.HeaderView()
        header.label.text = EditCardInfoVM.Section(rawValue: section)?.title
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.registerReusableCell(EditCardInfoView.TextFieldTableCell.self)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.contentInset = EditCardInfoView.defaultTableViewContentInsets
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = tableViewDataSource
    }

    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = nextButton
    }

    private func makeTableViewDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, row in
            let cell: EditCardInfoView.TextFieldTableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.textField.delegate = self
            cell.setRow(row, indexPath: indexPath, textValue: self?.viewModel.textValue(for: row))
            return cell
        }
    }
}

@objc
private extension EditCardInfoVC {
    func didTapDoneButton() {
        view.endEditing(true)
        delegate?.editCardInfoVC(self, didFinishWith: viewModel.transformedData())
    }
}

extension EditCardInfoVC: EditCardInfoVMDelegate {

}

extension EditCardInfoVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let cardInfoTextField = textField as? EditCardInfoView.EditCardInfoTextField else { return true }
        guard let indexPath = cardInfoTextField.indexPath, let nextIndexPath = nextIndexPath(for: indexPath) else { return true }
        guard let nextCell = tableView.cellForRow(at: nextIndexPath) as? EditCardInfoView.TextFieldTableCell else {
            textField.resignFirstResponder()
            return true
        }
        nextCell.textField.becomeFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let row = (textField as? EditCardInfoView.EditCardInfoTextField)?.row else { return }
        viewModel.setNewValue(text: textField.text ?? "", for: row)
    }

    private func nextIndexPath(for indexPath: IndexPath) -> IndexPath? {
        var nextRow = 0
        var nextSection = 0
        var iteration = 0
        var startRow = indexPath.row
        for section in indexPath.section ..< tableView.numberOfSections {
            nextSection = section
            for row in startRow ..< tableView.numberOfRows(inSection: section) {
                nextRow = row
                iteration += 1
                if iteration == 2 {
                    let nextIndexPath = IndexPath(row: nextRow, section: nextSection)
                    return nextIndexPath
                }
            }
            startRow = 0
        }

        return nil
    }
}
