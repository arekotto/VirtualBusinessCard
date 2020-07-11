//
//  PersonalCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import CoreMotion
import UIKit

protocol PersonalCardsVMlDelegate: class {
    func presentUserSetup(userID: String, email: String)
    func reloadData()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func presentCardDetails(viewModel: CardDetailsVM)
    func presentSettings(viewModel: SettingsVM)
}

final class PersonalCardsVM: AppViewModel {
    
    weak var delegate: PersonalCardsVMlDelegate? {
        didSet { didSetDelegate() }
    }
        
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    private var user: UserMC?
    private var cards: [PersonalBusinessCardMC] = []
    
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

extension PersonalCardsVM {
    var title: String {
        NSLocalizedString("My Cards", comment: "")
    }
    
    var tabBarIconImage: UIImage {
        UIImage(named: "PersonalCardsIcon")!
    }
    
    var newBusinessCardImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }
    
    var settingsImage: UIImage {
        UIImage(named: "SettingsIcon")!
    }
    
    func numberOfItems() -> Int {
        cards.count
    }
    
    func item(for indexPath: IndexPath) -> PersonalCardsView.BusinessCardCellDM {
        let bc = cards[indexPath.item]
        return PersonalCardsView.BusinessCardCellDM(frontImageURL: bc.frontImage.url, backImageURL: bc.backImage.url, textureImageURL: bc.texture.image.url, normal: CGFloat(bc.texture.normal), specular: CGFloat(bc.texture.specular))
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let card = cards[indexPath.item]
//        delegate?.presentCardDetails(viewModel: CardDetailsVM(userID: userID, cardID: card.id, initialLoadDataModel: item(for: indexPath)))
    }
    
    func didTapSettings() {
        delegate?.presentSettings(viewModel: SettingsVM(userID: userID))
    }
}

extension PersonalCardsVM {
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
        
        cards = querySnap.documents.compactMap {
            guard let bc = PersonalBusinessCard(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return PersonalBusinessCardMC(businessCard: bc)
        }
        delegate?.reloadData()
    }
}
