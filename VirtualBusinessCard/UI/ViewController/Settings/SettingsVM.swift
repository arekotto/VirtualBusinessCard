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
    
    weak var delegate: SettingsVMDelegate?
        
    private let sections: [Section] = [
        Section(rows: [.tags, .profile], title: ""),
        Section(rows: [.logOut], title: "")
    ]

    private func logout() {
        try! Auth.auth().signOut()
    }
}

// MARK: - ViewController API

extension SettingsVM {
    
    var title: String {
        NSLocalizedString("Settings", comment: "")
    }
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        sections[section].rows.count
    }
    
    func itemForRow(at indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch itemForRow(at: indexPath) {
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
    struct Section {
        let rows: [Row]
        let title: String
    }
    
    enum Row {
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
                return TitleTableCell.DataModel(title: NSLocalizedString("Log Out", comment: ""), titleColor: .appAccent)
            case .profile:
                return TitleTableCell.DataModel(title: NSLocalizedString("Profile", comment: ""), accessoryImage: Self.disclosureIndicatorImage)
            case .tags:
                return TitleTableCell.DataModel(title: NSLocalizedString("Tags", comment: ""), accessoryImage: Self.disclosureIndicatorImage)
            }
        }
    }

}
