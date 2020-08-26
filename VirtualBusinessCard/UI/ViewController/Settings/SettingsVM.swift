//
//  SettingsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

protocol SettingsVMDelegate: class {
    func presentUserProfileVC(with viewModel: UserProfileVM)
    func presentTagsVC(with viewModel: TagsVM)
    func presentLogoutAlertController(title: String, actionTitle: String)
}

final class SettingsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<SettingsVM.Section, SettingsVM.Row>

    weak var delegate: SettingsVMDelegate?
        
    private let sections: [Section] = [
        Section(rows: [.profile], title: ""),
        Section(rows: [.logOut], title: "")
    ]

    private func logout() {
        try? Auth.auth().signOut()
    }
}

// MARK: - ViewController API

extension SettingsVM {
    
    var title: String {
        NSLocalizedString("Settings", comment: "")
    }
    
    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in snapshot.appendItems(section.rows, toSection: section) }
        return snapshot
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch sections[indexPath.section].rows[indexPath.row] {
        case .profile: delegate?.presentUserProfileVC(with: UserProfileVM(userID: userID))
        case .tags: delegate?.presentTagsVC(with: TagsVM(userID: userID))
        case .logOut:
            delegate?.presentLogoutAlertController(
                title: NSLocalizedString("Are you sure you want to log out?", comment: ""),
                actionTitle: NSLocalizedString("Log Out", comment: "")
            )
        }
    }
    
    func didSelectLogoutAction() {
        logout()
    }
}

// MARK: - Section, Row

extension SettingsVM {
    struct Section: Hashable {
        let rows: [Row]
        let title: String
    }
    
    enum Row: Equatable {
        case profile
        case tags
        case logOut
        
        private static let disclosureIndicatorImage: UIImage = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .medium)
            return UIImage(systemName: "chevron.right", withConfiguration: imgConfig)!
        }()
        
        var dataModel: TitleTableCell.DataModel {
            switch self {
            case .logOut:
                return TitleTableCell.DataModel(title: NSLocalizedString("Log Out", comment: ""), titleColor: Asset.Colors.appAccent.color)
            case .profile:
                return TitleTableCell.DataModel(title: NSLocalizedString("Profile", comment: ""), accessoryImage: Self.disclosureIndicatorImage)
            case .tags:
                return TitleTableCell.DataModel(title: NSLocalizedString("Tags", comment: ""), accessoryImage: Self.disclosureIndicatorImage)
            }
        }
    }
}
