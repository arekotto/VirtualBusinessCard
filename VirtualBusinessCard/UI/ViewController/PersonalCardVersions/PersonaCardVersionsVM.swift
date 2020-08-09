//
//  PersonalCardVersionsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol PersonaCardVersionsVMDelegate: class {
    func refreshData()
}

final class PersonalCardVersionsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PersonalCardVersionsView.TableCell.DataModel>

    weak var delegate: PersonaCardVersionsVMDelegate?
    private let cardID: BusinessCardID

    private var card: PersonalBusinessCardMC?

    init(userID: UserID, cardID: BusinessCardID) {
        self.cardID = cardID
        super.init(userID: userID)
    }
}

// MARK: - ViewController API

extension PersonalCardVersionsVM {

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(card?.languageVersions.map { cellDataModel(for: $0) } ?? [])
        return snapshot
    }

//    func editCardCoordinator(root: AppNavigationController, for indexPath: IndexPath) -> Coordinator {
//        EditCardCoordinator(
//            collectionReference: cardCollectionReference,
//            navigationController: root,
//            userID: userID,
//            businessCard: card.editPersonalBusinessCardMC(userID: userID))
//    }

    private func cellDataModel(for cardData: BusinessCardData) -> PersonalCardVersionsView.TableCell.DataModel {
        PersonalCardVersionsView.TableCell.DataModel(
            title: cardData.languageVersionCode ?? NSLocalizedString("Language not specified", comment: "")
        )
    }
}

// MARK: - Firebase

extension PersonalCardVersionsVM {
    private var cardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(PersonalBusinessCard.collectionName)
    }

    func fetchData() {
        cardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
        }
    }

    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching personal card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        DispatchQueue.global().async {
            guard let card = PersonalBusinessCardMC(documentSnapshot: doc) else {
                print(#file, "Error mapping personal card:", error?.localizedDescription ?? "No error info available.")
                DispatchQueue.main.async {
                    self.card = nil
                    self.delegate?.refreshData()
                }
                return
            }
            DispatchQueue.main.async {
                self.card = card
                self.delegate?.refreshData()
            }
        }
    }

}

// MARK: - Section

extension PersonalCardVersionsVM {
    enum Section {
        case main
    }
}
