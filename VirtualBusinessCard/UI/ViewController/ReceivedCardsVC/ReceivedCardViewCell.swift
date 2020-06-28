//
//  ReceivedBusinessCardViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

extension ReceivedCardsView {
    final class BusinessCardCell: AppCollectionViewCell, Reusable {
        
        private let frontSceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView(dynamicLightingEnabled: true)
            return view
        }()
        
        private let backSceneView: BusinessCardSceneView = {
            let view = BusinessCardSceneView(dynamicLightingEnabled: true)
            return view
        }()
        
        private var allSceneViews: [BusinessCardSceneView] {
            [backSceneView, frontSceneView]
        }
                
        private(set) var frontSceneXConstraint: NSLayoutConstraint!
        private(set) var frontSceneYConstraint: NSLayoutConstraint!
        private(set) var backSceneXConstraint: NSLayoutConstraint!
        private(set) var backSceneYConstraint: NSLayoutConstraint!
        
        override func configureCell() {
            super.configureCell()
//            contentView.layer.shadowRadius = 4
//            contentView.layer.shadow
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            allSceneViews.forEach { contentView.addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
                        
            let estimatedCardTargetSize = CGSize.businessCardSize(width: UIScreen.main.bounds.width * 0.8)

            frontSceneView.constrainLeadingToSuperview()
            frontSceneView.constrainTopToSuperview()
            
            backSceneView.constrainTrailingToSuperview()
            backSceneView.constrainBottomToSuperview()
            
            allSceneViews.forEach {
                $0.constrainHeightLessThan(contentView)
                $0.constrainHeight(constant: estimatedCardTargetSize.height, priority: .defaultHigh)
                $0.constrainWidthLessThan(contentView)
                $0.constrainWidth(constant: estimatedCardTargetSize.width, priority: .defaultHigh)
            }
        }
    }
    
    // MARK: BusinessCardCellDM
    
    struct BusinessCardCellDM {
        let frontImageURL: URL
        let backImageURL: URL
        let textureImageURL: URL
        let normal: CGFloat
        let specular: CGFloat
    }
}

// MARK: API

extension ReceivedCardsView.BusinessCardCell {
    
    func setDataModel(_ dm: ReceivedCardsView.BusinessCardCellDM) {
        let task = ImageAndTextureFetchTask(frontImageURL: dm.frontImageURL, textureURL: dm.textureImageURL, backImageURL: dm.backImageURL)
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
    
    func updateMotionData(_ motion: CMDeviceMotion, over timeInterval: TimeInterval) {
        let deviceRotationInX = max(min(motion.attitude.pitch, deg2rad(90)), deg2rad(0))
        let x = deviceRotationInX / deg2rad(90) * 20 - 10
        let deviceRotationInZ = min(max(motion.attitude.roll, deg2rad(-45)), deg2rad(45))
        let y = deviceRotationInZ * 10 / deg2rad(45)
        
        animateShadow(to: CGSize(width: y, height: -x), over: timeInterval)

        allSceneViews.forEach { $0.updateMotionData(motion: motion, over: timeInterval) }
    }
    
    private func animateShadow(to offset: CGSize, over duration: TimeInterval) {
        allSceneViews.forEach {
            let animation = CABasicAnimation(keyPath: "shadowOffset")
            animation.fromValue = $0.layer.shadowOffset
            animation.toValue = offset
            animation.duration = duration
            $0.layer.add(animation, forKey: animation.keyPath)
            $0.layer.shadowOffset = offset
        }
    }
    
    func setSizeMode(_ sizeMode: ReceivedCardsVM.CellSizeMode) {
        switch sizeMode {
        case .compact:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 6
                $0.layer.shadowOpacity = 0.2
            }

//            backSceneView.dynamicLightingEnabled = false
//            frontSceneView.dynamicLightingEnabled = false
//            backSceneView.clipsToBounds = true
//            frontSceneView.clipsToBounds = true
        case .expanded:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 12
                $0.layer.shadowOpacity = 0.4
            }
//            backSceneView.dynamicLightingEnabled = true
//            frontSceneView.dynamicLightingEnabled = true
//            backSceneView.clipsToBounds = false
//            frontSceneView.clipsToBounds = false

        }
    }
}
