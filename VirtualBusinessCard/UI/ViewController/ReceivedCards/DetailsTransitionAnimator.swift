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
        private let estimatedTopSafeAreaInset: CGFloat
        
        init?(type: PresentationType, animatedCell: UICollectionViewCell, animatedCellSnapshot: UIView, availableAnimationBounds: CGRect, estimatedTopSafeAreaInset: CGFloat) {
            self.type = type
            self.animatedCellSnapshot = animatedCellSnapshot
            self.animatedCell = animatedCell
            self.availableAnimationBounds = availableAnimationBounds
            self.estimatedTopSafeAreaInset = estimatedTopSafeAreaInset
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return Self.duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            
            let isPresenting = type.isPresenting
            
            guard let views = requiredViews(using: transitionContext) else {
                transitionContext.completeTransition(false)
                return
            }

            views.availableAnimationBoundsView.addSubview(animatedCellSnapshot)

            [views.presentingVC.view, views.shadowView, views.presentedView, views.availableAnimationBoundsView].forEach { containerView.addSubview($0) }

            let animatedCellOnPresentedViewOrigin: CGRect
            if let exactBounds = views.cardDetailsVC.imageCellFrame(translatedTo: views.availableAnimationBoundsView) {
                animatedCellOnPresentedViewOrigin = exactBounds
            } else {
                let estimatedCellFrame = views.cardDetailsVC.estimatedImageCellFrame(estimatedTopSafeAreaInset: estimatedTopSafeAreaInset)
                animatedCellOnPresentedViewOrigin = views.presentingVC.view.convert(estimatedCellFrame, to: views.availableAnimationBoundsView)
            }
            
            let animatedCellFrame = animatedCell.contentView.convert(animatedCell.contentView.bounds, to: views.availableAnimationBoundsView)
            
            animatedCellSnapshot.frame = isPresenting ? animatedCellFrame : animatedCellOnPresentedViewOrigin

            let onScreenPresentedViewFrame = views.presentedView.frame
            let offScreenPresentedViewFrame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width, y: onScreenPresentedViewFrame.origin.y), size: onScreenPresentedViewFrame.size)
            if isPresenting {
                views.presentedView.frame = offScreenPresentedViewFrame
            }
            
            animatedCell.isHidden = true
            views.cardDetailsVC.setImageSectionHidden(true)

            UIView.animate(withDuration: Self.duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                if isPresenting {
                    views.presentedView.frame = onScreenPresentedViewFrame
                    self.animatedCellSnapshot.frame = animatedCellOnPresentedViewOrigin
                    views.shadowView.alpha = 0.2
                } else {
                    views.presentedView.frame = offScreenPresentedViewFrame
                    self.animatedCellSnapshot.frame = animatedCellFrame
                    views.shadowView.alpha = 0
                }
            }, completion: { _ in
                views.presentingVC.view.removeFromSuperview()
                views.availableAnimationBoundsView.removeFromSuperview()
                if !isPresenting {
                    self.animatedCell.isHidden = false
                } else {
                    views.cardDetailsVC.setImageSectionHidden(false)
                }
                transitionContext.completeTransition(true)
            })
        }

        private func requiredViews(using transitionContext: UIViewControllerContextTransitioning) -> RequiredAnimationViews? {
            let isPresenting = type.isPresenting
            let presentingVCKey: UITransitionContextViewControllerKey = isPresenting ? .from : .to
            guard let presentingVC = transitionContext.viewController(forKey: presentingVCKey) else {
                return nil
            }

            let presentedVCKey: UITransitionContextViewControllerKey = isPresenting ? .to : .from
            guard let presentedVC = transitionContext.viewController(forKey: presentedVCKey) else {
                return nil
            }

            guard let cardDetailsVC = presentedVC.children.first as? CardDetailsVC else {
                return nil
            }

            guard let presentedView = presentedVC.view else {
                return nil
            }

            let availableAnimationBoundsView = UIView()
            availableAnimationBoundsView.frame = self.availableAnimationBounds
            availableAnimationBoundsView.clipsToBounds = true

            let shadowView = UIView(frame: presentingVC.view.bounds)
            shadowView.backgroundColor = .black
            shadowView.alpha = isPresenting ? 0 : 0.2

            return RequiredAnimationViews(
                presentingVC: presentingVC,
                presentedVC: presentedVC,
                cardDetailsVC: cardDetailsVC,
                presentedView: presentedView,
                availableAnimationBoundsView: availableAnimationBoundsView,
                shadowView: shadowView
            )
        }
    }
}

extension ReceivedCardsVC.DetailsTransitionAnimator {

    struct RequiredAnimationViews {
        let presentingVC: UIViewController
        let presentedVC: UIViewController
        let cardDetailsVC: CardDetailsVC
        let presentedView: UIView
        let availableAnimationBoundsView: UIView
        let shadowView: UIView
    }

    enum PresentationType {
        case present
        case dismiss

        var isPresenting: Bool {
            return self == .present
        }
    }
}
