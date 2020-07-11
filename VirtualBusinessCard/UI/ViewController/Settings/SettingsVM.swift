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

final class SettingsVM: AppViewModel {
    
    weak var delegate: SettingsVMDelegate?
        
    private let sections: [Section] = [
        Section(items: [.tags, .profile], title: ""),
        Section(items: [.logOut], title: "")
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
        sections[section].items.count
    }
    
    func itemForRow(at indexPath: IndexPath) -> Item {
        sections[indexPath.section].items[indexPath.row]
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

// MARK: - Section, Row, RowType

extension SettingsVM {
    struct Section {
        let items: [Item]
        let title: String
    }
    
    enum Item {
        case profile
        case tags
        case logOut
        
        private static let disclosureIndicatorImage: UIImage = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .medium)
            return UIImage(systemName: "chevron.right", withConfiguration: imgConfig)!
        }()
        
        var dataModel: DataModel {
            switch self {
            case .logOut: return .buttonCell(NSLocalizedString("Log Out", comment: ""))
            case .profile:
                return .accessoryCell(TitleAccessoryImageCollectionCell.DataModel(
                    title: NSLocalizedString("Profile", comment: ""),
                    accessoryImage: Self.disclosureIndicatorImage
                ))
            case .tags:
                return .accessoryCell(TitleAccessoryImageCollectionCell.DataModel(
                    title: NSLocalizedString("Tags", comment: ""),
                    accessoryImage: Self.disclosureIndicatorImage
                ))
            }
        }
    }
    
    enum DataModel {
        case buttonCell(String)
        case accessoryCell(TitleAccessoryImageCollectionCell.DataModel)
    }
}
