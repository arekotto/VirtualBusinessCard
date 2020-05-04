//
//  SceneVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 24/04/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class SceneVC: UIViewController {

    let motionManager = CMMotionManager()
    
    var lightNode: SCNNode!
    
    let xRange = deg2rad(-110)...deg2rad(-70)
    let zRange = deg2rad(-15)...deg2rad(15)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let scene = SCNScene(named: "SceneKitAssets.scnassets/Main.scn")!
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.clipsToBounds = false
        
        lightNode = scene.rootNode.childNode(withName: "directionalLight", recursively: true)
        
        view.addSubview(sceneView)
        
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(action))
        
//        let lightNode = scene.rootNode.childNode(withName: "omni", recursively: true)
        
//        let light = lightNode!.light!
//
//        light.shadowMapSize = CGSize(width: 2048, height: 2048)
//        light.shadowMode = .forward
//        light.shadowSampleCount = 200
//        light.shadowRadius = 50
//        light.shadowBias  = 32
//        light.automaticallyAdjustsShadowProjection = true
//        
//        light.orthographicScale=200; // bigger is softer
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sceneView.heightAnchor.constraint(equalToConstant: 300),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            sceneView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])
        
        let card = scene.rootNode.childNode(withName: "businessCard", recursively: true)!.geometry as! SCNBox
        card.firstMaterial!.lightingModel = .blinn
        print(card.firstMaterial!.lightingModel)
    }
    var val = CGFloat(deg2rad(20))
    @objc func action() {
        val = -val
        print(lightNode.eulerAngles)
        print(lightNode.rotation)
        let moveTo = SCNAction.rotateTo(x: -1.5882496, y: 0, z: val, duration: 3)
        self.lightNode.runAction(moveTo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print(self.lightNode.eulerAngles)
            print(self.lightNode.rotation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let motionData = motion {
                let deviceRotationInX = (motionData.attitude.pitch - deg2rad(45)) / 8
                let potentialX = Double(self.lightNode.eulerAngles.x) - deviceRotationInX
                let newX = max(min(potentialX, self.xRange.upperBound), self.xRange.lowerBound)
                
                let deviceRotationInY = motionData.attitude.roll / 8
                let potentialZ = Double(self.lightNode.eulerAngles.z) + deviceRotationInY
                let newZ = max(min(potentialZ, self.zRange.upperBound), self.zRange.lowerBound)

                let moveTo = SCNAction.rotateTo(x: CGFloat(newX), y: 0, z: CGFloat(newZ), duration: 0.01)
                self.lightNode.runAction(moveTo)
            }
        }
    }

}

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

func rad2deg(_ number: Double) -> Double {
    return number * 180 / .pi
}
