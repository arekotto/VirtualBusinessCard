//
//  CardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

protocol CardDetailsVMDelegate: class {
    func reloadData()

}

final class CardDetailsVM: AppViewModel {
    
    typealias DataModel = TitleValueCollectionCell.DataModel
    
    weak var delegate: CardDetailsVMDelegate?
    
    private let cardID: BusinessCardID
    private var card: ReceivedBusinessCardMC?
    
    private let userID: UserID
    private var user: UserMC?
    
    private var sections = [Section]()

    init(userID: UserID, cardID: BusinessCardID) {
        self.userID = userID
        self.cardID = cardID
    }
}
// MARK: - Public API

extension CardDetailsVM {
    var title: String {
        NSLocalizedString("Settings", comment: "")
    }
    
    func numberOrSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        sections[section].rows.count
    }
    
    func row(at indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        sections[section].title
    }
}

// MARK: - Row Creation

extension CardDetailsVM {
    private static func makeRows(for card: ReceivedBusinessCardMC) -> [Section] {
    
        let cardData = card.cardData
        let imagesDataModel = CardFrontBackView.DataModel(
            frontImageURL: cardData.frontImage.url,
            backImageURL: cardData.backImage.url,
            textureImageURL: cardData.texture.image.url,
            normal: CGFloat(cardData.texture.normal),
            specular: CGFloat(cardData.texture.specular)
        )
        
        var sections = [Section(rows: [.cardImagesCell(imagesDataModel)])]
        
        let personalData = [
            DataModel(title: NSLocalizedString("Name", comment: ""), value: card.ownerDisplayName),
            DataModel(title: NSLocalizedString("Position", comment: ""), value: cardData.position.title),
            DataModel(title: NSLocalizedString("Company", comment: ""), value: cardData.position.company)
        ]
        
        let includedPersonalDataRows = personalData.filter { $0.value ?? "" != "" }
        if !includedPersonalDataRows.isEmpty {
            sections.append(Section(rows: includedPersonalDataRows.map { .dataCell($0) }))
        }
        
        let contactData = [
            DataModel(title: NSLocalizedString("Phone Primary", comment: ""), value: cardData.contact.phoneNumberPrimary),
            DataModel(title: NSLocalizedString("Phone Secondary", comment: ""), value: cardData.contact.phoneNumberSecondary),
            DataModel(title: NSLocalizedString("Email", comment: ""), value: cardData.contact.email),
            DataModel(title: NSLocalizedString("Website", comment: ""), value: cardData.contact.website),
            DataModel(title: NSLocalizedString("Fax", comment: ""), value: cardData.contact.fax),
        ]
        
        let includedContactDataRows = contactData.filter { $0.value ?? "" != "" }
        if !includedContactDataRows.isEmpty {
            sections.append(Section(rows: includedContactDataRows.map { .dataCell($0) }))
        }
        
        let address = card.addressFormatted
        if address != "" {
            sections.append(Section(rows: [.dataCell(DataModel(title: NSLocalizedString("Address", comment: ""), value: address))]))
        }
        
        return sections
    }
}

// MARK: - Firebase fetch

extension CardDetailsVM {
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
    
    private var receivedCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
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
        receivedCardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
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
    
    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching received card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        guard let card = ReceivedBusinessCardMC(documentSnapshot: doc) else {
            print(#file, "Error mapping received card:", error?.localizedDescription ?? "No error info available.")
            return
        }
        self.card = card
        sections = Self.makeRows(for: card)
        delegate?.reloadData()
    }
}

// MARK: - Section, Row, RowType

extension CardDetailsVM {
    struct Section {
        
        var rows: [Row]
        var title: String?
        
        init(rows: [CardDetailsVM.Row], title: String? = nil) {
            self.rows = rows
            self.title = title
        }
    }
    
    enum Row {
        case dataCell(TitleValueCollectionCell.DataModel)
        case cardImagesCell(CardFrontBackView.DataModel)
    }
}
