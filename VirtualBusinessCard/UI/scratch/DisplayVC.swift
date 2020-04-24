//
//  DisplayVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/04/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreHaptics

class DisplayVC: UIViewController {
    
    lazy var holderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(panGesture)
        return view
    }()
    
    let cardVC = CardView(imageName: "ExampleBC")
    let cardVC2 = CardView(imageName: "ExampleBCBack")
    
    lazy var currentCard = cardVC

//    lazy var actionButton: UIBarButtonItem = {
//        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(action))
//    }()
    
    var animator : UIViewPropertyAnimator!
    var animationDuration : TimeInterval = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        navigationItem.rightBarButtonItem = actionButton
        
        
        [cardVC2, cardVC].forEach { cardView in
            holderView.addSubview(cardView)
            NSLayoutConstraint.activate([
                cardView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: holderView.trailingAnchor),
                cardView.topAnchor.constraint(equalTo: holderView.topAnchor),
                cardView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor)
            ])
        }
        cardVC2.isHidden = true
        
        view.addSubview(holderView)
        NSLayoutConstraint.activate([
            holderView.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
            holderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            holderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            holderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            holderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        
    }
    
    func loadAnimator() -> UIViewPropertyAnimator {
        let fromView = currentCard
        let toView = currentCard == cardVC ? cardVC2 : cardVC
        
        toView.isHidden = false

        guard let snapshot = toView.snapshotView(afterScreenUpdates: true) else {
            fatalError()
        }
        toView.isHidden = true

        // 2
        let containerView = holderView
//        let finalFrame = transitionContext.finalFrame(for: toVC)

        // 3
//        snapshot.layer.cornerRadius = 10//CardViewController.cardCornerRadius
//        snapshot.layer.masksToBounds = true
        
        snapshot.layer.shadowOffset = CGSize(width: 4, height: 4)
        snapshot.layer.shadowRadius = 8
        snapshot.layer.shadowOpacity = 0
        snapshot.layer.shadowColor = UIColor.black.cgColor

        // 1
        containerView.addSubview(toView)
        containerView.addSubview(snapshot)

        // 2
        AnimationHelper.perspectiveTransform(for: containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
        // 3
//        let duration = transitionDuration(using: transitionContext)

        // 1
        
        let timeParameter = UICubicTimingParameters(animationCurve: .linear)
        let animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timeParameter)
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 3, delay: 0, options: .calculationModeCubic,
                animations: {
                    // 2
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                        fromView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                        fromView.layer.shadowOpacity = 0
                    }

                    // 3
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                        snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                        snapshot.layer.shadowOpacity = 0.6
                    }

                    // 4
                    //            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                    //              snapshot.frame = finalFrame
                    //              snapshot.layer.cornerRadius = 0
                    //            }
            },
                // 5
                completion: { _ in

    //                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        animator.addCompletion { state in
            switch state {
            case .end:
                toView.isHidden = false
                fromView.isHidden = true

                self.currentCard = toView
                
            case .start:
                fromView.isHidden = false
                toView.isHidden = true
                
            default:
                return
            }

            snapshot.removeFromSuperview()
            fromView.layer.transform = CATransform3DIdentity
            
            self.isFinishing = false
            self.animator = nil
        }
                
        return animator
//        animator.pausesOnCompletion = true
    }
     
    var isFinishing = false
    
    var engine: CHHapticEngine?
    var continuousPlayer: CHHapticAdvancedPatternPlayer!

}



@objc extension DisplayVC {
    private func pan(_ panGesture : UIPanGestureRecognizer){
        
        guard !isFinishing else { return }
        
        switch panGesture.state{
        case .began:

            animator = loadAnimator()
            
            animator.startAnimation()
            animator.pauseAnimation()
            
            
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

            do {
                engine = try CHHapticEngine()
                try engine?.start()
            } catch {
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
            
            // create a dull, strong haptic
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

            
            guard let url = Bundle.main.url(forResource: "rec", withExtension: "wav") else {
                return
            }
            let resourceId = (try! engine?.registerAudioResource(url, options: [:]))!

            // create a continuous haptic event starting immediately and lasting one second
            
            var events = [CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1)]
            
            for i in 0..<100 {
                events.append(CHHapticEvent(audioResourceID: resourceId, parameters: [], relativeTime: TimeInterval(i/4), duration: 0.25))
            }
    
            // now attempt to play the haptic, with our fading parameter
            do {
                let pattern = try CHHapticPattern(events: events, parameterCurves: [])

                self.continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
                try continuousPlayer?.start(atTime: 0)
            } catch {
                // add your own meaningful error handling here!
                print(error.localizedDescription)
            }
            
            break
        case .changed:
            let complete = panGesture.translation(in: holderView).x / holderView.bounds.width
            animator.fractionComplete = complete
            let final = Float(complete/2 + 0.3)
            print(final)
//            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: final, relativeTime: 0)
//            let intensityParameter2 = CHHapticDynamicParameter(parameterID: .audioBrightnessControl, value: Float(complete), relativeTime: 0)

            
            // Send dynamic parameters to the haptic player.
            do {
//                try continuousPlayer.sendParameters([intensityParameter], atTime: 0)
            } catch let error {
                print("Dynamic Parameter Error: \(error)")
            }
            
        case .ended:
            
            isFinishing = true
            
            do {
                try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
            } catch let error {
                print("Error stopping the continuous haptic player: \(error)")
            }
            
            if animator.fractionComplete > 0.5 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                animator.isReversed = true
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }
}
