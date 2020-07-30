//
//  MotionDataSource.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 23/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import CoreMotion

protocol MotionDataSource: class {
    var motionManager: CMMotionManager { get }
    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

extension MotionDataSource {
    func startUpdatingMotionData(in interval: TimeInterval) {
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            self.didReceiveMotionData(motion, over: self.motionManager.deviceMotionUpdateInterval)
        }
    }

    func pauseUpdatingMotionData() {
        motionManager.stopDeviceMotionUpdates()
    }
}
