//
//  BusinessCardSceneView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

import UIKit
import SceneKit
import CoreMotion

class BusinessCardSceneView: UIView {
    
    let scene = SCNScene(named: "SceneKitAssets.scnassets/Main.scn")!
    let lightNode: SCNNode
    let businessCard: SCNNode
    
    var isAcceptingMoves: Bool

    let xRange = deg2rad(-110)...deg2rad(-70)
    let zRange = deg2rad(-15)...deg2rad(15)
    
    private(set) lazy var sceneView: SCNView = {
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.clipsToBounds = false
        sceneView.preferredFramesPerSecond = 60
        return sceneView
    }()

    
    init(isAcceptingMoves: Bool) {
        lightNode = scene.rootNode.childNode(withName: "directionalLight", recursively: true)!
        businessCard = scene.rootNode.childNode(withName: "businessCard", recursively: true)!
        (businessCard.geometry as! SCNBox).firstMaterial!.lightingModel = .blinn
        
        self.isAcceptingMoves = isAcceptingMoves
        if !isAcceptingMoves {
            let moveTo = SCNAction.rotateTo(x: CGFloat(deg2rad(-120)), y: 0, z: 0, duration: 0)
            lightNode.runAction(moveTo)
        }
        super.init(frame: .zero)
        
//        let vConstraint = SCNLookAtConstraint(target: businessCard)
//        vConstraint.isGimbalLockEnabled = true
//        (scene.rootNode.childNode(withName: "camera", recursively: true))!.constraints = [vConstraint]
        
        addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            sceneView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            sceneView.heightAnchor.constraint(equalTo: sceneView.widthAnchor, multiplier: 0.57)
        ])
        
        
        AnimationHelper.perspectiveTransform(for: self)
        
        tiltSideways(duration: 0)
        
        sceneView.layer.shadowOpacity = 0.3
        sceneView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
//        let lookAtConstraint = SCNLookAtConstraint(target: businessCard)
//        sceneView.pointOfView!.constraints = [lookAtConstraint]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func updateMotionData(motion: CMDeviceMotion?, error: Error?) {
        if let motionData = motion, isAcceptingMoves {
            let deviceRotationInX = (motionData.attitude.pitch - deg2rad(45)) / 8
            let oldX: Double = Double(self.lightNode.eulerAngles.x)
            let potentialX = oldX - deviceRotationInX
            let newX = max(min(potentialX, self.xRange.upperBound), self.xRange.lowerBound)
            
            let deviceRotationInY = motionData.attitude.roll / 8
            let oldZ = Double(self.lightNode.eulerAngles.z)
            let potentialZ = oldZ + deviceRotationInY
            let newZ = max(min(potentialZ, self.zRange.upperBound), self.zRange.lowerBound)

//            if abs(newZ - oldZ) < deg2rad(5) || abs(newX - oldX) < deg2rad(5){
                let moveTo = SCNAction.rotateTo(x: CGFloat(newX), y: 0, z: CGFloat(newZ), duration: 0.1)
                self.lightNode.runAction(moveTo)
//            }
        }
    }
    
    func tiltSideways(duration: Double = 0.4) {
        isAcceptingMoves = false
//        lightNode.light?.intensity = 400
        let moveTo = SCNAction.rotateTo(x: CGFloat(deg2rad(-160)), y: 0, z: 0, duration: 0.4)
        lightNode.runAction(moveTo)

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            self.sceneView.layer.transform = CATransform3DMakeRotation(-.pi / 4, 1, 0, 0)
        })

    }
    
    func tiltStraight() {
//        isAcceptingMoves = true
//        lightNode.light?.intensity = 0
        let moveTo = SCNAction.rotateTo(x: CGFloat(deg2rad(-90)), y: 0, z: 0, duration: 0.4)
        lightNode.runAction(moveTo)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.sceneView.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        })
    }
}
