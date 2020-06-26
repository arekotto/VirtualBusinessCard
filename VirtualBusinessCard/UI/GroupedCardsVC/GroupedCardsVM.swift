//
//  GroupedCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol GroupedCardsVMDelegate: class {
    func refreshData()
}

final class GroupedCardsVM: AppViewModel {
    
    weak var delegate: GroupedCardsVMDelegate?
    
    var selectedGroupingProperty = CardGroup.GroupingProperty.tag {
        didSet { updateGrouping() }
    }
    
    private let userID: UserID
    private let groupingProperties: [CardGroup.GroupingProperty] = [.tag, .company, .date]
    
    private let encodeValueDateFormatter = ISO8601DateFormatter()
    private let displayDateFormatter: DateFormatter = {
        let this = DateFormatter()
        this.timeStyle = .none
        this.dateStyle = UIScreen.main.bounds.width > 320 ? .long : .medium
        return this
    }()
    
    private var user: UserMC?
    private var cards = [ReceivedBusinessCardMC]()
    private var tags = [BusinessCardTagMC]()

    private var groups = [CardGroup]()

    init(userID: String) {
        self.userID = userID
    }
    
    private func updateGrouping() {
        switch selectedGroupingProperty {
        case .tag:
            groups = CardGroup.groupByTag(cards: cards)
        case .date:
            groups = CardGroup.groupByDate(cards: cards, dateFormatter: encodeValueDateFormatter)
        case .company:
            groups = CardGroup.groupByCompany(cards: cards)
        }
        delegate?.refreshData()
    }
}

// MARK: - Item Data

extension GroupedCardsVM {
    
    private static func itemSubtitle(cards: [ReceivedBusinessCardMC]) -> String {
        let subtitle = cards.first!.ownerDisplayName
        return cards.reduce(subtitle) { text, card in
            text + ", \(card.ownerDisplayName)"
        }
    }
    
    private func itemTitle(groupingValue: CardGroup.GroupingValue) -> String {
        switch selectedGroupingProperty {
        case .tag: return itemTitleForTag(groupingValue: groupingValue)
        case .date: return itemTitleForDate(groupingValue: groupingValue)
        case .company: return itemTitleForCompany(groupingValue: groupingValue)
        }
    }
    
    private func itemTitleForTag(groupingValue: CardGroup.GroupingValue) -> String {
        switch groupingValue {
        case .some(let tagID): return tags.first(where: {$0.id == tagID})?.title ?? ""
        case .none: return NSLocalizedString("Not Tagged", comment: "")
        }
    }
    
    private func itemTitleForCompany(groupingValue: CardGroup.GroupingValue) -> String {
        switch groupingValue {
        case .some(let company): return company
        case .none: return NSLocalizedString("Personal Cards", comment: "")
        }
    }
    
    private func itemTitleForDate(groupingValue: CardGroup.GroupingValue) -> String {
        switch groupingValue {
        case .some(let dateString):
            guard let date = encodeValueDateFormatter.date(from: dateString) else { return "" }
            return displayDateFormatter.string(from: date)
        case .none: return "" // this should never happen
        }
    }
}

// MARK: - ViewController API

extension GroupedCardsVM {
    var title: String {
        NSLocalizedString("Collection", comment: "")
    }
    
    var tabBarIconImage: UIImage {
        UIImage(named: "CollectionIcon")!
    }
    
    func numberOfItems() -> Int {
        groups.count
    }
    
    var availableGroupingModes: [String] {
        groupingProperties.map(\.localizedName)
    }
    
    func item(for indexPath: IndexPath) -> GroupedCardsView.TableCell.DataModel {
        let group = groups[indexPath.row]
        let cardsInGroup = cards.filter{group.cardIDs.contains($0.id)}

        return GroupedCardsView.TableCell.DataModel(
            frontImageURL: cardsInGroup[optional: 0]?.cardData.frontImage.url,
            middleImageURL: cardsInGroup[optional: 1]?.cardData.frontImage.url,
            backImageURL: cardsInGroup[optional: 2]?.cardData.frontImage.url,
            title: itemTitle(groupingValue: group.groupingValue),
            subtitle: Self.itemSubtitle(cards: cardsInGroup),
            cardCountText: "\(cardsInGroup.count)"
        )
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        //        delegate?.presentBusinessCardDetails(id: businessCards[indexPath.item].id)
    }
    
    func didSelectGroupingMode(at index: Int) {
        selectedGroupingProperty = groupingProperties[index]
    }
}

// MARK: - Firebase fetch

extension GroupedCardsVM {
    private var userPublicDocumentReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userID)
    }
    
    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    private var businessCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    private var businessCardTagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }
    
    func fetchData() {
        userPublicDocumentReference.addSnapshotListener() { [weak self] document, error in
            self?.userPublicDidChange(document, error)
        }
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
        businessCardCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.receivedBusinessCardCollectionDidChange(querySnapshot, error)
        }
        
        businessCardTagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.businessCardTagsDidChange(querySnapshot, error)
        }
    }
    
    private func userPrivateDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user private changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        user?.setUserPrivate(document: doc)
        delegate?.refreshData()
    }
    
    private func receivedBusinessCardCollectionDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        cards = querySnap.documents.compactMap {
            guard let bc = ReceivedBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return ReceivedBusinessCardMC(card: bc)
        }
        updateGrouping()
    }
    
    private func businessCardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        tags = querySnap.documents.compactMap {
            guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return BusinessCardTagMC(tag: tag)
        }
        
        if !cards.isEmpty {
            delegate?.refreshData()
        }
    }
}
