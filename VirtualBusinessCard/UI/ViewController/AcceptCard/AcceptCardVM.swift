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
    func presentRejectAlert()
    func presentSaveOfflineAlert()
    func presentErrorAlert(message: String)
    func dismissSelf()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func presentEditCardTagsVC(viewModel: EditCardTagsVM)
    func presentEditCardNotesVC(viewModel: EditCardNotesVM)
    func refreshTags()
    func refreshNotes()
}

final class AcceptCardVM: MotionDataViewModel {

    weak var delegate: AcceptCardVMDelegate?

    let card: EditReceivedBusinessCardMC
    private var acceptedCard = SingleTimeToggleBool(ofInitialValue: false)
    private(set) var hasSavedCardToCollection = false

    private lazy var selectedTags: [BusinessCardTagMC]? = nil

    init(userID: UserID, sharedCard: EditReceivedBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }

    override func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        super.didReceiveMotionData(motion, over: timeFrame)
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

    func dataModel() -> CardFrontBackView.DataModel {
        let texture = card.cardData.texture
        return CardFrontBackView.DataModel(
            frontImageURL: card.cardData.frontImage.url,
            backImageURL: card.cardData.backImage.url,
            textureImageURL: texture.image.url,
            normal: CGFloat(texture.normal),
            specular: CGFloat(texture.specular)
        )
    }

    func didAcceptCard() {
        acceptedCard.toggle()
        card.save(in: receivedCardsCollectionReference) { [weak self] result in
            switch result {
            case .success(): self?.hasSavedCardToCollection = true
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
    }

    func didSelectAddNote() {
        let vm = EditCardNotesVM(notes: card.notes)
        vm.editingDelegate = self
        delegate?.presentEditCardNotesVC(viewModel: vm)
    }

    func didSelectAddTag() {
        let vm = EditCardTagsVM(userID: userID, selectedTagIDs: card.tagIDs)
        vm.selectionDelegate = self
        delegate?.presentEditCardTagsVC(viewModel: vm)
    }

    func didSelectReject() {
        delegate?.presentRejectAlert()
    }

    func didSelectDone() {
        guard hasAcceptedCard else { return }
        guard hasSavedCardToCollection else {
            delegate?.presentSaveOfflineAlert()
            return
        }
        delegate?.dismissSelf()
    }

    func didConfirmReject() {
        delegate?.dismissSelf()
    }

    func didConfirmSaveOffline() {
        delegate?.dismissSelf()
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
            case .success(): return
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
            case .success(): return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        delegate?.refreshNotes()
    }
}
