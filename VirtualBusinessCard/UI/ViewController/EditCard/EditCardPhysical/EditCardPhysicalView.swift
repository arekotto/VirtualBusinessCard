//
//  EditCardPhysicalView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardPhysicalView: AppBackgroundView {

    var editingViews: [UIView] {
        EditingViewType.allCases.map { editingView(of: $0) }
    }

    let titleView = NavigationTitleView()

    private(set) var cardSceneViewTopConstraint: NSLayoutConstraint!
    let cardSceneView: CardFrontBackView = {
        let this = CardFrontBackView(sceneHeightAdjustMode: .fixed)
        this.setSceneShadowOpacity(0.2)
        return this
    }()

    let editingViewSegmentedControl: UISegmentedControl = {
        let this = UISegmentedControl(items: EditingViewType.allCases.map(\.title))
        this.selectedSegmentIndex = 0
        return this
    }()

    let textureEditingView = TextureEditingView()

    let surfaceEditingView: SurfaceEditingView = {
        let this = SurfaceEditingView()
        this.isHidden = true
        this.alpha = 0
        return this
    }()

    let cornersEditingView: SingleSliderEditingView = {
        let this = SingleSliderEditingView()
        this.minLabel.text = NSLocalizedString("Straight", comment: "")
        this.maxLabel.text = NSLocalizedString("Round", comment: "")
        this.isHidden = true
        this.alpha = 0
        return this
    }()

    let hapticsEditingView: HapticsEditingView = {
        let this = HapticsEditingView()
        this.isHidden = true
        this.alpha = 0
        return this
    }()

    private let mainScrollView: UIScrollView = {
        let this = UIScrollView()
        this.alwaysBounceVertical = true
        return this
    }()

    private let editingSectionBackgroundView: UIView = {
        let this = UIView()
        this.layer.cornerRadius = 20
        this.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return this
    }()

    private let editingViewContainer: UIView = {
        let this = UIView()
        this.translatesAutoresizingMaskIntoConstraints = false
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        mainScrollView.addSubview(cardSceneView)
        editingViews.forEach { editingViewContainer.addSubview($0) }
        [mainScrollView, editingSectionBackgroundView, editingViewSegmentedControl, editingViewContainer].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        let widthMultiplayer: CGFloat
        let cardSpacing: CGFloat
        switch DeviceDisplay.sizeType {
        case .commodious:
            widthMultiplayer = 0.85
            cardSpacing = 32
        case .standard:
            widthMultiplayer = 0.82
            cardSpacing = 24
        case .compact:
            widthMultiplayer = 0.82
            cardSpacing = 16
        }

        mainScrollView.constrainHorizontallyToSuperview()
        mainScrollView.constrainTopToSuperviewSafeArea()
        mainScrollView.constrainBottom(to: editingViewSegmentedControl.topAnchor, constant: -16)

        let heightMultiplayer = CGSize.businessCardHeightToWidthRatio * 2
        cardSceneView.constrainHeight(to: cardSceneView.widthAnchor, constant: cardSpacing, multiplier: heightMultiplayer)
        cardSceneView.constrainWidth(constant: DeviceDisplay.size.width * widthMultiplayer)
        cardSceneView.constrainCenterXToSuperview()
        cardSceneView.constrainBottomToSuperview(inset: cardSpacing)
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperview(inset: cardSpacing)

        editingViewSegmentedControl.constrainHeight(constant: 30)
        editingViewSegmentedControl.constrainCenterXToSuperview()
        editingViewSegmentedControl.constrainHorizontallyToSuperview(sideInset: 16)
        editingViewSegmentedControl.constrainBottom(to: editingViewContainer.topAnchor, constant: -8)

        textureEditingView.constrainToEdgesOfSuperview()

        surfaceEditingView.constrainVerticallyToSuperview(topInset: 16, bottomInset: 16)
        surfaceEditingView.constrainHorizontallyToSuperview(sideInset: 32)

        cornersEditingView.constrainCenterYToSuperview()
        cornersEditingView.constrainHorizontallyToSuperview(sideInset: 32)
        cornersEditingView.constrainHeight(to: editingViewContainer.heightAnchor, constant: -20, multiplier: 0.5)

        hapticsEditingView.constrainToEdgesOfSuperview()

        editingViewContainer.constrainHeight(constant: 150)
        editingViewContainer.constrainHorizontallyToSuperview()
        editingViewContainer.constrainBottomToSuperviewSafeArea(inset: 8)

        editingSectionBackgroundView.constrainBottomToSuperview()
        editingSectionBackgroundView.constrainHorizontallyToSuperview()
        editingSectionBackgroundView.constrainTop(to: editingViewSegmentedControl.topAnchor, constant: -16)
    }

    override func configureColors() {
        super.configureColors()
        editingSectionBackgroundView.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
    }

    func editingView(of type: EditingViewType) -> UIView {
        switch type {
        case .texture: return textureEditingView
        case .surface: return surfaceEditingView
        case .corners: return cornersEditingView
        case .haptics: return hapticsEditingView
        }
    }
}

extension EditCardPhysicalView {
    enum EditingViewType: Int, CaseIterable {
        case texture
        case surface
        case corners
        case haptics

        var title: String {
            switch self {
            case .texture: return NSLocalizedString("Texture", comment: "")
            case .surface: return NSLocalizedString("Surface", comment: "")
            case .corners: return NSLocalizedString("Corners", comment: "")
            case .haptics: return NSLocalizedString("Haptics", comment: "")
            }
        }
    }
}
