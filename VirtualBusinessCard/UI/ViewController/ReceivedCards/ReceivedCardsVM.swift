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
    func refreshData()
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
    private let userID: UserID

    private var user: UserMC?
    private var cards = [ReceivedBusinessCardMC]()
    private var displayedCardIndexes = [Int]()
    
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    init(userID: UserID, title: String, dataFetchMode: DataFetchMode) {
        self.userID = userID
        self.title = title
        self.dataFetchMode = dataFetchMode
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
        delegate?.presentCardDetails(viewModel: CardDetailsVM(userID: userID, cardID: card.id))
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
        if query.isEmpty {
            displayedCardIndexes = Array(0 ..< cards.count)
        } else {
            displayedCardIndexes = cards.enumerated()
                .filter { _, card in Self.shouldDisplayCard(card, forQuery: query) }
                .map { idx, _ in idx }
        }
        delegate?.refreshData()
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
    private var userPublicDocumentReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userID)
    }
    
    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
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
        receivedCardsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.receivedCardsCollectionDidChange(querySnapshot: querySnapshot, error: error)
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
    
    private func receivedCardsCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        switch dataFetchMode {
        case .allReceivedCards: cards = Self.mapAllCards(from: querySnap)
        case .specifiedIDs(let ids): cards = Self.mapCards(from: querySnap, containedIn: ids)
        }
        displayedCardIndexes = Array(0 ..< cards.count)
        delegate?.refreshData()
    }
}

// MARK: - CellSizeMode & DataFetchMode

extension ReceivedCardsVM {    
    enum DataFetchMode {
        case allReceivedCards
        case specifiedIDs(_ ids: [BusinessCardID])
    }
}
