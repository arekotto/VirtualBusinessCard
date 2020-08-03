//
//  CardFrontBackView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

final class CardFrontBackView: AppView {

    static let defaultSceneShadowOpacity: Float = 0.35

    private var frontSceneViewHeightConstraint: NSLayoutConstraint!
    let frontSceneView: BusinessCardSceneView = {
        let this = BusinessCardSceneView(dynamicLightingEnabled: true)
        this.layer.shadowOpacity = defaultSceneShadowOpacity
        return this
    }()

    private var backSceneViewHeightConstraint: NSLayoutConstraint!
    let backSceneView: BusinessCardSceneView = {
        let this = BusinessCardSceneView(dynamicLightingEnabled: true)
        this.layer.shadowOpacity = defaultSceneShadowOpacity
        return this
    }()
    
    private let sceneHeightAdjustMode: SceneHeightAdjustMode
    
    var allSceneViews: [BusinessCardSceneView] {
        [backSceneView, frontSceneView]
    }
    
    var style = Style.expanded {
        didSet { setStyle(style) }
    }

    init(sceneHeightAdjustMode: SceneHeightAdjustMode) {
        self.sceneHeightAdjustMode = sceneHeightAdjustMode
        super.init()
    }

    required init() {
        self.sceneHeightAdjustMode = .flexible(multiplayer: 0.9)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureView() {
        super.configureView()
        setStyle(.expanded)
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

        switch sceneHeightAdjustMode {
        case .flexible(let multiplayer):
            frontSceneViewHeightConstraint = frontSceneView.constrainHeightEqualTo(self, multiplier: multiplayer)
            backSceneViewHeightConstraint = backSceneView.constrainHeightEqualTo(self, multiplier: multiplayer)
        case .fixed:
            frontSceneView.constrainTrailingToSuperview()
            backSceneView.constrainLeadingToSuperview()
        }
        
        frontSceneView.constrainWidthEqualTo(frontSceneView.heightAnchor, multiplier: 1 / CGSize.businessCardHeightToWidthRatio)
        backSceneView.constrainWidthEqualTo(backSceneView.heightAnchor, multiplier: 1 / CGSize.businessCardHeightToWidthRatio)
    }

    func setSceneShadowOpacity(_ shadowOpacity: Float) {
        allSceneViews.forEach { $0.layer.shadowOpacity = shadowOpacity }
    }
    
    func lockScenesToCurrentHeights() {
        switch sceneHeightAdjustMode {
        case .flexible:
            frontSceneViewHeightConstraint.isActive = false
            frontSceneView.constrainHeight(constant: frontSceneView.frame.size.height)

            backSceneViewHeightConstraint.isActive = false
            backSceneView.constrainHeight(constant: backSceneView.frame.size.height)
        default:
            return
        }
    }
    
    private func setStyle(_ style: Style) {
        switch style {
        case .compact:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 4.5
            }
        case .expanded:
            allSceneViews.forEach {
                $0.layer.shadowRadius = 9
            }
        }
    }
    
    // MARK: BusinessCardCellDM
    
    struct URLDataModel {
        let frontImageURL: URL
        let backImageURL: URL
        let textureImageURL: URL
        let normal: CGFloat
        let specular: CGFloat
        var cornerRadiusHeightMultiplier: CGFloat
    }

    struct ImageDataModel {
        let frontImage: UIImage
        let backImage: UIImage
        let textureImage: UIImage
        let normal: CGFloat
        let specular: CGFloat
        let cornerRadiusHeightMultiplier: CGFloat
    }

    enum SceneHeightAdjustMode: Equatable {
        case flexible(multiplayer: CGFloat)
        case fixed
    }

    enum Style {
        case compact, expanded
    }
}

extension CardFrontBackView {

    func setDynamicLightingEnabled(_ isEnabled: Bool) {
        allSceneViews.forEach { $0.dynamicLightingEnabled = isEnabled }
    }

    func setDataModel(_ dm: ImageDataModel) {
        frontSceneView.setImage(image: dm.frontImage, texture: dm.textureImage, normal: dm.normal, specular: dm.specular, cornerRadiusHeightMultiplier: dm.cornerRadiusHeightMultiplier)
        backSceneView.setImage(image: dm.backImage, texture: dm.textureImage, normal: dm.normal, specular: dm.specular, cornerRadiusHeightMultiplier: dm.cornerRadiusHeightMultiplier)
    }
    
    func setDataModel(_ dm: URLDataModel) {
        let task = ImageAndTextureFetchTask(imageURLs: [dm.frontImageURL, dm.textureImageURL, dm.backImageURL])
        task { [weak self] result in
            switch result {
            case .failure(let err): print(err.localizedDescription)
            case .success(let images):
                self?.setDataModel(ImageDataModel(
                    frontImage: images[0],
                    backImage: images[2],
                    textureImage: images[1],
                    normal: dm.normal,
                    specular: dm.specular,
                    cornerRadiusHeightMultiplier: dm.cornerRadiusHeightMultiplier
                ))
            }
        }
    }
    
    func updateMotionData(_ motion: CMDeviceMotion, over timeInterval: TimeInterval) {
        let deviceRotationInX = max(min(motion.attitude.pitch, deg2rad(90)), deg2rad(0))
        let x = deviceRotationInX / deg2rad(90) * 20 - 10
        let deviceRotationInZ = min(max(motion.attitude.roll, deg2rad(-45)), deg2rad(45))
        let y = deviceRotationInZ * 10 / deg2rad(45)
        
        switch style {
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
