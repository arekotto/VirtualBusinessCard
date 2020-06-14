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
        sceneView.clipsToBounds = false
        sceneView.preferredFramesPerSecond = 60
        return sceneView
    }()
    
    private(set) lazy var dynamicDirectionalLightNode = scene.rootNode.childNode(withName: "directionalLight", recursively: true)!
    
    private(set) lazy var businessCardNode = scene.rootNode.childNode(withName: "businessCard", recursively: true)!
    
    private var businessCardGeometryMaterial: SCNMaterial {
        (businessCardNode.geometry as! SCNBox).firstMaterial!
    }
    
    private let xLightAngleLowest = deg2rad(-120)
    private let xLightAngleHighest = deg2rad(-60)
    private let zLightAngleHighestABS = deg2rad(30)
    
    override func configureView() {
        super.configureView()
        businessCardGeometryMaterial.lightingModel = .blinn
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(sceneView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        sceneView.constrainToEdgesOfSuperview()
    }
}

extension BusinessCardSceneView {
    var dynamicLightingEnabled: Bool {
        get { scene.isPaused }
        set {
            if newValue {
                scene.isPaused = false
                dynamicDirectionalLightNode.light!.intensity = 200
            } else {
                scene.isPaused = true
                dynamicDirectionalLightNode.light!.intensity = 0
            }
        }
    }
    
    convenience init(dynamicLightingEnabled: Bool) {
        self.init()
        self.dynamicLightingEnabled = dynamicLightingEnabled
    }
    
    func setImage(image: UIImage, texture: UIImage?) {
        let imageMaterial = businessCardGeometryMaterial
        imageMaterial.lightingModel = .blinn
        imageMaterial.diffuse.contents = image
        //        imageMaterial.normal.contents = texture
        //        scene.isPaused = true
    }
    
    func updateMotionData(motion: CMDeviceMotion) {
        let deviceRotationInX = max(min(motion.attitude.pitch, deg2rad(90)), deg2rad(0))
        let rotationProportionX = deviceRotationInX / deg2rad(90)
        
        let zeroedScaleEndX = xLightAngleHighest - xLightAngleLowest
        let newX = rotationProportionX * zeroedScaleEndX + xLightAngleLowest
        
        let deviceRotationInZ = min(max(motion.attitude.roll, deg2rad(-45)), deg2rad(45))
        let newZ = deviceRotationInZ / deg2rad(45) * zLightAngleHighestABS
        
        let moveTo = SCNAction.rotateTo(x: CGFloat(newX), y: 0, z: CGFloat(newZ), duration: 0.1)
        dynamicDirectionalLightNode.runAction(moveTo)
    }
}
