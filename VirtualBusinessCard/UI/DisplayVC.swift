//
//  DisplayVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/04/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class CardVC: UIViewController {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.6
        view.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    //    @objc func click() {
    //        let destinationViewController = CardVC()
    //        destinationViewController.providesPresentationContextTransitionStyle = true
    //        destinationViewController.transitioningDelegate = self
    //        destinationViewController.modalPresentationStyle = .custom
    //        present(destinationViewController, animated: true)
    //
    //
    //
    //
    //    }
}

//extension CardVC: UIViewControllerTransitioningDelegate {
//  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController)
//    -> UIViewControllerAnimatedTransitioning? {
//    return FlipPresentAnimationController(originFrame: view.frame)
//  }
//}

class DisplayVC: UIViewController {
    
    lazy var holderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(panGesture)
        return view
    }()
    
    let cardVC = CardVC(imageName: "ExampleBC")
    let cardVC2 = CardVC(imageName: "ExampleBCBack")
    
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
        
        
        [cardVC2, cardVC].forEach { cardVC in
            addChild(cardVC)
            holderView.addSubview(cardVC.view)
            cardVC.didMove(toParent: self)
            NSLayoutConstraint.activate([
                cardVC.view.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
                cardVC.view.trailingAnchor.constraint(equalTo: holderView.trailingAnchor),
                cardVC.view.topAnchor.constraint(equalTo: holderView.topAnchor),
                cardVC.view.bottomAnchor.constraint(equalTo: holderView.bottomAnchor)
            ])
        }
        cardVC2.view.isHidden = true
        
        view.addSubview(holderView)
        NSLayoutConstraint.activate([
            holderView.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
            holderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            holderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            holderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            holderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAnimator()
    }
    
    func loadAnimator() {
        let fromVC = currentCard
        let toVC = currentCard == cardVC ? cardVC2 : cardVC
        
        toVC.view.isHidden = false

        guard let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else {
            return
        }
        toVC.view.isHidden = true

        // 2
        let containerView = holderView
//        let finalFrame = transitionContext.finalFrame(for: toVC)

        // 3
//        snapshot.layer.cornerRadius = 10//CardViewController.cardCornerRadius
//        snapshot.layer.masksToBounds = true
        
        snapshot.layer.shadowOffset = CGSize(width: 4, height: 4)
        snapshot.layer.shadowRadius = 8
        snapshot.layer.shadowOpacity = 0.6
        snapshot.layer.shadowColor = UIColor.black.cgColor

        // 1
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)

        // 2
        AnimationHelper.perspectiveTransform(for: containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
        // 3
//        let duration = transitionDuration(using: transitionContext)

        // 1
        
        let timeParameter = UICubicTimingParameters(animationCurve: .linear)
        animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timeParameter)
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 3, delay: 0, options: .calculationModeCubic,
                animations: {
                    // 2
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
                        fromVC.view.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    }

                    // 3
                    UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                        snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                    }

                    // 4
                    //            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                    //              snapshot.frame = finalFrame
                    //              snapshot.layer.cornerRadius = 0
                    //            }
            },
                // 5
                completion: { _ in
                    toVC.view.isHidden = false
                    fromVC.view.isHidden = true
                    snapshot.removeFromSuperview()
                    fromVC.view.layer.transform = CATransform3DIdentity
                    self.currentCard = toVC
    //                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        animator.pausesOnCompletion = true
    }
     
    @objc
    private func pan(_ panGesture : UIPanGestureRecognizer){
        switch panGesture.state{
        case .began:
            // You will see alot examples of creating the animator here.
            // But to create a more complex animator, it is often a good item
            // to implement the animtor outside of gesture
            break
        case .changed:
            // When we pan back and forth on the screen,
            // we update the fractionComplete to give the visual effect
            // that we are moving the blue box
            animator.fractionComplete = panGesture.translation(in: holderView).x / holderView.bounds.width
        case .ended:
            // When we lift the finger, we continue the animation
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


class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }

        // 2
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        // 3
        snapshot.frame = originFrame
        snapshot.layer.cornerRadius = 10//CardViewController.cardCornerRadius
        snapshot.layer.masksToBounds = true

        // 1
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true

        // 2
        AnimationHelper.perspectiveTransform(for: containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
        // 3
        let duration = transitionDuration(using: transitionContext)

        // 1
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                // 2
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
                    fromVC.view.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                }

                // 3
                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                }

                // 4
                //            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                //              snapshot.frame = finalFrame
                //              snapshot.layer.cornerRadius = 0
                //            }
        },
            // 5
            completion: { _ in
                toVC.view.isHidden = false
                snapshot.removeFromSuperview()
                fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }


}
