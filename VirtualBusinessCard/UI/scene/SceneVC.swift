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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let scene = SCNScene(named: "SceneKitAssets.scnassets/Main.scn")!
        let sceneView = SCNView()
        sceneView.scene = scene
        
        lightNode = scene.rootNode.childNode(withName: "directionalLight", recursively: true)
        
        view.addSubview(sceneView)
        
        view.backgroundColor = .white
        
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
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sceneView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        motionManager.gyroUpdateInterval = 0.5
        
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (motion, error) in
            if let motionData = motion {
                let moveTo = SCNAction.move(to: SCNVector3Make(1, 1, 1), duration: 1)
                self.lightNode.runAction(moveTo)
            }
        }
    }

}
