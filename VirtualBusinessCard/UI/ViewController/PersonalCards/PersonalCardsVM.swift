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
    
    private var cards: [PersonalBusinessCardMC] = []
    private var cardsSnapshotListener: ListenerRegistration?

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

    var showsEmptyState: Bool {
        numberOfItems() == 0
    }
    
    var tabBarIconImage: UIImage {
        Asset.Images.Icon.personalCards.image
    }
    
    var newBusinessCardImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }
    
    var settingsImage: UIImage {
        Asset.Images.Icon.settings.image
    }

    func settingsViewModel() -> SettingsVM {
        SettingsVM(userID: userID)
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
            specular: CGFloat(card.texture.specular),
            cornerRadiusHeightMultiplier: CGFloat(card.cornerRadiusHeightMultiplier)
        )
    }

    func personaCardVersionsVM(for indexPath: IndexPath) -> PersonalCardLocalizationsVM {
        PersonalCardLocalizationsVM(userID: userID, cardID: cards[indexPath.row].id)
    }

    func newCardCoordinator(root: AppNavigationController) -> Coordinator {
        EditCardCoordinator(collectionReference: cardCollectionReference, navigationController: root, userID: userID, mode: .newCard)
    }
}

extension PersonalCardsVM {

    private var cardCollectionReference: CollectionReference {
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

        cardsSnapshotListener?.remove()
        cardsSnapshotListener = cardCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.personalBusinessCardCollectionDidChange(querySnapshot: querySnapshot, error: error)
        }
    }

    private func personalBusinessCardCollectionDidChange(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        DispatchQueue.global().async {
            var cards: [PersonalBusinessCardMC] = querySnap.documents.compactMap {
                guard let bc = PersonalBusinessCard(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping business card:", $0.documentID)
                    return nil
                }
                return PersonalBusinessCardMC(businessCard: bc)
            }

            cards.sort { $0.creationDate < $1.creationDate }

            DispatchQueue.main.async {
                self.cards = cards
                self.delegate?.reloadData()
            }
        }
    }
}
