//
//  EditCardCoordinator.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

final class EditCardCoordinator: Coordinator {

    static let uploadTaskTimeoutSeconds = 10

    let navigationController: UINavigationController

    private var card: EditPersonalBusinessCardLocalizationMC
    private var originalImages: Images!
    private var newImages: Images?
    private var storage = Storage.storage().reference()
    private let collectionReference: CollectionReference
    private let title: String

    init(collectionReference: CollectionReference, navigationController: UINavigationController, userID: UserID, mode: Mode) {
        self.collectionReference = collectionReference
        self.navigationController = navigationController

        switch mode {
        case .newCard:
            self.card = EditPersonalBusinessCardLocalizationMC(userID: userID)
            originalImages = Images()
            title = NSLocalizedString("New Card", comment: "")
        case .newLocalization(let card, let localizationLanguageCode):
            self.card = card.editPersonalBusinessCardLocalizationMC(userID: userID, newLocalizationLanguageCode: localizationLanguageCode)
            originalImages = Images()
            let titleFormat = NSLocalizedString("New %@ Localization", comment: "")
            title = String.localizedStringWithFormat(titleFormat, Locale.current.localizedString(forLanguageCode: localizationLanguageCode) ?? "")
        case .editLocalization(let card, let localizationID):
            self.card = card.editPersonalBusinessCardLocalizationMC(userID: userID, editedLocalizationID: localizationID)
            if let langCode = card.localization(withID: localizationID)?.languageCode {
                let titleFormat = NSLocalizedString("Edit %@ Localization", comment: "")
                let localizationName = Locale.current.localizedString(forLanguageCode: langCode) ?? ""
                title = String.localizedStringWithFormat(titleFormat, localizationName)
            } else {
                title = NSLocalizedString("Edit Card", comment: "")
            }
        }
    }

    func start(completion: @escaping (Result<Void, Error>) -> Void) {
        if originalImages != nil {
            completion(.success(()))
            pushEditCardImagesVC()
        } else {
            let localization = card.editedLocalization
            let fetchImages = ImageAndTextureFetchTask(imageURLs: [localization.frontImage.url, localization.backImage.url, card.texture.image.url], tag: 0, forceRefresh: true)
            fetchImages { [weak self] result, _ in
                guard let self = self else { return }
                switch result {
                case .success(let images):
                    self.originalImages = Images(front: images[0], back: images[1], texture: images[2])
                    self.pushEditCardImagesVC()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func pushEditCardImagesVC() {
        let vc = EditCardImagesVC(viewModel: EditCardImagesVM(subtitle: title, frontImage: originalImages.front, backImage: originalImages.back))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: false)
    }

    private func updateCard(properties: EditCardPhysicalVM.CardPhysicalProperties) {
        newImages?.texture = properties.texture
        card.cornerRadiusHeightMultiplier = properties.cornerRadiusHeightMultiplier
        card.texture.specular = properties.specular
        card.texture.normal = properties.normal
        card.editedLocalization.hapticFeedbackSharpness = properties.hapticSharpness
    }

    private func updateCard(transformedData: EditCardInfoVM.TransformableData) {
        card.address = transformedData.address
        card.contact = transformedData.contact
        card.name = transformedData.name
        card.position = transformedData.position
    }

    private func updateCard(images: UploadedImages) {
        if let frontImage = images.front {
            self.card.frontImage = frontImage
        }
        if let backImage = images.back {
            self.card.backImage = backImage
        }
        if let texture = images.texture {
            self.card.texture.image = texture
        }
    }
}

// MARK: - EditCardImagesVCDelegate

extension EditCardCoordinator: EditCardImagesVCDelegate {

    func editCardImagesVC(_ viewController: EditCardImagesVC, didFinishWith frontImage: UIImage, and backImage: UIImage) {
        let cardProperties = EditCardPhysicalVM.CardPhysicalProperties(
            texture: originalImages.texture ?? Asset.Images.BundledTexture.texture1.image,
            specular: card.texture.specular,
            normal: card.texture.normal,
            cornerRadiusHeightMultiplier: card.cornerRadiusHeightMultiplier,
            hapticSharpness: card.editedLocalization.hapticFeedbackSharpness
        )
        newImages = Images(front: frontImage, back: backImage, texture: nil)
        let vc = EditCardPhysicalVC(viewModel: EditCardPhysicalVM(subtitle: title, frontCardImage: frontImage, backCardImage: backImage, physicalCardProperties: cardProperties))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EditCardPhysicalVCDelegate

extension EditCardCoordinator: EditCardPhysicalVCDelegate {

    func editCardPhysicalVC(_ editCardPhysicalVC: EditCardPhysicalVC, didFinishWith properties: EditCardPhysicalVM.CardPhysicalProperties) {
        updateCard(properties: properties)

        let transformableData = EditCardInfoVM.TransformableData(position: card.position, name: card.name, contact: card.contact, address: card.address)
        let vc = EditCardInfoVC(viewModel: EditCardInfoVM(subtitle: title, transformableData: transformableData))
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - UploadedImages & Images

private extension EditCardCoordinator {

    private struct UploadedImages {
        var front: BusinessCardLocalization.Image?
        var back: BusinessCardLocalization.Image?
        var texture: BusinessCardLocalization.Image?
    }

    struct Images {
        var front: UIImage?
        var back: UIImage?
        var texture: UIImage?
    }
}

// MARK: - EditCardInfoVCDelegate

extension EditCardCoordinator: EditCardInfoVCDelegate {

    func editCardInfoVC(_ viewController: EditCardInfoVC, didFinishWith transformedData: EditCardInfoVM.TransformableData) {
        guard let newImages = self.newImages else { return }

        viewController.presentLoadingAlert(title: NSLocalizedString("Saving Card", comment: ""))

        DispatchQueue.global().async {
            self.updateCard(transformedData: transformedData)
            self.uploadImages(newImages: newImages) { result in
                switch result {
                case .failure(let error):
                    print(#file, "Failure uploading images", error.localizedDescription)
                    let errorMessage = NSLocalizedString("We could not upload images of your card. Please check your internet connection and try again.", comment: "")
                    DispatchQueue.main.async {
                        viewController.dismiss(animated: true) {
                            viewController.presentErrorAlert(message: errorMessage)
                        }
                    }
                case .success(let images):
                    self.updateCard(images: images)

                    self.collectionReference.firestore.runTransaction { [weak self] transaction, errorPointer in
                        guard let self = self else { return nil }
                        self.card.save(using: transaction, in: self.collectionReference)
                        return nil
                    } completion: { [weak self] _, error in
                        if error != nil {
                            let errorMessage = NSLocalizedString("We could not upload your card details. Please check your internet connection and try again.", comment: "")
                            print(#file, error?.localizedDescription ?? "")
                            viewController.dismiss(animated: true) {
                                viewController.presentErrorAlert(message: errorMessage)
                            }
                        } else {
                            viewController.dismiss(animated: true) {
                                self?.navigationController.dismiss(animated: true)
                            }
                        }
                    }
                }
            }

        }

    }

    private func uploadImages(newImages: Images, completion: @escaping (Result<EditCardCoordinator.UploadedImages, Error>) -> Void) {

        var uploadedImages = UploadedImages()
        var encounteredError: Error?

        let dispatchGroup = DispatchGroup()

        [Int](0...2).forEach { _ in dispatchGroup.enter() }

        DispatchQueue.global().async {
            if let newImage = newImages.front, let newImageData = newImage.pngData(), newImageData != self.originalImages.front?.pngData() {
                self.replaceImage(newImageData: newImageData, originalImagePath: self.card.frontImageStoragePath) { result in
                    switch result {
                    case .success(let image): uploadedImages.front = image
                    case .failure(let error): encounteredError = error
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }

        DispatchQueue.global().async {
            if let newImage = newImages.texture, let newImageData = newImage.pngData(), newImageData != self.originalImages.texture?.pngData() {
                self.replaceImage(newImageData: newImageData, originalImagePath: self.card.textureImageStoragePath) { result in
                    switch result {
                    case .success(let image): uploadedImages.texture = image
                    case .failure(let error): encounteredError = error
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }

        DispatchQueue.global().async {
            if let newImage = newImages.back, let newImageData = newImage.pngData(), newImageData != self.originalImages.back?.pngData() {
                self.replaceImage(newImageData: newImageData, originalImagePath: self.card.backImageStoragePath) { result in
                    switch result {
                    case .success(let image): uploadedImages.back = image
                    case .failure(let error): encounteredError = error
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(uploadedImages))
            }
        }
    }

    private func replaceImage(newImageData: Data, originalImagePath: String?, completion: @escaping (Result<BusinessCardLocalization.Image, Error>) -> Void) {

        let newImageID = UUID().uuidString
        let cardFolderPath = card.imageStoragePath
        let imageRef = storage.child("\(cardFolderPath)/\(newImageID)")

        var isTaskCompleted = false
        let uploadTask = imageRef.putData(newImageData, metadata: nil) { _, error in
            isTaskCompleted = true
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                if let originalImagePath = originalImagePath {
                    self.storage.child(originalImagePath).delete { error in
                        if let err = error {
                            print("Replaced image could not be deleted:", err.localizedDescription)
                        }
                    }
                }
                completion(.success(BusinessCardLocalization.Image(id: newImageID, url: downloadURL)))
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Self.uploadTaskTimeoutSeconds)) {
            if !isTaskCompleted {
                uploadTask.cancel()
            }
        }
    }
}

// MARK: - Mode

extension EditCardCoordinator {
    enum Mode {
        case newCard
        case newLocalization(card: PersonalBusinessCardMC, localizationLanguageCode: String)
        case editLocalization(card: PersonalBusinessCardMC, localizationID: UUID)
    }
}
