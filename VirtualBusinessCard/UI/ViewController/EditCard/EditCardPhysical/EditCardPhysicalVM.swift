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
    func didCalculateSelectedTextureIndexPath(_ indexPath: IndexPath?)
}

final class EditCardPhysicalVM: AppViewModel, MotionDataSource {

    private(set) lazy var motionManager = CMMotionManager()

    weak var delegate: EditCardPhysicalVMDelegate?

    private(set) var subtitle: String

    let images: (cardFront: UIImage, cardBack: UIImage)

    let specularMax: Float = 2
    let normalMax: Float = 2
    let cornerRadiusHeightMultiplierMax: Float = 0.2
    let hapticSharpnessMax: Float = 1

    private(set) var cardProperties: CardPhysicalProperties

    private var preloadedTextures: [UIImage] = [
        Asset.Images.BundledTexture.texture1.image,
        Asset.Images.BundledTexture.texture2.image,
        Asset.Images.BundledTexture.texture3.image,
        Asset.Images.BundledTexture.texture4.image
    ]

    init(subtitle: String, frontCardImage: UIImage, backCardImage: UIImage, physicalCardProperties: CardPhysicalProperties) {
        images = (frontCardImage, backCardImage)
        cardProperties = physicalCardProperties
        self.subtitle = subtitle
        super.init()
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }
}

// MARK: - ViewController API

extension EditCardPhysicalVM {

    var texture: UIImage {
        get { cardProperties.texture }
        set { cardProperties.texture = newValue }
    }

    var specular: Float {
        get { cardProperties.specular }
        set { cardProperties.specular = newValue }
    }

    var normal: Float {
        get { cardProperties.normal }
        set { cardProperties.normal = newValue }
    }

    var cornerRadiusHeightMultiplier: Float {
        get { cardProperties.cornerRadiusHeightMultiplier }
        set { cardProperties.cornerRadiusHeightMultiplier = newValue }
    }

    var hapticSharpness: Float {
        get { cardProperties.hapticSharpness }
        set { cardProperties.hapticSharpness = newValue }
    }

    var title: String {
        NSLocalizedString("Card Properties", comment: "")
    }

    func calculateSelectedIndexPath() {
        DispatchQueue.global().async {
            let textureData = self.texture.pngData()
            let itemIdx = self.preloadedTextures.firstIndex(where: {$0.pngData() == textureData})
            DispatchQueue.main.async {
                self.delegate?.didCalculateSelectedTextureIndexPath(itemIdx != nil ? IndexPath(item: itemIdx!) : nil)
            }
        }
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

// MARK: - CardPhysicalProperties

extension EditCardPhysicalVM {
    struct CardPhysicalProperties {
        var texture: UIImage
        var specular: Float
        var normal: Float
        var cornerRadiusHeightMultiplier: Float
        var hapticSharpness: Float
    }
}
