//
//  BusinessCardSceneView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Kingfisher

import UIKit
import SceneKit
import CoreMotion

class BusinessCardSceneView: AppView {
    
    let scene = SCNScene(named: "SceneKitAssets.scnassets/Main.scn")!

    private(set) lazy var sceneView: SCNView = {
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.clipsToBounds = true
        sceneView.preferredFramesPerSecond = 60
        return sceneView
    }()
    
    private(set) lazy var dynamicDirectionalLightNode = scene.rootNode.childNode(withName: "directionalLight", recursively: true)!
    
    private(set) lazy var businessCardNode = scene.rootNode.childNode(withName: "businessCard", recursively: true)!
    
    private var businessCardGeometryMaterial: SCNMaterial {
        (businessCardNode.geometry as! SCNBox).firstMaterial!
    }

    private var cornerRadiusHeightMultiplier: CGFloat = 0
    
    private let xLightAngleLowest = deg2rad(-120)
    private let xLightAngleHighest = deg2rad(-60)
    private let zLightAngleHighestABS = deg2rad(30)

    private let activityIndicator: UIActivityIndicatorView = {
        let this = UIActivityIndicatorView(style: .medium)
        this.hidesWhenStopped = true
        this.startAnimating()
        return this
    }()
    
    override func configureView() {
        super.configureView()
        businessCardGeometryMaterial.lightingModel = .blinn
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        [sceneView, activityIndicator].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        sceneView.constrainToEdgesOfSuperview()
        activityIndicator.constrainCenterToSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sceneView.layer.cornerRadius = cornerRadiusHeightMultiplier * frame.height
    }

    override func configureColors() {
        super.configureColors()
        activityIndicator.color = Asset.Colors.appAccent.color
    }
}

extension BusinessCardSceneView {
    var dynamicLightingEnabled: Bool {
        get { !scene.isPaused }
        set {
            guard newValue != dynamicLightingEnabled else { return }
            if newValue {
                scene.isPaused = false
//                dynamicDirectionalLightNode.light!.intensity = 200
            } else {
//                dynamicDirectionalLightNode.light!.intensity = 0
                scene.isPaused = true
            }
        }
    }
    
    var shininess: CGFloat {
        get { businessCardGeometryMaterial.specular.intensity }
        set { businessCardGeometryMaterial.specular.intensity = min(max(newValue, 0), 1) }
    }
    
    var illumination: CGFloat {
        get { businessCardGeometryMaterial.selfIllumination.intensity }
        set { businessCardGeometryMaterial.selfIllumination.intensity = min(max(newValue, 0), 0.5) }
    }
    
    convenience init(dynamicLightingEnabled: Bool) {
        self.init()
        self.dynamicLightingEnabled = dynamicLightingEnabled
    }
    
    func setImage(image: UIImage, texture: UIImage?, normal: CGFloat, specular: CGFloat, cornerRadiusHeightMultiplier: CGFloat) {
        activityIndicator.stopAnimating()
        let imageMaterial = businessCardGeometryMaterial
        imageMaterial.lightingModel = .blinn
        imageMaterial.diffuse.contents = image
        imageMaterial.normal.contents = texture
        imageMaterial.normal.intensity = normal
        imageMaterial.specular.intensity = specular
        sceneView.layer.cornerRadius = cornerRadiusHeightMultiplier * frame.height
        self.cornerRadiusHeightMultiplier = cornerRadiusHeightMultiplier
    }
    
    func updateMotionData(motion: CMDeviceMotion, over timeframe: TimeInterval) {
        guard dynamicLightingEnabled else { return }

        let deviceRotationInX = max(min(1 - motion.attitude.rotationMatrix.m33, 1), 0)

        let zeroedScaleEndX = xLightAngleHighest - xLightAngleLowest
        let newX = deviceRotationInX * zeroedScaleEndX + xLightAngleLowest
        
        let deviceRotationInZ = min(max(motion.attitude.rotationMatrix.m13, -0.5), 0.5)
        let newZ = deviceRotationInZ / 0.5 * zLightAngleHighestABS

        let moveTo = SCNAction.rotateTo(x: CGFloat(newX), y: 0, z: CGFloat(newZ), duration: timeframe)
        dynamicDirectionalLightNode.runAction(moveTo)
    }

    func prepareForImageReload() {
        let placeholder = Asset.Colors.cardPlaceholder.color.as1ptImage()
        setImage(image: placeholder, texture: nil, normal: 0, specular: 0, cornerRadiusHeightMultiplier: 0)
        activityIndicator.startAnimating()
    }
}
