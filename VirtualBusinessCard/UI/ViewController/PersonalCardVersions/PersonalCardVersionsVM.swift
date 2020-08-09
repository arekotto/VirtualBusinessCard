//
//  PersonalCardVersionsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol PersonalCardVersionsVMDelegate: class {
    func refreshData()
}

final class PersonalCardVersionsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PersonalCardVersionsView.TableCell.DataModel>

    weak var delegate: PersonalCardVersionsVMDelegate?
    private let cardID: BusinessCardID

    private var card: PersonalBusinessCardMC?

    init(userID: UserID, cardID: BusinessCardID) {
        self.cardID = cardID
        super.init(userID: userID)
    }
}

// MARK: - ViewController API

extension PersonalCardVersionsVM {

    var newBusinessCardImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }

    func actionConfig(for indexPath: IndexPath) -> (title: String, deleteTitle: String, isDefault: Bool)? {
        guard let languageVersion = card?.languageVersions[indexPath.row] else { return nil }
        // TODO: change
        return ("testing", "delete", languageVersion.isDefault)
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(card?.languageVersions.map { cellDataModel(for: $0) } ?? [])
        return snapshot
    }

    func newVersionCardCoordinator(root: AppNavigationController) -> Coordinator? {
        guard let card = self.card else { return nil }
        return EditCardCoordinator(
            collectionReference: cardCollectionReference,
            navigationController: root,
            userID: userID,
            card: card
        )
    }

    func editCardCoordinator(for indexPath: IndexPath, root: AppNavigationController) -> Coordinator? {
        guard let card = self.card else { return nil }
        return EditCardCoordinator(
            collectionReference: cardCollectionReference,
            navigationController: root,
            userID: userID,
            card: card,
            editedCardDataID: card.languageVersions[indexPath.row].id
        )
    }

    func deleteLocalization(at indexPath: IndexPath) {
        print("delete")
        // TODO: implemnt
    }

    private func cellDataModel(for cardData: BusinessCardData) -> PersonalCardVersionsView.TableCell.DataModel {
        PersonalCardVersionsView.TableCell.DataModel(
            id: cardData.id,
            title: cardData.languageVersionCode ?? NSLocalizedString("Language not specified", comment: ""),
            isDefault: cardData.isDefault,
            sceneDataModel: CardFrontBackView.URLDataModel(
                frontImageURL: cardData.frontImage.url,
                backImageURL: cardData.backImage.url,
                textureImageURL: cardData.texture.image.url,
                normal: CGFloat(cardData.texture.normal),
                specular: CGFloat(cardData.texture.specular),
                cornerRadiusHeightMultiplier: CGFloat(cardData.cornerRadiusHeightMultiplier)
            )
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
