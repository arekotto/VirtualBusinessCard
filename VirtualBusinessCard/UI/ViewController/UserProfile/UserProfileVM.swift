//
//  UserProfileVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 28/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileVMDelegate: class {
    func reloadData()
    func presentAlertWithTextField(title: String?, message: String?, for row: UserProfileVM.Row)
    func presentAlert(title: String?, message: String?)
}

final class UserProfileVM: AppViewModel {
    
    weak var delegate: UserProfileVMDelegate?
    
    private let userID: UserID
    private var user: UserMC?
    
    let sections: [Section] = [Section(rows: [.firstName, .lastName, .email], title: NSLocalizedString("Account", comment: ""))]

    internal init(userID: UserID) {
        self.userID = userID
    }
}

extension UserProfileVM {
}

// MARK: - Public API

extension UserProfileVM {
    var title: String {
        NSLocalizedString("Settings", comment: "")
    }
    
    func numberOrSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        let rowCount = sections[section].rows.count
        return rowCount > 1 ? rowCount + 2 : 0
    }
    
    func title(for section: Int) -> String {
        sections[section].title
    }
    
    func rowType(at indexPath: IndexPath) -> RowType {
        if indexPath.row == 0 {
            return .sectionOpening
        }
        
        let section = sections[indexPath.section]
        if indexPath.row == section.rows.count + 1 {
            return .sectionClosing
        }
        return .item
    }
    
    func itemForRow(at indexPath: IndexPath) -> UserProfileView.TableCell.DateModel {
        let row = rowWithIndexAdjustment(at: indexPath)
        return UserProfileView.TableCell.DateModel(title: row.title, value: valueText(for: row))
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard rowType(at: indexPath) == .item else { return }
        let row = rowWithIndexAdjustment(at: indexPath)
        delegate?.presentAlertWithTextField(title: row.title, message: row.modifyMessage, for: row)
    }
    
    private func rowWithIndexAdjustment(at indexPath: IndexPath) -> Row {
        let adjustedIndex = indexPath.row - 1
        return sections[indexPath.section].rows[adjustedIndex]
    }
    
    private func valueText(for row: Row) -> String? {
        switch row {
        case .firstName:
            return user?.firstName
        case .lastName:
            return user?.lastName
        case .email:
            return user?.email
        }
    }
    
    func didSetNewValue(_ value: String, for row: Row) {
        guard !value.isEmpty else {
            presentEmptyValueAlert(for: row)
            return
        }
        switch row {
        case .firstName: setNewFirstName(value)
        case .lastName: setNewLastName(value)
        case .email: setNewEmail(value)
        }
    }
    
    private func setNewFirstName(_ value: String) {
        user?.firstName = value
        user?.save()
    }
    
    private func setNewLastName(_ value: String) {
        user?.lastName = value
        user?.save()
    }
    
    private func setNewEmail(_ value: String) {
        Auth.auth().currentUser?.updateEmail(to: value, completion: { error in
            if let err = error {
                let title = NSLocalizedString("Email Could Not Be Updated", comment: "")
                print(#file, err.localizedDescription)
                guard let errorCode = AuthErrorCode(rawValue: err._code) else {
                    self.delegate?.presentAlert(title: title, message: AppError.localizedUnknownErrorDescription)
                    return
                }
                let message = errorCode.localizedMessageForUser
                self.delegate?.presentAlert(title: title, message: message)
            } else {
                self.user?.email = value
                self.user?.save()
            }
        })
    }
    
    private func presentEmptyValueAlert(for row: Row) {
        switch row {
        case .firstName:
            delegate?.presentAlert(
                title: NSLocalizedString("Empty First Name", comment: ""),
                message: NSLocalizedString("Your account has to have a first name.", comment: "")
            )
        case .lastName:
            delegate?.presentAlert(
                title: NSLocalizedString("Empty Last Name", comment: ""),
                message: NSLocalizedString("Your account has to have a last name.", comment: "")
            )
        case .email:
            delegate?.presentAlert(
                title: NSLocalizedString("Empty First Name", comment: ""),
                message: NSLocalizedString("Your account has to have a valid email.", comment: "")
            )
        }
    }
}

// MARK: - Firebase fetch

extension UserProfileVM {
    func fetchData() {
        userPublicDocumentReference.addSnapshotListener() { [weak self] document, error in
            self?.userPublicDidChange(document, error)
        }
    }
    
    private var userPublicDocumentReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userID)
    }
    
    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    private var businessCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(PersonalBusinessCard.collectionName)
    }
    
    private func userPublicDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user public changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        
        guard let user = UserMC(userPublicDocument: doc) else {
            print(#file, "Error mapping user public:", doc.documentID)
            return
        }
        self.user = user
        userPrivateDocumentReference.addSnapshotListener() { [weak self] snapshot, error in
            self?.userPrivateDidChange(snapshot, error)
        }
    }
    
    private func userPrivateDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user private changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        user?.setUserPrivate(document: doc)
        delegate?.reloadData()
    }
}

extension UserProfileVM {
    struct Section {
        var rows: [Row]
        var title: String
    }
    
    enum Row {
        case firstName
        case lastName
        case email
        
        var title: String {
            switch self {
            case .firstName: return NSLocalizedString("First name", comment: "")
            case .lastName: return NSLocalizedString("Last name", comment: "")
            case .email: return NSLocalizedString("Email", comment: "")
            }
        }
        
        var modifyMessage: String {
            switch self {
            case .firstName: return NSLocalizedString("Enter your new first name in the field below.", comment: "")
            case .lastName: return NSLocalizedString("Enter your new last name in the field below.", comment: "")
            case .email: return NSLocalizedString("Enter your new email in the field below.", comment: "")
            }
        }
    }
    
    enum RowType {
        case sectionOpening
        case sectionClosing
        case item
    }
}
