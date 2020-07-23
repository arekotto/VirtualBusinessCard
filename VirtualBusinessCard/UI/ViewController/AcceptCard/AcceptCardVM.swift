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
    func presentSaveErrorAlert(title: String)
    func dismissSelf()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

final class AcceptCardVM: MotionDataViewModel {

    weak var delegate: AcceptCardVMDelegate?

    let card: EditReceivedBusinessCardMC
    private var acceptedCard = SingleTimeToggleBool(ofInitialValue: false)
    private(set) var hasSavedCardToCollection = false

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
                let errorTitle = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentSaveErrorAlert(title: errorTitle)
            }
        }
    }

    func didSelectAddNote() {

    }

    func didSelectAddTag() {

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

extension AcceptCardVM {
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
}
