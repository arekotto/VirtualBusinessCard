//
//  HapticFeedbackEngine.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 24/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import CoreHaptics
import AVFoundation

struct HapticFeedbackEngine {

    private let shouldPlayVibrateOnError: Bool

    var engine: CHHapticEngine?

    var player: CHHapticPatternPlayer?

    init(sharpness: Float, intensity: Float) {

        shouldPlayVibrateOnError = intensity > 0.8

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine?.makePlayer(with: pattern)
        } catch {
            print("Failed perform haptic: \(error.localizedDescription).")
        }
    }

    func play() {
        do {
            try player?.start(atTime: 0)
        } catch {
            if shouldPlayVibrateOnError {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }

    }
}
