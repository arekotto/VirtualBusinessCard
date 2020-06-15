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
        
        static private let shareButtonTopConstraintValue: CGFloat = 60

        private let frontSceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView(dynamicLightingEnabled: false)
            view.layer.shadowOpacity = 0.4
            view.layer.shadowRadius = 12
            return view
        }()
        
        private let backSceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView(dynamicLightingEnabled: false)
            view.layer.shadowOpacity = 0.4
            view.layer.shadowRadius = 12
            return view
        }()
        
        private let shareButton: UIButton = {
            let button = UIButton()
            button.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
            button.titleLabel?.font = .appDefault(size: 20, weight: .semibold, design: .rounded)
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
            button.setImage(UIImage(systemName: "square.and.arrow.up.fill", withConfiguration: imgConfig), for: .normal)
            button.layer.cornerRadius = 14
            button.layer.shadowOpacity = 0.35
            button.layer.shadowRadius = 10
            button.layer.shadowOffset = CGSize(width: 0, height: 6)
            button.imageEdgeInsets = UIEdgeInsets(top: 4, left: -12, bottom: 4, right: 12)
            return button
        }()
        
        private let scalableView = UIView()
        
        private(set) var shareButtonTopConstraint: NSLayoutConstraint!
        private(set) var frontSceneXConstraint: NSLayoutConstraint!
        private(set) var frontSceneYConstraint: NSLayoutConstraint!
        private(set) var backSceneXConstraint: NSLayoutConstraint!
        private(set) var backSceneYConstraint: NSLayoutConstraint!
        
        override func configureSubviews() {
            super.configureSubviews()
            [backSceneView, frontSceneView, shareButton].forEach { scalableView.addSubview($0) }
            contentView.addSubview(scalableView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            
            let screenWidth = UIScreen.main.bounds.size.width
            let dimensions = CGSize.businessCardSize(width: screenWidth * 0.75)
            
            scalableView.constrainVerticallyToSuperview()
            scalableView.constrainCenterXToSuperview()
            scalableView.constrainWidth(constant: screenWidth * 0.8)
            
            frontSceneView.constrainHeight(constant: dimensions.height)
            frontSceneView.constrainWidth(constant: dimensions.width)
            frontSceneXConstraint = frontSceneView.constrainCenterXToSuperview()
            frontSceneYConstraint = frontSceneView.constrainCenterYToSuperview()
            
            backSceneView.constrainHeight(constant: dimensions.height)
            backSceneView.constrainWidth(constant: dimensions.width)
            backSceneXConstraint = backSceneView.constrainCenterXToSuperview()
            backSceneYConstraint = backSceneView.constrainCenterYToSuperview()
            
            shareButtonTopConstraint = shareButton.constrainTop(to: frontSceneView.bottomAnchor, constant: Self.shareButtonTopConstraintValue)
            shareButton.constrainWidthGreaterThanOrEqualTo(constant: 150)
            shareButton.constrainHeight(constant: 50)
            shareButton.constrainCenterXToSuperview()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            shareButton.tintColor = .appWhite
            shareButton.layer.shadowColor = UIColor.appAccent.cgColor
            shareButton.backgroundColor = .appAccent
        }
    }
    
    struct BusinessCardCellDM {
        let frontImageURL: URL?
        let backImageURL: URL?
        let textureImageURL: URL?
        let normal: CGFloat
        let specular: CGFloat
    }
}

extension PersonalBusinessCardsView.BusinessCardCell {
    func setDataModel(_ dm: PersonalBusinessCardsView.BusinessCardCellDM) {
        if let frontImageURL = dm.frontImageURL, let backImageURL = dm.backImageURL, let textureURL = dm.textureImageURL {
            let task = ImageAndTextureFetchTask(frontImageURL: frontImageURL, textureURL: textureURL, backImageURL: backImageURL)
            task { [weak self] result in
                switch result {
                case .failure(let err): print(err.localizedDescription)
                case .success(let imagesResult):
                    self?.frontSceneView.setImage(image: imagesResult.frontImage, texture: imagesResult.texture, normal: dm.normal, specular: dm.specular)
                    if let backImage = imagesResult.backImage {
                        self?.backSceneView.setImage(image: backImage, texture: imagesResult.texture, normal: dm.normal, specular: dm.specular)
                    }

                }
            }
        }
    }
    
    func updateMotionData(_ motion: CMDeviceMotion) {
        let deviceRotationInX = max(min(motion.attitude.pitch, deg2rad(90)), deg2rad(0))
        let x = deviceRotationInX / deg2rad(90) * 20 - 10
        let deviceRotationInZ = min(max(motion.attitude.roll, deg2rad(-45)), deg2rad(45))
        let y = deviceRotationInZ * 10 / deg2rad(45)
        
        frontSceneView.layer.shadowOffset = CGSize(width: y, height: -x)
        frontSceneView.updateMotionData(motion: motion)
        
        backSceneView.layer.shadowOffset = CGSize(width: y, height: -x)
        backSceneView.updateMotionData(motion: motion)
    }
}

extension PersonalBusinessCardsView.BusinessCardCell: TransformableView {
    
    static func computeTranslationCurve(progress: CGFloat) -> CGFloat {
        log10(1 + progress * 9)
    }
    
    static func computeShareButtonTransition(progress: CGFloat, multiplier: CGFloat = 1) -> CGFloat {
        1 - max(min(1, progress * multiplier), 0)
    }
    
    static func computeShareButtonTopConstraint(progress: CGFloat) -> CGFloat {
        computeShareButtonTransition(progress: progress) * shareButtonTopConstraintValue
    }
    
    static func computeSceneCenterConstraint(progress: CGFloat) -> CGPoint {
        let value = computeShareButtonTransition(progress: progress) * 10
        return CGPoint(x: value, y: value)
    }
        
    private var minScale: CGFloat { 0.6 }
    
    private var scaleRatio: CGFloat { 0.4 }
    
    private var maxScale: CGFloat { 1 }
  
    private var translationRatio: CGPoint { CGPoint(x: 0.66, y: 0.2) }
    
    private var maxTranslationRatio: CGPoint { CGPoint(x: 5, y: 5) }

    private var minTranslationRatio: CGPoint { CGPoint(x: -5, y: -5) }

    func transform(progress: CGFloat) {
        let absProgress = abs(progress)
        applyScaleAndTranslation(progress: progress)
        shareButton.alpha = Self.computeShareButtonTransition(progress: absProgress, multiplier: 1.6)
        shareButtonTopConstraint.constant = Self.computeShareButtonTopConstraint(progress: absProgress)
        let frontSceneConstraintValues = Self.computeSceneCenterConstraint(progress: absProgress)
        frontSceneXConstraint.constant = -frontSceneConstraintValues.x
        frontSceneYConstraint.constant = -frontSceneConstraintValues.y
        backSceneXConstraint.constant = frontSceneConstraintValues.x
        backSceneYConstraint.constant = frontSceneConstraintValues.y
        
        let shouldEnableLighting = absProgress < 0.8
        backSceneView.dynamicLightingEnabled = shouldEnableLighting
        frontSceneView.dynamicLightingEnabled = shouldEnableLighting
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
