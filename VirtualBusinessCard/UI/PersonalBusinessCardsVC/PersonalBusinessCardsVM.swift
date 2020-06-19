//
//  PersonalBusinessCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import CoreMotion
import UIKit

protocol PersonalBusinessCardsVMlDelegate: class {
    func presentUserSetup(userID: String, email: String)
    func presentBusinessCardDetails(id: BusinessCardID)
    func reloadData()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

final class PersonalBusinessCardsVM: AppViewModel {
    
    weak var delegate: PersonalBusinessCardsVMlDelegate? {
        didSet { didSetDelegate() }
    }
        
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    private var user: UserMC?
    private var businessCards: [PersonalBusinessCardMC] = []
    
    private var userID: UserID {
        Auth.auth().currentUser!.uid
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

extension PersonalBusinessCardsVM {
    var title: String {
        NSLocalizedString("My Cards", comment: "")
    }
    
    var tabBarIconImage: UIImage {
        UIImage(named: "PersonalCardsIcon")!
    }
    
    var newBusinessCardImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .large)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }
    
    func numberOfItems() -> Int {
        businessCards.count
    }
    
    func item(for indexPath: IndexPath) -> PersonalBusinessCardsView.BusinessCardCellDM {
        let bc = businessCards[indexPath.item]
        return PersonalBusinessCardsView.BusinessCardCellDM(frontImageURL: bc.frontImage.url, backImageURL: bc.backImage.url, textureImageURL: bc.texture.image.url, normal: CGFloat(bc.texture.normal), specular: CGFloat(bc.texture.specular))
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        delegate?.presentBusinessCardDetails(id: businessCards[indexPath.item].id)
    }
}

extension PersonalBusinessCardsVM {
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
            self?.personalBusinessCardCollectionDidChange(querySnapshot: querySnapshot, error: error)
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
    
    private func personalBusinessCardCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        businessCards = querySnap.documents.compactMap {
            guard let bc = PersonalBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return PersonalBusinessCardMC(businessCard: bc)
        }
        delegate?.reloadData()
    }
}
