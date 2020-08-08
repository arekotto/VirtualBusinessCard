//
//  EditCardCoordinator.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardCoordinator: Coordinator {

    let navigationController: UINavigationController

    private let userID: UserID
    private var card: EditPersonalBusinessCardMC
    private var images: Images!

    init(navigationController: UINavigationController, userID: UserID, businessCard: EditPersonalBusinessCardMC? = nil) {
        self.navigationController = navigationController
        self.userID = userID
        if let card = businessCard {
            self.card = card
        } else {
            self.card = EditPersonalBusinessCardMC()
            self.images = Images(front: UIImage(), back: UIImage(), texture: Asset.Images.PrebundledTexture.texture1.image)
        }
    }

    func start(completion: @escaping (Result<Void, Error>) -> Void) {
        if images != nil {
            completion(.success(()))
            pushEditCardImagesVC()
        } else {
            let cardData = card.cardData
            let fetchImages = ImageAndTextureFetchTask(imageURLs: [cardData.frontImage.url, cardData.backImage.url, card.texture.image.url], tag: 0, forceRefresh: true)
            fetchImages { [weak self] result, _ in
                guard let self = self else { return }
                switch result {
                case .success(let images):
                    self.images = Images(front: images[0], back: images[1], texture: images[2])
                    self.pushEditCardImagesVC()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func pushEditCardImagesVC() {
        let vc = EditCardImagesVC(viewModel: EditCardImagesVM(userID: userID, frontImage: images.front, backImage: images.back))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: false)
    }
}

// MARK: - EditCardImagesVCDelegate

extension EditCardCoordinator: EditCardImagesVCDelegate {
    func editCardImagesVC(_: EditCardImagesVC, didFinishWith frontImage: UIImage, and backImage: UIImage) {
        let cardProperties = EditCardPhysicalVM.CardPhysicalProperties(
            texture: images.texture,
            specular: card.texture.specular,
            normal: card.texture.normal,
            cornerRadiusHeightMultiplier: card.cornerRadiusHeightMultiplier,
            hapticSharpness: card.cardData.hapticFeedbackSharpness
        )
        images.front = frontImage
        images.back = backImage
        let vc = EditCardPhysicalVC(viewModel: EditCardPhysicalVM(frontCardImage: frontImage, backCardImage: backImage, physicalCardProperties: cardProperties))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EditCardPhysicalVCDelegate

extension EditCardCoordinator: EditCardPhysicalVCDelegate {
    func editCardPhysicalVC(_ editCardPhysicalVC: EditCardPhysicalVC, didFinishWith properties: EditCardPhysicalVM.CardPhysicalProperties) {
        let transformableData = EditCardInfoVM.TransformableData(position: card.position, name: card.name, contact: card.contact, address: card.address)
        let vc = EditCardInfoVC(viewModel: EditCardInfoVM(transformableData: transformableData))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EditCardInfoVCDelegate

extension EditCardCoordinator: EditCardInfoVCDelegate {
    func editCardInfoVC(_ viewController: EditCardInfoVC, didFinishWith transformedData: EditCardInfoVM.TransformableData) {

    }
}

private extension EditCardCoordinator {
    struct Images {
        var front: UIImage?
        var back: UIImage?
        var texture: UIImage
    }
}
