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
    
    private let userID: UserID
    
    weak var delegate: GroupedCardsVMDelegate?
    
    private var user: UserMC?
    private var businessCards = [ReceivedBusinessCardMC]()
    
    init(userID: String) {
        self.userID = userID
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
        businessCards.count
    }
    
    func item(for indexPath: IndexPath) -> GroupedCardsView.TableCell.DataModel {
        let bcURL0 = businessCards[optional: 0]?.frontImage.url
        let bcURL1 = businessCards[optional: 1]?.frontImage.url
        let bcURL2 = businessCards[optional: 2]?.frontImage.url
        return GroupedCardsView.TableCell.DataModel(frontImageURL: bcURL0, middleImageURL: bcURL1, backImageURL: bcURL2)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        //        delegate?.presentBusinessCardDetails(id: businessCards[indexPath.item].id)
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
            self?.receivedBusinessCardCollectionDidChange(querySnapshot: querySnapshot, error: error)
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
    
    private func receivedBusinessCardCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        businessCards = querySnap.documents.compactMap {
            guard let bc = ReceivedBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return ReceivedBusinessCardMC(card: bc)
        }
        delegate?.refreshData()
    }
}
