//
//  AcceptCardVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class AcceptCardVC: AppViewController<AcceptCardView, AcceptCardVM> {

    private var acceptAnimator: UIViewPropertyAnimator?
    private var bounceAnimator: UIViewPropertyAnimator?
    private var slideDownAnimator: UIViewPropertyAnimator?
    private var slideUpAnimator: UIViewPropertyAnimator?

    var isFinishingAcceptAnimation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.fetchData()
        contentView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        contentView.rejectButton.addTarget(self, action: #selector(didTapRejectButton), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playBounceAnimation()
        Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(playBounceAnimation), userInfo: nil, repeats: true)
    }

    private func makeBounceAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                    self.contentView.cardSceneViewTopConstraint.constant += 10
                    self.view.layoutIfNeeded()
                }
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                    self.contentView.cardSceneViewTopConstraint.constant = self.contentView.startingCardTopConstraintConstant
                    self.view.layoutIfNeeded()
                }
            })
        }
        return animator
    }

    private func makeSlideDownAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 2, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.contentView.slideToAcceptStackView.alpha = 0.4
                    self.contentView.slideToAcceptStackViewTopConstraint.constant += UIScreen.main.bounds.height / 8
                    self.view.layoutIfNeeded()
                }
            })
        }
        return animator
    }

    private func makeSlideUpAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 2, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations {
            UIView.animateKeyframes(withDuration:2, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.contentView.slideToAcceptStackViewTopConstraint.constant = AcceptCardView.startingSlideToAcceptStackViewTopConstraint
                    self.contentView.slideToAcceptStackView.alpha = 1
                    self.view.layoutIfNeeded()
                }
            })
        }
        return animator
    }

    private func makeAcceptAnimator() -> UIViewPropertyAnimator {
        let timeParameter = UICubicTimingParameters(animationCurve: .linear)
        let animator = UIViewPropertyAnimator(duration: 1, timingParameters: timeParameter)
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 3/5) {
                    self.contentView.cardSceneView.transform = CGAffineTransform(rotationAngle: 0)
                    self.contentView.cardSceneViewTopConstraint.constant = self.view.bounds.height / 4
                    self.view.layoutIfNeeded()
                }
                UIView.addKeyframe(withRelativeStartTime: 3/5, relativeDuration: 2/5) {
                    self.contentView.cardSceneViewTopConstraint.constant += self.view.bounds.height / 4
                    self.view.layoutIfNeeded()
                }
            })
        }
        animator.addCompletion { state in
            self.acceptAnimator = nil
            switch state {
            case .end: return
            case .start: self.resetViewAfterDiscardedAcceptAnimation()
            default: return
            }
        }

        return animator
    }

    private func resetViewAfterDiscardedAcceptAnimation() {
        self.contentView.cardSceneViewTopConstraint.constant = contentView.startingCardTopConstraintConstant
        self.contentView.slideToAcceptStackViewTopConstraint.constant = AcceptCardView.startingSlideToAcceptStackViewTopConstraint
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.contentView.slideToAcceptStackView.alpha = 1
            self.contentView.rejectButton.alpha = 1
        }
    }

    private func beginAcceptAnimation() {
        bounceAnimator?.stopAnimation(true)
        slideDownAnimator?.stopAnimation(true)
        slideUpAnimator?.stopAnimation(true)

        slideUpAnimator = nil
        slideDownAnimator = nil

        UIView.animate(withDuration: 0.2) {
            self.contentView.slideToAcceptStackView.alpha = 0
            self.contentView.rejectButton.alpha = 0
        }

        acceptAnimator = makeAcceptAnimator()

        acceptAnimator?.startAnimation()
        acceptAnimator?.pauseAnimation()
    }

    private func updateAcceptAnimation(completeFraction: CGFloat) {
        var complete = completeFraction
        if complete > 3/5 {
            let bounceValue = log10(1 + (complete - 3/5))
            print(bounceValue)
            complete = 3/5 + bounceValue
        }
        acceptAnimator?.fractionComplete = complete
    }

    private func endAcceptAnimation() {
        guard let animator = acceptAnimator else { return }
        if animator.fractionComplete > 0.5 {
            isFinishingAcceptAnimation = true
        } else {
            animator.isReversed = true
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

@objc private extension AcceptCardVC {

    func didTapRejectButton() {
        viewModel.didSelectReject()
    }

    func playBounceAnimation() {
        guard acceptAnimator == nil else { return }

        bounceAnimator = makeBounceAnimator()
        bounceAnimator?.startAnimation()
        
        if slideDownAnimator == nil {
            slideDownAnimator = makeSlideDownAnimator()
            slideDownAnimator?.startAnimation()
            slideUpAnimator = nil
        } else {
            slideUpAnimator = makeSlideUpAnimator()
            slideUpAnimator?.startAnimation()
            slideDownAnimator = nil
        }
    }

    func panGesture(_ panGesture : UIPanGestureRecognizer) {
        guard !isFinishingAcceptAnimation else { return }

        switch panGesture.state {
        case .began: beginAcceptAnimation()
        case .changed: updateAcceptAnimation(completeFraction: panGesture.translation(in: view).y / (view.bounds.height / 2))
        case .ended: endAcceptAnimation()
        default: return
        }
    }
}

extension AcceptCardVC: AcceptCardVMDelegate {
    func dismissSelf() {
        dismiss(animated: true)
    }

    func presentRejectAlert() {
        let title = NSLocalizedString("Reject Card", comment: "")
        let message = NSLocalizedString("This business card has not been saved to your collection yet. Are you sure you want to reject it?", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reject Card", comment: ""), style: .destructive) { _ in
            self.viewModel.didConfirmReject()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }

    func didFetchData(image: UIImage, texture: UIImage, normal: Double, specular: Double) {
        contentView.cardSceneView.setImage(image: image, texture: texture, normal: CGFloat(normal), specular: CGFloat(specular))

    }


}
