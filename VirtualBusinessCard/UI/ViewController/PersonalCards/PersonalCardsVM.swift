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
}

final class PersonalCardsVM: PartialUserViewModel, MotionDataSource {
    
    weak var delegate: PersonalCardsVMlDelegate?
        
    private(set) lazy var motionManager = CMMotionManager()
    
    private var user: UserMC?
    private var cards: [PersonalBusinessCardMC] = []

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }

    private func cardForCell(at indexPath: IndexPath) -> PersonalBusinessCardMC {
        cards[indexPath.item]
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

    func settingsViewModel() -> SettingsVM {
        SettingsVM(userID: userID)
    }

    func newCardViewModel() -> EditCardImagesVM {
        EditCardImagesVM(userID: userID)
    }

    func sharingViewModel(for indexPath: IndexPath) -> DirectSharingVM {
        DirectSharingVM(userID: userID, sharedCard: cardForCell(at: indexPath))
    }
    
    func numberOfItems() -> Int {
        cards.count
    }
    
    func item(for indexPath: IndexPath) -> PersonalCardsView.CollectionCell.DataModel {
        let card = cardForCell(at: indexPath)
        return PersonalCardsView.CollectionCell.DataModel(
            frontImageURL: card.frontImage.url,
            backImageURL: card.backImage.url,
            textureImageURL: card.texture.image.url,
            normal: CGFloat(card.texture.normal),
            specular: CGFloat(card.texture.specular)
        )
    }
    
    func didSelectItem(at indexPath: IndexPath) {
//        let card = cardForCell(at: indexPath)
//        delegate?.presentCardDetails(viewModel: CardDetailsVM(userID: userID, cardID: card.id, initialLoadDataModel: item(for: indexPath)))
    }
}

extension PersonalCardsVM {
    
    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    private var businessCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(PersonalBusinessCard.collectionName)
    }
    
    func fetchData() {
        userPublicDocumentReference.addSnapshotListener { [weak self] document, error in
            self?.userPublicDidChange(document, error)
        }
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
        userPrivateDocumentReference.addSnapshotListener { [weak self] snapshot, error in
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
