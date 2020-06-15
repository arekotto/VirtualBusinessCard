//
//  PersonalBusinessCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import CoreMotion
import CoreGraphics

protocol PersonalBusinessCardsVMlDelegate: class {
    func presentUserSetup(userID: String, email: String)
    func presentBusinessCardDetails(id: BusinessCardID)
    func reloadData()
    func didUpdateMotionData(motion: CMDeviceMotion)
}

final class PersonalBusinessCardsVM: AppViewModel {
    
    weak var delegate: PersonalBusinessCardsVMlDelegate? {
        didSet {
            if delegate != nil {
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
                    guard let motion = motion else { return }
                    self?.delegate?.didUpdateMotionData(motion: motion)
                }
            } else {
                motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    let title = NSLocalizedString("Personal Cards", comment: "")
    
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    private var user: UserMC?
    private var businessCards: [ViewBusinessCardMC] = []
    
    private var userID: UserID {
        Auth.auth().currentUser!.uid
    }
    
    private var userPublicDocumentReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userID)
    }
    
    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    private var businessCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCard.collectionName)
    }
    
    func fetchData() {
        userPublicDocumentReference.addSnapshotListener(userPublicDidChange)
    }
    
    func numberOfItems() -> Int {
        businessCards.count
    }
    
    func item(for indexPath: IndexPath) -> PersonalBusinessCardsView.BusinessCardCellDM {
        let bc = businessCards[indexPath.item]
        return PersonalBusinessCardsView.BusinessCardCellDM(frontImageURL: bc.frontImage?.url, backImageURL: bc.backImage?.url, textureImageURL: bc.texture?.image.url, normal: CGFloat(bc.texture?.normal ?? 0), specular: CGFloat(bc.texture?.specular ?? 0))
    }

    func didSelectItem(at indexPath: IndexPath) {
        delegate?.presentBusinessCardDetails(id: businessCards[indexPath.item].id)
    }
    
    private func userPublicDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user public changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        
        guard doc.exists else {
            let currentUser = Auth.auth().currentUser!
            delegate?.presentUserSetup(userID: currentUser.uid, email: currentUser.email!)
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
            self?.businessCardCollectionDidChange(querySnapshot: querySnapshot, error: error)
        }
    }
    
    private func userPrivateDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user private changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        user?.setUserPrivate(document: doc)
//        user?.personalBusinessCardIDs.forEach { id in
//            //            if !events.contains(where: {$0.id == id}) {
//            //                eventCollection.document(id).addSnapshotListener(eventHasChanged)
//            //            }
//        }
        delegate?.reloadData()
    }
    
    private func businessCardCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        businessCards = querySnap.documents.compactMap {
            guard let bc = BusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return ViewBusinessCardMC(businessCard: bc)
        }
        delegate?.reloadData()
    }
}
