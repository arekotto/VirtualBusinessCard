//
//  CardFrontBackView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

class CardFrontBackView: AppView {
    
    let frontSceneView =  BusinessCardSceneView(dynamicLightingEnabled: true)
    let backSceneView = BusinessCardSceneView(dynamicLightingEnabled: true)
    
    var frontSceneViewHeightConstraint: NSLayoutConstraint!
    var backSceneViewHeightConstraint: NSLayoutConstraint!
    
    var allSceneViews: [BusinessCardSceneView] {
        [backSceneView, frontSceneView]
    }
    
    var sizeMode = SizeMode.expanded {
        didSet { setSizeMode(sizeMode) }
    }

    override func configureView() {
        super.configureView()
        setSizeMode(.expanded)
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        allSceneViews.forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        
        frontSceneView.constrainLeadingToSuperview()
        frontSceneView.constrainTopToSuperview()
        
        
        backSceneView.constrainTrailingToSuperview()
        backSceneView.constrainBottomToSuperview()
        
        frontSceneViewHeightConstraint = frontSceneView.constrainHeightEqualTo(self, multiplier: 0.9)
        backSceneViewHeightConstraint = backSceneView.constrainHeightEqualTo(self, multiplier: 0.9)
        
        frontSceneView.constrainWidthEqualTo(frontSceneView.heightAnchor, multiplier: 1 / CGSize.businessCardSizeRatio)
        backSceneView.constrainWidthEqualTo(backSceneView.heightAnchor, multiplier: 1 / CGSize.businessCardSizeRatio)
    }
    
    func lockViewsToCurrentSizes() {
        
        frontSceneViewHeightConstraint.isActive = false
        frontSceneView.constrainHeight(constant: frontSceneView.frame.size.height)
        
        backSceneViewHeightConstraint.isActive = false
        backSceneView.constrainHeight(constant: backSceneView.frame.size.height)
    }
    
    private func setSizeMode(_ sizeMode: SizeMode) {
        switch sizeMode {
        case .compact:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 4.5
                $0.layer.shadowOpacity = 0.35
            }
        case .expanded:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 9
                $0.layer.shadowOpacity = 0.35
            }
        }
    }
    
    // MARK: BusinessCardCellDM
    
    struct DataModel {
        let frontImageURL: URL
        let backImageURL: URL
        let textureImageURL: URL
        let normal: CGFloat
        let specular: CGFloat
    }
    
    enum SizeMode {
        case compact, expanded
    }
}

extension CardFrontBackView {

    func setDynamicLightingEnabled(_ isEnabled: Bool) {
        allSceneViews.forEach { $0.dynamicLightingEnabled = isEnabled }
    }
    
    func setDataModel(_ dm: DataModel) {
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
        
        switch sizeMode {
        case .compact:  animateShadow(to: CGSize(width: y / 2, height: -x / 2), over: timeInterval)
        case .expanded: animateShadow(to: CGSize(width: y, height: -x), over: timeInterval)
        }
        
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
}
