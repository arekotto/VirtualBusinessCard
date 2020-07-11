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
    func refreshLayout(sizeMode: CardFrontBackView.SizeMode)
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func presentCardDetails(viewModel: CardDetailsVM)
}

final class ReceivedCardsVM: AppViewModel {
    
    weak var delegate: ReceivedBusinessCardsVMDelegate? {
        didSet { didSetDelegate() }
    }

    private(set) var cellSizeMode = CardFrontBackView.SizeMode.expanded
    
    let title: String
    let dataFetchMode: DataFetchMode
    
    private var user: UserMC?
    private var cards = [ReceivedBusinessCardMC]()
    private var displayedCardIndexes = [Int]()
    
    private let sortActions = defaultSortActions()
    
    private(set) lazy var selectedSortMode = sortActions.first!.mode
    
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    init(userID: UserID, title: String, dataFetchMode: DataFetchMode) {
        self.title = title
        self.dataFetchMode = dataFetchMode
        super.init(userID: userID)
    }
    
    private func didSetDelegate() {
        if delegate != nil {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }
                self.delegate?.didUpdateMotionData(motion, over: self.motionManager.deviceMotionUpdateInterval)
            }
        } else {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}

// MARK: - ViewController API

extension ReceivedCardsVM {
    
    var tabBarIconImage: UIImage {
        UIImage(named: "CollectionIcon")!
    }
    
    var cellSizeControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .large)
        switch cellSizeMode {
        case .compact:
            return UIImage(systemName: "square.split.1x2.fill", withConfiguration: imgConfig)!
        case .expanded:
            return UIImage(systemName: "table.fill", withConfiguration: imgConfig)!
        }
    }
    
    var sortControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        return UIImage(systemName: "arrow.up.arrow.down", withConfiguration: imgConfig)!
    }
    
    func numberOfItems() -> Int {
        displayedCardIndexes.count
    }
    
    func item(for indexPath: IndexPath) -> CardFrontBackView.DataModel {
        let cardID = displayedCardIndexes[indexPath.item]
        let cardData = cards[cardID].cardData
        return CardFrontBackView.DataModel(frontImageURL: cardData.frontImage.url, backImageURL: cardData.backImage.url, textureImageURL: cardData.texture.image.url, normal: CGFloat(cardData.texture.normal), specular: CGFloat(cardData.texture.specular))
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let card = cards[indexPath.item]
        delegate?.presentCardDetails(viewModel: CardDetailsVM(userID: userID, cardID: card.id, initialLoadDataModel: item(for: indexPath)))
    }
    
    func didChangeCellSizeMode() {
        switch cellSizeMode {
        case .compact:
            cellSizeMode = .expanded
            motionManager.deviceMotionUpdateInterval = 0.1
        case .expanded:
            motionManager.deviceMotionUpdateInterval = 0.2
            cellSizeMode = .compact
        }
        delegate?.refreshLayout(sizeMode: cellSizeMode)
    }
    
    func didSearch(for query: String) {
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
    
    func didSelectSortMode(_ mode: SortMode) {
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
}

// MARK: - Sorting static helpers

extension ReceivedCardsVM {
    
    private static func defaultSortActions() -> [SortAction] {
        return [
            SortAction(mode: SortMode(property: .firstName, direction: .ascending), title: NSLocalizedString("First name - ascending", comment: "")),
            SortAction(mode: SortMode(property: .firstName, direction: .descending), title: NSLocalizedString("First name - descending", comment: "")),
            SortAction(mode: SortMode(property: .lastName, direction: .ascending), title: NSLocalizedString("Last name - ascending", comment: "")),
            SortAction(mode: SortMode(property: .lastName, direction: .descending), title: NSLocalizedString("Last name - descending", comment: "")),
            SortAction(mode: SortMode(property: .receivingDate, direction: .ascending), title: NSLocalizedString("Receiving date - ascending", comment: "")),
            SortAction(mode: SortMode(property: .receivingDate, direction: .descending), title: NSLocalizedString("Receiving date - descending", comment: ""))
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
        (lhs.cardData.name.first ?? "") <= (rhs.cardData.name.first ?? "")
    }
    
    private static func cardSorterFirstNameDescending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        (lhs.cardData.name.first ?? "") >= (rhs.cardData.name.first ?? "")
    }
    
    private static func cardSorterLastNameAscending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        (lhs.cardData.name.last ?? "") <= (rhs.cardData.name.last ?? "")
    }
    
    private static func cardSorterLastNameDescending(_ lhs: ReceivedBusinessCardMC, _ rhs: ReceivedBusinessCardMC) -> Bool {
        (lhs.cardData.name.last ?? "") >= (rhs.cardData.name.last ?? "")
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
        let name = card.cardData.name
        let names = [name.first ?? "", name.last ?? "", name.middle ?? "" ]
        return names.contains(where: { $0.contains(query) })
    }
}


// MARK: - Firebase fetch

extension ReceivedCardsVM {
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
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
                self.delegate?.refreshData(animated: false)
            }
        }
    }
    
    private func mapAndSortCards(querySnapshot: QuerySnapshot) -> [ReceivedBusinessCardMC] {
        let newCards: [ReceivedBusinessCardMC]
        switch self.dataFetchMode {
        case .allReceivedCards: newCards = Self.mapAllCards(from: querySnapshot)
        case .specifiedIDs(let ids): newCards = Self.mapCards(from: querySnapshot, containedIn: ids)
        }
        return Self.sortCards(newCards, using: self.selectedSortMode)
    }
}

// MARK: - DataFetchMode

extension ReceivedCardsVM {    
    enum DataFetchMode {
        case allReceivedCards
        case specifiedIDs(_ ids: [BusinessCardID])
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
        
        enum Property {
            case firstName, lastName, receivingDate
        }
        
        enum Direction {
            case ascending, descending
        }
    }
    
    struct SortAction {
        let mode: SortMode
        let title: String
    }
    
}
