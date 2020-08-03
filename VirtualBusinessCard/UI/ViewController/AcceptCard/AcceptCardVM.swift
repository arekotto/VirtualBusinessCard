//
//  AcceptCardVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

protocol AcceptCardVMDelegate: class {
    func presentSaveOfflineAlert()
    func presentErrorAlert(message: String)
    func dismissSelf()
    func popSelf()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func refreshTags()
    func refreshNotes()
}

final class AcceptCardVM: PartialUserViewModel, MotionDataSource {

    weak var delegate: AcceptCardVMDelegate?

    let card: EditReceivedBusinessCardMC

    private(set) var hasSavedCardToCollection = false
    private(set) lazy var motionManager = CMMotionManager()

    private var acceptedCard = SingleTimeToggleBool(ofInitialValue: false)
    private lazy var selectedTags: [BusinessCardTagMC]? = nil

    init(userID: UserID, sharedCard: EditReceivedBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }
}

// MARK: - ViewController API

extension AcceptCardVM {

    var hasAcceptedCard: Bool { acceptedCard.value }

    var addNoteImage: UIImage {
        UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    }

    var addTagImage: UIImage {
        UIImage(systemName: "tag", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    }

    var selectedTagColors: [UIColor] {
        selectedTags?.map(\.displayColor) ?? []
    }

    var notes: String {
        card.notes
    }

    func willAppear() {
        startUpdatingMotionData(in: 0.1)
    }

    func dataModel() -> CardFrontBackView.URLDataModel {
        let texture = card.cardData.texture
        return CardFrontBackView.URLDataModel(
            frontImageURL: card.cardData.frontImage.url,
            backImageURL: card.cardData.backImage.url,
            textureImageURL: texture.image.url,
            normal: CGFloat(texture.normal),
            specular: CGFloat(texture.specular)
        )
    }

    func acceptCard() {
        acceptedCard.toggle()
        card.save(in: receivedCardsCollectionReference) { [weak self] result in
            switch result {
            case .success: self?.hasSavedCardToCollection = true
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
    }

    func finishAcceptingProcess() {
        guard hasAcceptedCard else { return }
        guard hasSavedCardToCollection else {
            delegate?.presentSaveOfflineAlert()
            return
        }
        delegate?.dismissSelf()
    }

    func shareCardAgain() {
        guard hasAcceptedCard else { return }
        guard hasSavedCardToCollection else {
            delegate?.presentSaveOfflineAlert()
            return
        }
        delegate?.popSelf()
    }

    func editCardNotesVM() -> EditCardNotesVM {
        let vm = EditCardNotesVM(notes: card.notes)
        vm.editingDelegate = self
        return vm
    }

    func editCardTagsVM() -> EditCardTagsVM {
        let vm = EditCardTagsVM(userID: userID, selectedTagIDs: card.tagIDs)
        vm.selectionDelegate = self
        return vm
    }
}

// MARK: - Firebase

extension AcceptCardVM {
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
}

// MARK: - EditCardTagsVMSelectionDelegate

extension AcceptCardVM: EditCardTagsVMSelectionDelegate {
    func didChangeSelectedTags(to tags: [BusinessCardTagMC]) {
        selectedTags = tags
        card.tagIDs = tags.map(\.id)
        card.save(in: receivedCardsCollectionReference, fields: [.tagIDs]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        delegate?.refreshTags()
    }
}

// MARK: - EditCardNotesVMEditingDelegate

extension AcceptCardVM: EditCardNotesVMEditingDelegate {
    func didEditNotes(to editedNotes: String) {
        card.notes = editedNotes
        card.save(in: receivedCardsCollectionReference, fields: [.notes]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        delegate?.refreshNotes()
    }
}
