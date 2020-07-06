//
//  DetailsTransitionAnimator.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension ReceivedCardsVC {
    final class DetailsTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        static let duration: TimeInterval = 0.5
        
        var type: PresentationType
        private let animatedCell: UICollectionViewCell
        private let animatedCellSnapshot: UIView
        private let availableAnimationBounds: CGRect
        
        init?(type: PresentationType, animatedCell: UICollectionViewCell, animatedCellSnapshot: UIView, availableAnimationBounds: CGRect) {
            self.type = type
            self.animatedCellSnapshot = animatedCellSnapshot
            self.animatedCell = animatedCell
            self.availableAnimationBounds = availableAnimationBounds
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return Self.duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            
            let isPresenting = type.isPresenting
            
            let presentingVCKey: UITransitionContextViewControllerKey = isPresenting ? .from : .to
            guard let presentingVC = transitionContext.viewController(forKey: presentingVCKey) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let presentedVCKey: UITransitionContextViewControllerKey = isPresenting ? .to : .from
            guard let presentedVC = transitionContext.viewController(forKey: presentedVCKey) else {
                transitionContext.completeTransition(false)
                return
            }
            
            guard let cardDetailsVC = presentedVC.children.first as? CardDetailsVC else {
                transitionContext.completeTransition(false)
                return
            }
            
            guard let presentedView = presentedVC.view else {
                transitionContext.completeTransition(false)
                return
            }

            let availableAnimationBoundsView = UIView()
            availableAnimationBoundsView.frame = self.availableAnimationBounds
            availableAnimationBoundsView.clipsToBounds = true
            availableAnimationBoundsView.addSubview(animatedCellSnapshot)
            
            [presentingVC.view, presentedView, availableAnimationBoundsView].forEach { containerView.addSubview($0) }

            let animatedCellOnPresentedViewOrigin: CGPoint
            if let exactBounds = cardDetailsVC.imageCellOrigin(translatedTo: availableAnimationBoundsView) {
                animatedCellOnPresentedViewOrigin = exactBounds
            } else {
                animatedCellOnPresentedViewOrigin = presentingVC.view.convert(cardDetailsVC.estimatedImageCellOrigin(), to: availableAnimationBoundsView)
            }
            
            let animatedCellOnPresentedViewFrame = CGRect(x: animatedCellOnPresentedViewOrigin.x, y: animatedCellOnPresentedViewOrigin.y, width: animatedCellSnapshot.frame.width, height: animatedCellSnapshot.frame.height)
            
            let animatedCellFrame = animatedCell.contentView.convert(animatedCell.contentView.bounds, to: availableAnimationBoundsView)
            
            animatedCellSnapshot.frame = isPresenting ? animatedCellFrame : animatedCellOnPresentedViewFrame
            
            let onScreenPresentedViewFrame = presentedView.frame
            let offScreenPresentedViewFrame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width, y: onScreenPresentedViewFrame.origin.y), size: onScreenPresentedViewFrame.size)
            if isPresenting {
                presentedView.frame = offScreenPresentedViewFrame
            }
            
            animatedCell.isHidden = true
            cardDetailsVC.setImageSectionHidden(true)
            
            UIView.animate(withDuration: Self.duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                if isPresenting {
                    presentedView.frame = onScreenPresentedViewFrame
                    self.animatedCellSnapshot.frame = animatedCellOnPresentedViewFrame
                } else {
                    presentedView.frame = offScreenPresentedViewFrame
                    self.animatedCellSnapshot.frame = animatedCellFrame
                }
            }) { _ in
//                self.animatedCellSnapshot.removeFromSuperview()
                presentingVC.view.removeFromSuperview()
                availableAnimationBoundsView.removeFromSuperview()
                if !isPresenting {
                    self.animatedCell.isHidden = false
                } else {
                    cardDetailsVC.setImageSectionHidden(false)
                }
                transitionContext.completeTransition(true)
            }
        }
        
        enum PresentationType {
            case present
            case dismiss
            
            var isPresenting: Bool {
                return self == .present
            }
        }
    }
}
