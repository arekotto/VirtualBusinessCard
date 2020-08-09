//
//  EditCardInfoVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardInfoVMDelegate: class {

}

final class EditCardInfoVM: AppViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    weak var delegate: EditCardInfoVMDelegate?

    var position: BusinessCardData.Position
    var name: BusinessCardData.Name
    var contact: BusinessCardData.Contact
    var address: BusinessCardData.Address

    private(set) var subtitle: String

    private lazy var sections = [(type: Section, items: [Row])]()

    init(subtitle: String, transformableData: TransformableData) {
        self.subtitle = subtitle
        self.position = transformableData.position
        self.name = transformableData.name
        self.contact = transformableData.contact
        self.address = transformableData.address
    }
}

// MARK: - ViewController API

extension EditCardInfoVM {

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([.firstName, .lastName, .middleName, .prefix], toSection: .name)
        snapshot.appendItems([.title, .company], toSection: .position)
        snapshot.appendItems([.email, .phoneNumberPrimary, .phoneNumberSecondary, .fax, .website], toSection: .contact)
        snapshot.appendItems([.street, .city, .postCode, .country], toSection: .address)
        return snapshot
    }

    // swiftlint:disable cyclomatic_complexity
    func textValue(for row: Row) -> String? {
        switch row {
        case .firstName: return name.first
        case .lastName: return name.last
        case .middleName: return name.middle
        case .prefix: return name.prefix
        case .title: return position.title
        case .company: return position.company
        case .email: return contact.email
        case .phoneNumberPrimary: return contact.phoneNumberPrimary
        case .phoneNumberSecondary: return contact.phoneNumberSecondary
        case .fax: return contact.fax
        case .website: return contact.website
        case .country: return address.country
        case .city: return address.city
        case .postCode: return address.postCode
        case .street: return address.street
        }
    }

    func setNewValue(text: String, for row: Row) {
        print("setting Text", text)
        switch row {
        case .firstName: name.first = text
        case .lastName: name.last = text
        case .middleName: name.middle = text
        case .prefix: name.prefix = text
        case .title: position.title = text
        case .company: position.company = text
        case .email: contact.email = text
        case .phoneNumberPrimary: contact.phoneNumberPrimary = text
        case .phoneNumberSecondary: contact.phoneNumberSecondary = text
        case .fax: contact.fax = text
        case .website: contact.website = text
        case .country: address.country = text
        case .city: address.city = text
        case .postCode: address.postCode = text
        case .street: address.street = text
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func transformedData() -> TransformableData {
        TransformableData(position: position, name: name, contact: contact, address: address)
    }
}

// MARK: - Editable Data

extension EditCardInfoVM {
    struct TransformableData {
        let position: BusinessCardData.Position
        let name: BusinessCardData.Name
        let contact: BusinessCardData.Contact
        let address: BusinessCardData.Address
    }
}

// MARK: - Section & Row

extension EditCardInfoVM {
    enum Section: Int, Hashable, CaseIterable {
        case name
        case position
        case contact
        case address

        var title: String {
            switch self {
            case .name: return NSLocalizedString("Name", comment: "")
            case .position: return NSLocalizedString("Position", comment: "")
            case .contact: return NSLocalizedString("Contact", comment: "")
            case .address: return NSLocalizedString("Address", comment: "")
            }
        }
    }

    enum Row: Hashable, CaseIterable {
        case firstName
        case lastName
        case middleName
        case prefix

        case title
        case company

        case email
        case phoneNumberPrimary
        case phoneNumberSecondary
        case fax
        case website

        case country
        case city
        case postCode
        case street

        var title: String {
            switch self {
            case .firstName: return NSLocalizedString("First Name", comment: "")
            case .lastName: return NSLocalizedString("Last Name", comment: "")
            case .middleName: return NSLocalizedString("Middle Name", comment: "")
            case .prefix: return NSLocalizedString("Prefix", comment: "")
            case .title: return NSLocalizedString("Position Title", comment: "")
            case .company: return NSLocalizedString("Company", comment: "")
            case .email: return NSLocalizedString("Email", comment: "")
            case .phoneNumberPrimary: return NSLocalizedString("Phone Number", comment: "")
            case .phoneNumberSecondary: return NSLocalizedString("Phone Number Secondary", comment: "")
            case .fax: return NSLocalizedString("Fax", comment: "")
            case .website: return NSLocalizedString("Website", comment: "")
            case .country: return NSLocalizedString("Country", comment: "")
            case .city: return NSLocalizedString("City", comment: "")
            case .postCode: return NSLocalizedString("Post Code", comment: "")
            case .street: return NSLocalizedString("Street", comment: "")
            }
        }

        var returnKeyType: UIReturnKeyType {
            switch self {
            case .country: return .done
            default: return .next
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .email: return .emailAddress
            case .phoneNumberPrimary, .phoneNumberSecondary, .fax: return .phonePad
            case .website: return .URL
            default: return .default
            }
        }

        var autocapitalizationType: UITextAutocapitalizationType {
            switch self {
            case .firstName, .lastName, .middleName, .prefix, .title, .company, .country, .city, .street:
                return .words
            default:
                return .none
            }
        }

        func cellDataModel() -> EditCardInfoView.TextFieldTableCell.DataModel {
            EditCardInfoView.TextFieldTableCell.DataModel(title: title, returnKeyType: returnKeyType, keyboardType: keyboardType, autocapitalizationType: autocapitalizationType)
        }
    }
}
