//
//  AcceptCardVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

final class AcceptCardVC: AppViewController<AcceptCardView, AcceptCardVM> {

    private var bounceAnimatorsTimer: Timer?

    private var acceptAnimator: UIViewPropertyAnimator?
    private var bounceAnimator: UIViewPropertyAnimator?
    private var slideDownAnimator: UIViewPropertyAnimator?
    private var slideUpAnimator: UIViewPropertyAnimator?
    private var finishAcceptingAnimator: UIViewPropertyAnimator?

    private var didEnterAcceptingRangeInAnimationProgress = false

    private lazy var lightEngine = HapticFeedbackEngine(sharpness: 0.7, intensity: 0.4)
    private lazy var strongEngine = HapticFeedbackEngine(sharpness: 0.7, intensity: 1)

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupContentView()
        setupBars()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.willAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.cardSceneView.lockViewsToCurrentSizes()
        playBounceAnimation()
        bounceAnimatorsTimer = Timer.scheduledTimer(timeInterval: 2.1, target: self, selector: #selector(playBounceAnimation), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bounceAnimatorsTimer?.invalidate()
        bounceAnimatorsTimer = nil 
    }

    private func setupContentView() {
        contentView.cardSceneView.setDataModel(viewModel.dataModel())
        contentView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        contentView.rejectButton.addTarget(self, action: #selector(didTapRejectButton), for: .touchUpInside)
        contentView.doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        contentView.tagsCollectionView.tagDataSource = self
    }

    private func setupBars() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        toolbarItems = [
            UIBarButtonItem(image: viewModel.addNoteImage, style: .plain, target: self, action: #selector(didTapAddNoteButton)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: viewModel.addTagImage, style: .plain, target: self, action: #selector(didTapAddTagButton))
        ]
    }
}

// MARK: - Animation Handlers

private extension AcceptCardVC {
    func resetViewAfterDiscardedAcceptAnimation() {
        self.contentView.cardSceneViewTopConstraint.constant = contentView.startingCardTopConstraintConstant
        self.contentView.slideToAcceptStackViewTopConstraint.constant = AcceptCardView.startingSlideToAcceptStackViewTopConstraint
        self.contentView.cardSceneViewHeightConstraint.constant = AcceptCardView.defaultCardViewSize.height
        self.contentView.cardSceneViewWidthConstraint.constant = AcceptCardView.defaultCardViewSize.width
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.contentView.slideToAcceptStackView.alpha = 1
            self.contentView.rejectButton.alpha = 1
        }
    }

    func beginAcceptAnimation() {
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

    func updateAcceptAnimation(completeFraction: CGFloat) {
        var complete = completeFraction
        if complete > 0.6 {
            if !didEnterAcceptingRangeInAnimationProgress {
                self.strongEngine.play()
            }
            didEnterAcceptingRangeInAnimationProgress = true
            let bounceValue = log10(1 + (complete - 3/5))
            complete = 0.6 + 0.01 + bounceValue
        } else {
            if didEnterAcceptingRangeInAnimationProgress {
                self.strongEngine.play()
            }
            didEnterAcceptingRangeInAnimationProgress = false
        }
        acceptAnimator?.fractionComplete = complete
    }

    func endAcceptAnimation() {
        guard let animator = acceptAnimator else { return }
        if animator.fractionComplete > 3/5 {
            animator.stopAnimation(true)
            makeFinishAcceptingAnimator().startAnimation()
            viewModel.didAcceptCard()
        } else {
            animator.isReversed = true
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

// MARK: - Animators Creation

private extension AcceptCardVC {
    func makeBounceAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
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

    func makeSlideDownAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 2, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
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

    func makeSlideUpAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 2, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.contentView.slideToAcceptStackViewTopConstraint.constant = AcceptCardView.startingSlideToAcceptStackViewTopConstraint
                    self.contentView.slideToAcceptStackView.alpha = 1
                    self.view.layoutIfNeeded()
                }
            })
        }
        return animator
    }

    func makeFinishAcceptingAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    self.contentView.cardSceneViewTopConstraint.constant = AcceptCardView.cardViewExpandedTopConstraint
                    self.contentView.cardSceneViewHeightConstraint.constant = AcceptCardView.cardViewExpandedSize
                    self.contentView.cardSceneViewWidthConstraint.constant = AcceptCardView.defaultCardViewSize.width
                    self.contentView.doneButtonView.isHidden = false
                    self.contentView.doneButtonView.alpha = 1
                    self.contentView.cardSavedLabel.isHidden = false
                    self.contentView.cardSavedLabel.alpha = 1
                    self.view.layoutIfNeeded()
                }
            })
        }
        animator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.bounceAnimatorsTimer?.invalidate()
            self.bounceAnimatorsTimer = nil
            self.contentView.gestureRecognizers?.forEach {
                self.contentView.removeGestureRecognizer($0)
            }
            self.contentView.prepareForExpandedCardView()
            self.contentView.scrollView.delegate = self
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        return animator
    }

    func makeAcceptAnimator() -> UIViewPropertyAnimator {
        let timeParameter = UICubicTimingParameters(animationCurve: .linear)
        let animator = UIViewPropertyAnimator(duration: 1, timingParameters: timeParameter)
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    self.contentView.cardSceneView.transform = CGAffineTransform(rotationAngle: 0)
                    self.contentView.cardSceneViewTopConstraint.constant = self.view.bounds.height / 4
                    self.view.layoutIfNeeded()
                }
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.01) {
                    self.contentView.cardSceneViewHeightConstraint.constant += 20
                    self.contentView.cardSceneViewWidthConstraint.constant += 20
                    self.contentView.cardSceneView.sceneShadowOpacity = CardFrontBackView.defaultSceneShadowOpacity
                    self.view.layoutIfNeeded()
                }
                UIView.addKeyframe(withRelativeStartTime: 0.601, relativeDuration: 0.4) {
                    self.contentView.cardSceneViewTopConstraint.constant += self.view.bounds.height / 4
                    self.contentView.cardSceneViewHeightConstraint.constant += 15
                    self.contentView.cardSceneViewWidthConstraint.constant += 15
                    self.view.layoutIfNeeded()
                }
            })
        }
        animator.addCompletion {  [weak self] state in
            guard let self = self else { return }
            self.acceptAnimator = nil
            switch state {
            case .end: return
            case .start: self.resetViewAfterDiscardedAcceptAnimation()
            default: return
            }
        }
        return animator
    }
}

// MARK: - Actions

@objc
private extension AcceptCardVC {

    func didTapAddNoteButton() {
        viewModel.didSelectAddNote()
    }

    func didTapAddTagButton() {
        viewModel.didSelectAddTag()
    }

    func didTapDoneButton() {
        viewModel.didSelectDone()
    }

    func didTapRejectButton() {
        viewModel.didSelectReject()
    }

    func playBounceAnimation() {
        guard acceptAnimator == nil else { return }

        bounceAnimator = makeBounceAnimator()
        bounceAnimator?.startAnimation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightEngine.play()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.lightEngine.play()
        }

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
        guard !viewModel.hasAcceptedCard else { return }

        switch panGesture.state {
        case .began: beginAcceptAnimation()
        case .changed: updateAcceptAnimation(completeFraction: panGesture.translation(in: view).y / (view.bounds.height / 2))
        case .ended: endAcceptAnimation()
        default: return
        }
    }
}

// MARK: - CompactTagsCollectionViewDataSource

extension AcceptCardVC: CompactTagsCollectionViewDataSource {
    var tagColors: [UIColor] {
        viewModel.selectedTagColors
    }
}

// MARK: - UIScrollViewDelegate

extension AcceptCardVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newAlpha = 1 - scrollView.contentOffset.y / AcceptCardView.cardViewExpandedTopConstraint
        contentView.cardSavedLabel.alpha = min(max(newAlpha, 0), 1)
    }
}

// MARK: - AcceptCardVMDelegate

extension AcceptCardVC: AcceptCardVMDelegate {
    func refreshNotes() {
        contentView.notesStackView.isHidden = viewModel.notes.isEmpty
        contentView.notesLabel.text = viewModel.notes
    }

    func refreshTags() {
        contentView.tagStackView.isHidden = viewModel.selectedTagColors.isEmpty
        contentView.tagsCollectionView.reloadData()
    }

    func presentEditCardNotesVC(viewModel: EditCardNotesVM) {
        let vc = EditCardNotesVC(viewModel: viewModel)
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.presentationController?.delegate = vc
        present(navVC, animated: true)
    }

    func presentEditCardTagsVC(viewModel: EditCardTagsVM) {
        let vc = EditCardTagsVC(viewModel: viewModel)
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.presentationController?.delegate = vc
        present(navVC, animated: true)
    }

    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        contentView.cardSceneView.updateMotionData(motion, over: timeFrame)
    }

    func presentSaveErrorAlert(title: String) {
        let alert = UIAlertController.accentTinted(title: title, message: nil, preferredStyle: .alert)
        alert.addOkAction()
        present(alert, animated: true)
    }

    func presentSaveOfflineAlert() {
        let title = NSLocalizedString("Save Offline", comment: "")
        let message = NSLocalizedString("Your device appears to be disconnected from internet. The received business card has been saved offline and will be synced when the connection is restored.", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save Offline", style: .default) { _ in
            self.viewModel.didConfirmSaveOffline()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go Back", comment: ""), style: .cancel))
        present(alert, animated: true)
    }

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
}

