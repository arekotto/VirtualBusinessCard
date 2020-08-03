//
//  EditCardPhysicalVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

protocol EditCardPhysicalVMDelegate: class {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

final class EditCardPhysicalVM: PartialUserViewModel, MotionDataSource {

    private(set) lazy var motionManager = CMMotionManager()

    private var preloadedTextures: [UIImage] = [
        Asset.Images.PrebundledTexture.texture1.image,
        Asset.Images.PrebundledTexture.texture2.image,
        Asset.Images.PrebundledTexture.texture3.image,
        Asset.Images.PrebundledTexture.texture4.image
    ]

    weak var delegate: EditCardPhysicalVMDelegate?

    let images: (cardFront: UIImage, cardBack: UIImage)

    let specularMax: Float = 2
    let normalMax: Float = 2
    let cornerRadiusHeightMultiplierMax: Float = 0.2
    let hapticSharpnessMax: Float = 1

    var texture: UIImage
    var specular: Float = 0.5
    var normal: Float = 0.5
    var cornerRadiusHeightMultiplier: Float = 0
    var hapticSharpness: Float = 0.5

    init(userID: UserID, frontCardImage: UIImage, backCardImage: UIImage) {
        images = (frontCardImage, backCardImage)
        texture = preloadedTextures.first!
        super.init(userID: userID)
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }
}

// MARK: - ViewController API

extension EditCardPhysicalVM {

    var title: String {
        NSLocalizedString("Edit Texture", comment: "")
    }

    var nextButtonTitle: String {
        NSLocalizedString("Next", comment: "")
    }

    var selectedTextureItemIndexPath: IndexPath? {
        guard let itemIdx = preloadedTextures.firstIndex(of: texture) else { return nil }
        return IndexPath(item: itemIdx)
    }

    func numberOfItems() -> Int {
        preloadedTextures.count
    }

    func textureItem(at indexPath: IndexPath) -> EditCardPhysicalView.TextureCollectionCell.DataModel {
        let texture = preloadedTextures[indexPath.item]
        return EditCardPhysicalView.TextureCollectionCell.DataModel(textureImage: texture)
    }

    func didSelectTextureItem(at indexPath: IndexPath) {
        texture = preloadedTextures[indexPath.item]
    }

    func dataModel() -> CardFrontBackView.ImageDataModel {
        return CardFrontBackView.ImageDataModel(
            frontImage: images.cardFront,
            backImage: images.cardBack,
            textureImage: texture,
            normal: CGFloat(normal),
            specular: CGFloat(specular),
            cornerRadiusHeightMultiplier: CGFloat(cornerRadiusHeightMultiplier)
        )
    }
}
