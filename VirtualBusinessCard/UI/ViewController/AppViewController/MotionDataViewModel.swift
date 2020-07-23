//
//  MotionDataViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 23/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import CoreMotion

class MotionDataViewModel: AppViewModel {

    private lazy var motionManager = CMMotionManager()

    func startUpdatingMotionData(in interval: TimeInterval) {
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.didReceiveMotionData(motion, over: self.motionManager.deviceMotionUpdateInterval)
        }
    }

    func pauseUpdatingMotionData() {
        motionManager.stopDeviceMotionUpdates()
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        // override in subclass
    }
}
