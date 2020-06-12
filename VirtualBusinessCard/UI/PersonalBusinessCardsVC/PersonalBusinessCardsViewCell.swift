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

        private let sceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView()
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
        
        override func configureSubviews() {
            super.configureSubviews()
            [sceneView, shareButton].forEach { scalableView.addSubview($0) }
            contentView.addSubview(scalableView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            
            let screenWidth = UIScreen.main.bounds.size.width
            let dimensions = CGSize.businessCardSize(width: screenWidth * 0.84)
            
            scalableView.constrainVerticallyToSuperview()
            scalableView.constrainCenterXToSuperview()
            scalableView.constrainWidth(constant: dimensions.width)
            
            sceneView.constrainHeight(constant: dimensions.height)
            sceneView.constrainHorizontallyToSuperview()
            sceneView.constrainCenter(toView: scalableView)
            
            shareButtonTopConstraint = shareButton.constrainTop(to: sceneView.bottomAnchor, constant: Self.shareButtonTopConstraintValue)
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
    
    static func computeShareButtonTransition(progress: CGFloat, multiplier: CGFloat = 1) -> CGFloat {
        1 - max(min(1, progress * multiplier), 0)
    }
        
    private var minScale: CGFloat { 0.6 }
    
    private var scaleRatio: CGFloat { 0.4 }
    
    private var maxScale: CGFloat { 1 }
  
    private var translationRatio: CGPoint { CGPoint(x: 0.66, y: 0.2) }
    
    private var maxTranslationRatio: CGPoint { CGPoint(x: 5, y: 5) }

    private var minTranslationRatio: CGPoint { CGPoint(x: -5, y: -5) }

    func transform(progress: CGFloat) {
        applyScaleAndTranslation(progress: progress)
        shareButton.alpha = Self.computeShareButtonTransition(progress: abs(progress), multiplier: 1.6)
        shareButtonTopConstraint.constant =  Self.computeShareButtonTransition(progress: abs(progress)) * Self.shareButtonTopConstraintValue
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
