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
    func presentReceivedCards(with viewModel: ReceivedCardsVM)
}

final class GroupedCardsVM: AppViewModel {
    
    weak var delegate: GroupedCardsVMDelegate?
    
    var selectedGroupingProperty = CardGroup.GroupingProperty.tag {
        didSet { updateGrouping() }
    }
    
    private let userID: UserID
    private let groupingProperties: [CardGroup.GroupingProperty] = [.tag, .company, .dateDay, .dateMonth, .dateYear]
    
    private let encodeValueDateFormatter = ISO8601DateFormatter()
    private let dateTitleFormatter = DateTitleFormatter()
    
    private lazy var sortingPerGroupingProperty: [CardGroup.GroupingProperty: CardGroup.Sorting] = {
        var this = [CardGroup.GroupingProperty: CardGroup.Sorting]()
        groupingProperties.forEach {
            this[$0] = $0.defaultSorting
        }
        return this
    }()
    
    private var user: UserMC?
    private var cards = [ReceivedBusinessCardMC]()
    private var tags = [BusinessCardTagID: BusinessCardTagMC]()

    private var groups = [CardGroup]()

    init(userID: String) {
        self.userID = userID
    }
    
    private func updateGrouping() {
        switch selectedGroupingProperty {
        case .tag: groups = CardGroup.groupByTag(cards: cards)
        case .dateDay: groups = CardGroup.groupByReceivingDay(cards: cards, dateFormatter: encodeValueDateFormatter)
        case .company: groups = CardGroup.groupByCompany(cards: cards)
        case .dateMonth: groups = CardGroup.groupByReceivingMonth(cards: cards, dateFormatter: encodeValueDateFormatter)
        case .dateYear: groups = CardGroup.groupByReceivingYear(cards: cards, dateFormatter: encodeValueDateFormatter)
        }
        updateSorting()
        delegate?.refreshData()
    }
    
    private func updateSorting() {
        switch selectedGroupingProperty {
        case .tag:
            groups.sort {
                if let tagID0 = $0.groupingValue, let tagID1 = $1.groupingValue {
                    return tags[tagID0]?.priorityIndex ?? Int.max < tags[tagID1]?.priorityIndex ?? Int.max
                } else {
                    return $1.groupingValue == nil
                }
            }
        default:
            let sorting = sortingPerGroupingProperty[selectedGroupingProperty]!
            switch sorting {
            case .ascending: groups.sort { $0.groupingValue ?? "" < $1.groupingValue ?? "" }
            case .descending: groups.sort { $0.groupingValue ?? "" > $1.groupingValue ?? "" }
            }
        }
    }
}

// MARK: - Item Data

extension GroupedCardsVM {
    
    private static func itemSubtitle(cards: [ReceivedBusinessCardMC]) -> String {
        let subtitle = cards.first!.ownerDisplayName
        return cards[1..<cards.count].reduce(subtitle) { text, card in
            text + ", \(card.ownerDisplayName)"
        }
    }
    
    private func itemTitle(groupingValue: String?) -> String {
        switch selectedGroupingProperty {
        case .tag: return itemTitleForTag(groupingValue: groupingValue)
        case .company: return itemTitleForCompany(groupingValue: groupingValue)
        case .dateDay: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.dayFormatter)
        case .dateMonth: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.monthFormatter)
        case .dateYear: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.yearFormatter)
        }
    }
    
    private func itemTitleForTag(groupingValue: String?) -> String {
        if let tagID = groupingValue {
            return tags[tagID]?.title ?? ""
        }
        return NSLocalizedString("Not Tagged", comment: "")
    }
    
    private func itemTitleForCompany(groupingValue: String?) -> String {
        if let company = groupingValue {
            return company
        }
        return NSLocalizedString("Personal Cards", comment: "")
    }
    
    private func itemTitleForDate(groupingValue: String?, dateFormatter: DateFormatter) -> String {
        guard let dateString = groupingValue else {
            return "" // this should never happen
        }
        guard let date = encodeValueDateFormatter.date(from: dateString) else {
            return "" // this should never happen
        }
        return dateFormatter.string(from: date)
    }
}

// MARK: - ViewController API

extension GroupedCardsVM {
    var title: String {
        NSLocalizedString("Collection", comment: "")
    }
    
    var seeAllCardsButtonTitle: String {
        NSLocalizedString("See all", comment: "")
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
        let title = item(for: indexPath).title
        let group = groups[indexPath.item]
        let vm = ReceivedCardsVM(userID: userID, title: title, dataFetchMode: .specifiedIDs(group.cardIDs))
        delegate?.presentReceivedCards(with: vm)
    }
    
    func didSelectGroupingMode(at index: Int) {
        selectedGroupingProperty = groupingProperties[index]
    }
    
    func didTapSeeAll() {
        let title = NSLocalizedString("All Cards", comment: "")
        let vm = ReceivedCardsVM(userID: userID, title: title, dataFetchMode: .allReceivedCards)
        delegate?.presentReceivedCards(with: vm)
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
    
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    private var tagsCollectionReference: CollectionReference {
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
        receivedCardsCollectionReference.order(by: "receivingDate", descending: true).addSnapshotListener { [weak self] querySnapshot, error in
            self?.receivedCardCollectionDidChange(querySnapshot, error)
        }
        tagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.cardTagsDidChange(querySnapshot, error)
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
    
    private func receivedCardCollectionDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
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
    
    private func cardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        tags.removeAll()
        querySnap.documents.forEach {
            guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return
            }
            tags[tag.id] = BusinessCardTagMC(tag: tag)
        }
        if selectedGroupingProperty == .tag {
            updateSorting()            
        }
        if !cards.isEmpty {
            delegate?.refreshData()
        }
    }
}

// MARK: - DateTitleFormatter

extension GroupedCardsVM {
    private struct DateTitleFormatter {
        
        let dayFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateStyle = UIScreen.main.bounds.width > 320 ? .long : .medium
            return this
        }()
        
        let monthFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMYYYY", options: 0, locale: Locale.current)
            return this
        }()
        
        let yearFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateStyle = UIScreen.main.bounds.width > 320 ? .long : .medium
            this.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale.current)
            return this
        }()
    }
}
