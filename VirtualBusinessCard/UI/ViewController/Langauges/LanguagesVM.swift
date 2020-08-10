//
//  LanguagesVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol LanguagesVMDelegate: class {
    func viewModelDidRefreshData()
    func viewModelDidLoadData()
}

final class LanguagesVM: AppViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>
    typealias DataModel = LanguagesView.TableCell.DataModel

    weak var delegate: LanguagesVMDelegate?

    let mode: Mode

    let currentlySelectedLanguageCode: String?
    let doneButtonTitle: String
    private(set) var newSelectedLanguageCode: String?

    private var availableLanguageCodes = [String]()
    private var displayedLanguageCodes = [String]()

    private let blacklistedCodes: [String]

    private let currentLocale = Locale.current

    init(mode: Mode, blacklistedCodes: [String]) {
        self.blacklistedCodes = blacklistedCodes
        self.mode = mode
        switch mode {
        case .newLocalization:
            doneButtonTitle = NSLocalizedString("Next", comment: "")
            currentlySelectedLanguageCode = nil
        case .editLocalization(_, let selectedCode):
            doneButtonTitle = NSLocalizedString("Done", comment: "")
            currentlySelectedLanguageCode = selectedCode
        }
        newSelectedLanguageCode = currentlySelectedLanguageCode
        super.init()
    }

    func loadData() {
        DispatchQueue.global().async { [self] in
            let commonLocales = Locale.availableIdentifiers.map { Locale(identifier: $0) }
            let availableLanguageCodes = Locale.isoLanguageCodes
                .filter { langCode in
                    commonLocales.contains(where: { $0.languageCode == langCode})
                        && !blacklistedCodes.contains(langCode)
                }
                .map { self.dataModel(langCode: $0) }
                .sorted { $0.title <= $1.title }
                .map(\.langCode)

            DispatchQueue.main.async {
                self.availableLanguageCodes = availableLanguageCodes
                displayedLanguageCodes = availableLanguageCodes
                delegate?.viewModelDidLoadData()
            }
        }

    }
}

// MARK: - ViewController API

extension LanguagesVM {

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(displayedLanguageCodes.map { dataModel(langCode: $0) })
        return snapshot
    }

    func selectRow(at indexPath: IndexPath) {
        newSelectedLanguageCode = displayedLanguageCodes[indexPath.row]
    }

    func search(for query: String) {
        guard !query.isEmpty else {
            displayedLanguageCodes = availableLanguageCodes
            return
        }
        DispatchQueue.global().async { [self] in
            let displayedLanguageCodes = availableLanguageCodes
                .map { dataModel(langCode: $0) }
                .filter { $0.title.localizedCaseInsensitiveContains(query) }
                .map(\.langCode)

            DispatchQueue.main.async {
                self.displayedLanguageCodes = displayedLanguageCodes
                delegate?.viewModelDidRefreshData()
            }
        }
    }

    private func dataModel(langCode: String) -> DataModel {
        DataModel(
            langCode: langCode,
            title: currentLocale.localizedString(forLanguageCode: langCode) ?? "",
            displayCheckmark: langCode == newSelectedLanguageCode
        )
    }
}

// MARK: - Section

extension LanguagesVM {
    enum Section {
        case main
    }
}

// MARK: - Mode

extension LanguagesVM {
    enum Mode {
        case newLocalization
        case editLocalization(id: UUID, selectedLanguageCode: String?)
    }
}
