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
    func presentBusinessCardDetails(id: BusinessCardID)
    func refreshData()
    func refreshLayout(sizeMode: ReceivedCardsVM.CellSizeMode)
    func didUpdateMotionData(motion: CMDeviceMotion)
}

final class ReceivedCardsVM: AppViewModel {
    
    weak var delegate: ReceivedBusinessCardsVMDelegate? {
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
    
    let title = NSLocalizedString("Collection", comment: "")
        
    private(set) var cellSizeMode = CellSizeMode.expanded
    
    var cellSizeControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .large)
        switch cellSizeMode {
        case .compact:
            return UIImage(systemName: "square.split.1x2.fill", withConfiguration: imgConfig)!
        case .expanded:
            return UIImage(systemName: "table.fill", withConfiguration: imgConfig)!
        }
    }
    
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()
    
    private var user: UserMC?
    private var businessCards = [ReceivedBusinessCardMC]()
    
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
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    func fetchData() {
        userPublicDocumentReference.addSnapshotListener() { [weak self] document, error in
            self?.userPublicDidChange(document, error)
        }
    }
    
    func numberOfItems() -> Int {
        businessCards.count
    }
    
    func item(for indexPath: IndexPath) -> ReceivedCardsView.BusinessCardCellDM {
        let bc = businessCards[indexPath.item]
        return ReceivedCardsView.BusinessCardCellDM(frontImageURL: bc.frontImage.url, backImageURL: bc.backImage.url, textureImageURL: bc.texture.image.url, normal: CGFloat(bc.texture.normal), specular: CGFloat(bc.texture.specular))
    }

    func didSelectItem(at indexPath: IndexPath) {
//        delegate?.presentBusinessCardDetails(id: businessCards[indexPath.item].id)
    }
    
    func didChangeCellSizeMode() {
        switch cellSizeMode {
        case .compact: cellSizeMode = .expanded
        case .expanded: cellSizeMode = .compact
        }
        delegate?.refreshLayout(sizeMode: cellSizeMode)
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

extension ReceivedCardsVM {
    enum CellSizeMode {
        case compact, expanded
    }
}
