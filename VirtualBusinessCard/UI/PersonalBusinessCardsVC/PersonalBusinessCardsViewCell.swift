//
//  PersonalBusinessCardsViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Kingfisher
import UIKit
import CollectionViewPagingLayout
import CoreMotion

extension PersonalBusinessCardsView {
    class BusinessCardCell: AppCollectionViewCell, Reusable {
        
        private let sceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView()
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.3
            view.layer.shadowRadius = 12
            return view
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(sceneView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            let screenWidth = UIScreen.main.bounds.size.width
            let dimensions = CGSize.businessCardSize(width: screenWidth * 0.7)
            sceneView.constrainHeight(constant: dimensions.height)
            sceneView.constrainWidth(constant: dimensions.width)
            sceneView.constrainCenter(toView: contentView)
        }
        
        func setDataModel(_ dataModel: BusinessCardCellDM) {
            if let imageURL = dataModel.imageURL, let textureURL = dataModel.textureImageURL {
                let task = ImageAndTextureFetchTask(imageURL: imageURL, textureURL: textureURL)
                task { [weak self] result in
                    switch result {
                    case .success(let imagesResult): self?.sceneView.setImage(image: imagesResult.image, texture: imagesResult.texture)
                    case .failure(let err): print(err.localizedDescription)
                    }
                }
            }
        }
        
        func updateMotionData(_ motion: CMDeviceMotion) {
            let deviceRotationInX = max(min(motion.attitude.pitch, deg2rad(90)), deg2rad(0))
            let x = deviceRotationInX / deg2rad(90) * 20 - 10
            let deviceRotationInZ = min(max(motion.attitude.roll, deg2rad(-45)), deg2rad(45))
            let y = deviceRotationInZ * 10 / deg2rad(45)
            sceneView.layer.shadowOffset = CGSize(width: y, height: -x)
            sceneView.updateMotionData(motion: motion)
        }
    }
    
    struct BusinessCardCellDM {
        let imageURL: URL?
        let textureImageURL: URL?
    }
}

extension PersonalBusinessCardsView.BusinessCardCell: TransformableView {
    
    static func computeTranslationCurve(progress: CGFloat) -> CGFloat {
        log10(1 + progress * 9)
    }
    
    private var scalableView: UIView { sceneView }
    
    private var minScale: CGFloat { 0.6 }
    
    private var scaleRatio: CGFloat { 0.4 }
    
    private var maxScale: CGFloat { 1 }
  
    private var translationRatio: CGPoint { CGPoint(x: 0.66, y: 0.2) }
    
    private var maxTranslationRatio: CGPoint { CGPoint(x: 5, y: 5) }

    private var minTranslationRatio: CGPoint { CGPoint(x: -5, y: -5) }

    func transform(progress: CGFloat) {
        applyScaleAndTranslation(progress: progress)
    }
    
    private func applyScaleAndTranslation(progress: CGFloat) {
        var transform = CGAffineTransform.identity
        var xAdjustment: CGFloat = 0
        var yAdjustment: CGFloat = 0
        let scaleProgress = Self.computeTranslationCurve(progress: abs(progress))
        var scale = 1 - scaleProgress * scaleRatio
        scale = max(scale, minScale)
        scale = min(scale, maxScale)
        
        xAdjustment = ((1 - scale) * scalableView.bounds.width) / 2
        if progress > 0 {
            xAdjustment *= -1
        }
        
        yAdjustment = ((1 - scale) * scalableView.bounds.height) / 2
        
        let translateProgress = abs(progress)
        var translateX = scalableView.bounds.width * translationRatio.x * (translateProgress * (progress < 0 ? -1 : 1)) - xAdjustment
        var translateY = scalableView.bounds.height * translationRatio.y * abs(translateProgress) - yAdjustment
        translateX = max(translateX, scalableView.bounds.width * minTranslationRatio.x)
        translateY = max(translateY, scalableView.bounds.height * minTranslationRatio.y)
        translateX = min(translateX, scalableView.bounds.width * maxTranslationRatio.x)
        translateY = min(translateY, scalableView.bounds.height * maxTranslationRatio.y)
        transform = transform.translatedBy(x: translateX, y: translateY).scaledBy(x: scale, y: scale)
        scalableView.transform = transform
    }
}
