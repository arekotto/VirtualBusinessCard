//
//  ReceivedCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import CoreMotion
import UIKit

protocol ReceivedBusinessCardsVMDelegate: class {
    func refreshData(animated: Bool)
    func refreshUpdateIndicators()
    func refreshLayout(style: CardFrontBackView.Style)
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

final class ReceivedCardsVM: PartialUserViewModel, MotionDataSource {

    typealias DataModel = ReceivedCardsView.CollectionCell.DataModel
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>

    weak var delegate: ReceivedBusinessCardsVMDelegate?

    var presentedCard: BusinessCardID?

    private(set) lazy var motionManager = CMMotionManager()

    private(set) var cellStyle = CardFrontBackView.Style.expanded
    private(set) lazy var selectedSortMode = sortActions.first!.mode

    let title: String
    let dataFetchMode: DataFetchMode

    private var searchedQuery = ""

    private var user: UserMC?
    private var cards = [ReceivedBusinessCardMC]()
    private var displayedCardIndexes = [Int]()

    private var updateCheckNo = 0
    private var updatesForCards = [BusinessCardID: Bool]()
    
    private let sortActions = defaultSortActions()

    init(userID: UserID, dataFetchMode: DataFetchMode, title: String) {
        self.title = title
        self.dataFetchMode = dataFetchMode
        super.init(userID: userID)
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }
}

// MARK: - ViewController API

extension ReceivedCardsVM {

    var titleImageColor: UIColor? {
        switch dataFetchMode {
        case .tagWithSpecifiedIDs(_, let tag):
            return tag.displayColor
        default: return nil
        }
    }
    
    var cellSizeControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        switch cellStyle {
        case .compact:
            return UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: imgConfig)!
        case .expanded:
            return UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: imgConfig)!
        }
    }

    var presentedIndexPath: IndexPath? {
        get {
            guard let cardIndex = cards.firstIndex(where: { $0.id == presentedCard }) else { return nil }
            guard let itemIndex = displayedCardIndexes.firstIndex(of: cardIndex) else { return nil }
            return IndexPath(item: itemIndex)
        }
        set {
            guard let indexPath = newValue else {
                presentedCard = nil
                return
            }
            presentedCard = card(for: indexPath).id
        }
    }
    
    var sortControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        return UIImage(systemName: "arrow.up.arrow.down", withConfiguration: imgConfig)!
    }

    func startUpdatingMotionData() {
        startUpdatingMotionData(in: cellStyle.motionDataUpdateInterval)
    }
    
    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(displayedCardIndexes.map { cellViewModel(for: cards[$0], withNumber: $0) })
        return snapshot
    }

    func detailsViewModel(for indexPath: IndexPath) -> CardDetailsVM {
        let card = cards[displayedCardIndexes[indexPath.item]]
        let prefetchedDM = CardDetailsVM.PrefetchedData(
            dataModel: sceneViewModel(for: card.displayedLocalization),
            hapticSharpness: card.displayedLocalization.hapticFeedbackSharpness
        )
        return CardDetailsVM(userID: userID, cardID: card.id, initialLoadDataModel: prefetchedDM)
    }

    func hasUpdatesForCard(at indexPath: IndexPath) -> Bool {
        let cardID = card(for: indexPath).id
        return updatesForCards[cardID] ?? false
    }
    
    func toggleCellSizeMode() {
        switch cellStyle {
        case .compact:
            cellStyle = .expanded
            startUpdatingMotionData(in: 0.1)
        case .expanded:
            startUpdatingMotionData(in: 0.2)
            cellStyle = .compact
        }
        delegate?.refreshLayout(style: cellStyle)
    }
    
    func beginSearch(for query: String) {
        self.searchedQuery = query
        DispatchQueue.global().async {
            let newDisplayedCardIndexes: [Int]
            if query.isEmpty {
                newDisplayedCardIndexes = Array(0 ..< self.cards.count)
            } else {
                newDisplayedCardIndexes = self.cards.enumerated()
                    .filter { _, card in Self.shouldDisplayCard(card, forQuery: query) }
                    .map { idx, _ in idx }
            }
            if newDisplayedCardIndexes != self.displayedCardIndexes {
                DispatchQueue.main.async {
                    self.displayedCardIndexes = newDisplayedCardIndexes
                    self.delegate?.refreshData(animated: true)
                }
            }
        }
    }
    
    func sortingAlertControllerDataModel() -> SortingAlertControllerDataModel {
        SortingAlertControllerDataModel(title: NSLocalizedString("Sort cards by:", comment: ""), actions: sortActions)
    }
    
    func setSortMode(_ mode: SortMode) {
        guard sortActions.contains(where: { $0.mode == mode}) else { return }
        selectedSortMode = mode
        DispatchQueue.global().async {
            let newSortedCards = Self.sortCards(self.cards, using: mode)
            DispatchQueue.main.async {
                self.cards = newSortedCards
                self.delegate?.refreshData(animated: true)
            }
        }
    }

    private func card(for indexPath: IndexPath) -> ReceivedBusinessCardMC {
        cards[displayedCardIndexes[indexPath.item]]
    }

    private func cellViewModel(for card: ReceivedBusinessCardMC, withNumber number: Int) -> DataModel {
        DataModel(
            cardID: card.id,
            sceneDataModel: sceneViewModel(for: card.displayedLocalization),
            hasUpdates: updatesForCards[card.id] ?? false
        )
    }

    private func sceneViewModel(for localization: BusinessCardLocalization) -> CardFrontBackView.URLDataModel {
        CardFrontBackView.URLDataModel(
            frontImageURL: localization.frontImage.url,
            backImageURL: localization.backImage.url,
            textureImageURL: localization.texture.image.url,
            normal: CGFloat(localization.texture.normal),
            specular: CGFloat(localization.texture.specular),
            cornerRadiusHeightMultiplier: CGFloat(localization.cornerRadiusHeightMultiplier)
        )
    }
}

// MARK: - Sorting static helpers

extension ReceivedCardsVM {
    
    private static func defaultSortActions() -> [SortAction] {
        return [
            SortAction(mode: SortMode(property: .receivingDate, direction: .descending), title: NSLocalizedString("Receiving date - descending", comment: "")),
            SortAction(mode: SortMode(property: .receivingDate, direction: .ascending), title: NSLocalizedString("Receiving date - ascending", comment: "")),
            SortAction(mode: SortMode(property: .firstName, direction: .descending), title: NSLocalizedString("First name - descending", comment: "")),
            SortAction(mode: SortMode(property: .firstName, direction: .ascending), title: NSLocalizedString("First name - ascending", comment: "")),
            SortAction(mode: SortMode(property: .lastName, direction: .descending), title: NSLocalizedString("Last name - descending", comment: "")),
            SortAction(mode: SortMode(property: .lastName, direction: .ascending), title: NSLocalizedString("Last name - ascending", comment: ""))
        ]
    }
    
    private static func sortCards(_ cards: [ReceivedBusinessCardMC], using mode: SortMode) -> [ReceivedBusinessCardMC] {
        switch mode.property {
        case .firstName:
            switch mode.direction {
            case .ascending: return cards.sorted(by: Self.cardSorterFirstNameAscending)
            case .descending: return cards.sorted(by: Self.cardSorterFirstNameDescending)
            }
        case .lastName:
            switch mode.direction {
            case .ascending: return cards.sorted(by: Self.cardSorterLastNameAscending)
            case .descending: return cards.sorted(by: Self.cardSorterLastNameDescending)
            }
        case .receivingDate:
            switch mode.direction {
            case .ascending: return cards.sorted(by: Self.cardSorterDateAscending)
            case .descending: return cards.sorted(by: Self.cardSorterDateDescending)
            }
        }
    }
    
    private static func cardSorterFirstNameAscending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        let lhsFirstName = lhs.displayedLocalization.name.first ?? ""
        let rhsFirstName = rhs.displayedLocalization.name.first ?? ""
        if lhsFirstName == rhsFirstName {
            return Self.cardSorterDateDescending(lhs, rhs)
        } else {
            return lhsFirstName < rhsFirstName
        }
    }
    
    private static func cardSorterFirstNameDescending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        let lhsFirstName = lhs.displayedLocalization.name.first ?? ""
        let rhsFirstName = rhs.displayedLocalization.name.first ?? ""
        if lhsFirstName == rhsFirstName {
            return Self.cardSorterDateDescending(lhs, rhs)
        } else {
            return lhsFirstName > rhsFirstName
        }
    }
    
    private static func cardSorterLastNameAscending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        let lhsLastName = lhs.displayedLocalization.name.last ?? ""
        let rhsLastName = rhs.displayedLocalization.name.last ?? ""
        if lhsLastName == rhsLastName {
            return Self.cardSorterDateDescending(lhs, rhs)
        } else {
            return lhsLastName < rhsLastName
        }
    }
    
    private static func cardSorterLastNameDescending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        let lhsLastName = lhs.displayedLocalization.name.last ?? ""
        let rhsLastName = rhs.displayedLocalization.name.last ?? ""
        if lhsLastName == rhsLastName {
            return Self.cardSorterDateDescending(lhs, rhs)
        } else {
            return lhsLastName > rhsLastName
        }
    }
    
    private static func cardSorterDateAscending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        lhs.receivingDate <= rhs.receivingDate
    }
    
    private static func cardSorterDateDescending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        lhs.receivingDate >= rhs.receivingDate
    }
}

// MARK: - Firebase static helpers

extension ReceivedCardsVM {
    
    private static func mapAllCards(from querySnap: QuerySnapshot) -> [ReceivedBusinessCardMC] {
        querySnap.documents.compactMap {
            guard let bc = ReceivedBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return ReceivedBusinessCardMC(card: bc)
        }
    }
    
    private static func mapCards(from querySnap: QuerySnapshot, containedIn ids: [BusinessCardID]) -> [ReceivedBusinessCardMC] {
        var idsDict = [String: Bool]()
        ids.forEach { idsDict[$0] = true }
        
        return querySnap.documents.compactMap {
            
            guard idsDict[$0.documentID] == true else { return nil }
            
            guard let bc = ReceivedBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return ReceivedBusinessCardMC(card: bc)
        }
    }
    
    private static func shouldDisplayCard(_ card: ReceivedBusinessCardMC, forQuery query: String) -> Bool {
        let name = card.displayedLocalization.name
        let names = [name.first ?? "", name.last ?? "", name.middle ?? "" ]
        return names.contains(where: { $0.contains(query) })
    }
}

// MARK: - Section

extension ReceivedCardsVM {
    enum Section {
        case main
    }
}

// MARK: - Firebase fetch

extension ReceivedCardsVM {
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }

    private var directCardExchangeReference: CollectionReference {
        db.collection(DirectCardExchange.collectionName)
    }
    
    func fetchData() {
        receivedCardsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.receivedCardsCollectionDidChange(querySnapshot: querySnapshot, error: error)
        }
    }
    
    private func receivedCardsCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        DispatchQueue.global().async {
            
            let newCardsSorted = self.mapAndSortCards(querySnapshot: querySnap)

            DispatchQueue.main.async {
                self.cards = newCardsSorted
                self.displayedCardIndexes = Array(0 ..< newCardsSorted.count)

                if !self.searchedQuery.isEmpty {
                    self.beginSearch(for: self.searchedQuery)
                } else {
                    self.delegate?.refreshData(animated: self.updateCheckNo > 0)
                }

                self.updateCheckNo += 1
                self.checkForAvailableUpdates(for: newCardsSorted, updateCheckNo: self.updateCheckNo)
            }
        }
    }

    private func checkForAvailableUpdates(for cards: [ReceivedBusinessCardMC], updateCheckNo: Int) {

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()

        var exchangeDocs: [QueryDocumentSnapshot] = []

        directCardExchangeReference
            .whereField(DirectCardExchange.CodingKeys.ownerID.rawValue, isEqualTo: userID)
            .getDocuments(source: .server) { querySnapshot, error in

                guard let snapshot = querySnapshot else {
                    print(#file, error?.localizedDescription ?? "")
                    dispatchGroup.leave()
                    return
                }

                exchangeDocs.append(contentsOf: snapshot.documents)
                dispatchGroup.leave()
            }

        directCardExchangeReference
            .whereField(DirectCardExchange.CodingKeys.guestID.rawValue, isEqualTo: userID)
            .getDocuments(source: .server) { querySnapshot, error in

                guard let snapshot = querySnapshot else {
                    print(#file, error?.localizedDescription ?? "")
                    dispatchGroup.leave()
                    return
                }

                exchangeDocs.append(contentsOf: snapshot.documents)
                dispatchGroup.leave()
            }

        dispatchGroup.notify(queue: .global()) { [weak self] in
            self?.makeUpdatesDictionary(exchangeDocs: exchangeDocs, cards: cards, updateCheckNo: updateCheckNo)
        }
    }

    private func makeUpdatesDictionary(exchangeDocs: [QueryDocumentSnapshot], cards: [ReceivedBusinessCardMC], updateCheckNo: Int) {

        var cards = cards
        var updatesForCards = [BusinessCardID: Bool]()

        exchangeDocs.forEach { exchangeDoc in
            guard let cardIndex = cards.firstIndex(where: { $0.exchangeID == exchangeDoc.documentID }) else { return }
            let card = cards.remove(at: cardIndex)

            guard let exchange = DirectCardExchangeMC(exchangeDocument: exchangeDoc) else {
                return
            }

            let lastExchangeVersion = exchange.ownerID == userID ? exchange.guestCardVersion : exchange.ownerCardVersion
            if lastExchangeVersion > card.version {
                updatesForCards[card.id] = true
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if updateCheckNo == self.updateCheckNo {
                self.updatesForCards = updatesForCards
                self.delegate?.refreshUpdateIndicators()
            }
        }
    }
    
    private func mapAndSortCards(querySnapshot: QuerySnapshot) -> [ReceivedBusinessCardMC] {
        let newCards: [ReceivedBusinessCardMC]
        switch self.dataFetchMode {
        case .allReceivedCards: newCards = Self.mapAllCards(from: querySnapshot)
        case .specifiedIDs(let ids), .tagWithSpecifiedIDs(let ids, _):
            newCards = Self.mapCards(from: querySnapshot, containedIn: ids)
        }
        return Self.sortCards(newCards, using: self.selectedSortMode)
    }
}

// MARK: - DataFetchMode

extension ReceivedCardsVM {    
    enum DataFetchMode {
        case allReceivedCards
        case specifiedIDs(_ ids: [BusinessCardID])
        case tagWithSpecifiedIDs(_ ids: [BusinessCardID], tag: BusinessCardTagMC)
    }
}

// MARK: - Sorting

extension ReceivedCardsVM {
    
    struct SortingAlertControllerDataModel {
        let title: String
        let actions: [SortAction]
    }
    
    struct SortMode: Equatable {
        let property: Property
        let direction: Direction
    }
    
    struct SortAction {
        let mode: SortMode
        let title: String
    }
    
}

extension ReceivedCardsVM.SortMode {
    enum Property {
        case firstName, lastName, receivingDate
    }

    enum Direction {
        case ascending, descending
    }
}

private extension CardFrontBackView.Style {
    var motionDataUpdateInterval: TimeInterval {
        switch self {
        case .compact: return 0.1
        case .expanded: return 0.2
        }
    }
}
