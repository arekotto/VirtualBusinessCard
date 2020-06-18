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
    class BusinessCardCell: AppCollectionViewCell, Reusable {
        
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
                
        private(set) var frontSceneXConstraint: NSLayoutConstraint!
        private(set) var frontSceneYConstraint: NSLayoutConstraint!
        private(set) var backSceneXConstraint: NSLayoutConstraint!
        private(set) var backSceneYConstraint: NSLayoutConstraint!
        
        override func configureSubviews() {
            super.configureSubviews()
            [backSceneView, frontSceneView].forEach { contentView.addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
                        
            let estimatedCardTargetSize = CGSize.businessCardSize(width: UIScreen.main.bounds.width * 0.8)
            
            frontSceneView.constrainHeightLessThan(contentView)
            frontSceneView.constrainHeight(constant: estimatedCardTargetSize.height, priority: .defaultHigh)
            frontSceneView.constrainWidthLessThan(contentView)
            frontSceneView.constrainWidth(constant: estimatedCardTargetSize.width, priority: .defaultHigh)
            frontSceneView.constrainLeftToSuperview()
            frontSceneView.constrainTopToSuperview()

            backSceneView.constrainHeightLessThan(contentView)
            backSceneView.constrainHeight(constant: estimatedCardTargetSize.height, priority: .defaultHigh)
            backSceneView.constrainWidthLessThan(contentView)
            backSceneView.constrainWidth(constant: estimatedCardTargetSize.width, priority: .defaultHigh)
            backSceneView.constrainRightToSuperview()
            backSceneView.constrainBottomToSuperview()
        }
    }
    
    struct BusinessCardCellDM {
        let frontImageURL: URL
        let backImageURL: URL
        let textureImageURL: URL
        let normal: CGFloat
        let specular: CGFloat
    }
}

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
    
    func setSizeMode(_ sizeMode: ReceivedCardsVM.CellSizeMode) {
        switch sizeMode {
        case .compact:
            backSceneView.dynamicLightingEnabled = false
            frontSceneView.dynamicLightingEnabled = false
            backSceneView.clipsToBounds = true
        case .expanded:
            backSceneView.dynamicLightingEnabled = true
            frontSceneView.dynamicLightingEnabled = true
            backSceneView.clipsToBounds = false
        }
    }
}
