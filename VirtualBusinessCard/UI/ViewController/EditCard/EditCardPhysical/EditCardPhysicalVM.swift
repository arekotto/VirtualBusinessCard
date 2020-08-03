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

    private(set) var selectedTexture: UIImage
    var specular: CGFloat = 0.5
    var normal: CGFloat = 0.5
    var cornerRadius: CGFloat = 0.5

    init(userID: UserID, frontCardImage: UIImage, backCardImage: UIImage) {
        images = (frontCardImage, backCardImage)
        selectedTexture = preloadedTextures.first!
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
        guard let itemIdx = preloadedTextures.firstIndex(of: selectedTexture) else { return nil }
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
        selectedTexture = preloadedTextures[indexPath.item]
    }

    func dataModel() -> CardFrontBackView.ImageDataModel {
        return CardFrontBackView.ImageDataModel(
            frontImage: images.cardFront,
            backImage: images.cardBack,
            textureImage: selectedTexture,
            normal: normal,
            specular: specular
        )
    }
}
