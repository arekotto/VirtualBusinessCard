//
//  DirectSharingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import AVFoundation

final class DirectSharingView: AppView {
    
    let qrCodeImageView: UIImageView = {
        let this = UIImageView()
        this.contentMode = .scaleAspectFit
        this.layer.magnificationFilter = .nearest
        return this
    }()

    let businessCardImageView: UIImageView = {
        let this = UIImageView()
        this.layer.shadowRadius = 5
        this.layer.shadowOpacity = 0.15
        this.layer.shadowOffset = CGSize(width: 0, height: 0)
        this.contentMode = .scaleAspectFit
        return this
    }()

    let goToSettingsButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Take me to Settings", comment: ""), for: .normal)
        this.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
        return this
    }()

    let cancelButtonView: TransparentButtonView = {
        let this = TransparentButtonView(style: .systemMaterial, shapeIntoCircle: true)
        this.setSystemImage("xmark")
        return this
    }()

    private let cameraPreviewOverlay: UIImageView = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight)
        let this = UIImageView(image: UIImage(systemName: "viewfinder", withConfiguration: imageConfig))
        this.tintColor = .white
        this.contentMode = .scaleAspectFit
        return this
    }()

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let cameraPreviewView: UIView = {
        let this = UIView()
        return this
    }()
    
    private let cameraPreviewDisabledLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("QR code scanning could not be enabled. Make sure the app has access to the camera in Settings.", comment: "")
        this.numberOfLines = 0
        this.textAlignment = .center
        return this
    }()
    
    private lazy var cameraPreviewDisabledStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [cameraPreviewDisabledLabel, goToSettingsButton])
        this.axis = .vertical
        this.spacing = 16
        this.isHidden = true
        return this
    }()

    private let qrCodeDescriptionLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Show the card's QR code to your business parnter", comment: "")
        this.textAlignment = .center
        this.numberOfLines = 2
        this.font = .appDefault(size: 13)
        return this
    }()
    
    private let cameraDescriptionLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("scan their card's code.", comment: "")
        this.textAlignment = .center
        this.numberOfLines = 2
        this.font = .appDefault(size: 13)
        return this
    }()

    private lazy var shareCardView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [businessCardImageView, qrCodeImageView])
        this.axis = .horizontal
        this.spacing = 16
        return this
    }()

    let qrCodeActivityIndicator: UIActivityIndicatorView = {
        let this = UIActivityIndicatorView(style: .large)
        this.hidesWhenStopped = true
        return this
    }()

    private let horizontalOrDivider = HorizontalOrDivider()

    private lazy var dividerStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [qrCodeDescriptionLabel, horizontalOrDivider, cameraDescriptionLabel])
        this.axis = .vertical
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [cameraPreviewView, cameraPreviewOverlay, dividerStackView, qrCodeActivityIndicator, shareCardView, cancelButtonView].forEach { addSubview($0) }
        cameraPreviewView.addSubview(cameraPreviewDisabledStackView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()

        cameraPreviewOverlay.constrainCenter(toView: cameraPreviewView)
        cameraPreviewOverlay.constrainHeightEqualTo(cameraPreviewView, multiplier: 0.8)
        cameraPreviewOverlay.constrainWidthEqualTo(cameraPreviewView, multiplier: 0.8)

        cameraPreviewDisabledStackView.constrainCenterYToSuperview()
        cameraPreviewDisabledStackView.constrainHorizontallyToSuperview(sideInset: 24)

        horizontalOrDivider.constrainHeight(constant: 20)
        dividerStackView.constrainHorizontallyToSuperview(sideInset: 20)
        
        cameraPreviewView.constrainHorizontallyToSuperview()
        cameraPreviewView.constrainBottomToSuperview()
        cameraPreviewView.constrainTop(to: dividerStackView.bottomAnchor, constant: 16)

        qrCodeImageView.constrainWidthEqualTo(qrCodeImageView.heightAnchor)
        businessCardImageView.constrainHeight(to: businessCardImageView.widthAnchor, multiplier: CGSize.businessCardHeightToWidthRatio)

        qrCodeActivityIndicator.constrainCenter(toView: qrCodeImageView)

        shareCardView.constrainHorizontallyToSuperview(sideInset: 20)
        shareCardView.constrainBottom(to: dividerStackView.topAnchor, constant: -32)
        shareCardView.constrainTopToSuperviewSafeArea(inset: 32)

        cancelButtonView.constrainCenterXToSuperview()
        cancelButtonView.constrainBottomToSuperviewSafeArea(inset: safeAreaInsets.bottom == 0 ? 16 : 4)
        cancelButtonView.constrainHeight(constant: 50)
        cancelButtonView.constrainWidth(constant: 50)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = cameraPreviewView.layer.bounds
    }

    override func configureColors() {
        super.configureColors()
        qrCodeActivityIndicator.color = Asset.Colors.appAccent.color
        cameraPreviewDisabledLabel.textColor = .secondaryLabel
        cameraDescriptionLabel.textColor = .secondaryLabel
        qrCodeDescriptionLabel.textColor = .secondaryLabel
        cameraPreviewView.backgroundColor = Asset.Colors.appBackground.color
        backgroundColor = Asset.Colors.appBackgroundSecondary.color
    }
    
    func setupPreviewLayer(usingSession session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        cameraPreviewView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    func disableCameraPreview() {
        previewLayer?.removeFromSuperlayer()
        cameraPreviewOverlay.isHidden = true
        cameraPreviewDisabledStackView.isHidden = false
    }
}

extension DirectSharingView {
    private final class HorizontalOrDivider: AppView {
        
        private let leadingHorizontalDivider: UIView = {
            let this = UIView()
            return this
        }()
        
        private let trailingHorizontalDivider: UIView = {
            let this = UIView()
            return this
        }()
        
        private let orLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("OR", comment: "")
            this.textAlignment = .center
            this.font = UIFont.appDefault(size: 16, weight: .light)
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            [leadingHorizontalDivider, orLabel, trailingHorizontalDivider].forEach { addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            
            orLabel.constrainCenterToSuperview()
            leadingHorizontalDivider.constrainCenterYToSuperview()
            trailingHorizontalDivider.constrainCenterYToSuperview()

            leadingHorizontalDivider.constrainLeadingToSuperview()
            leadingHorizontalDivider.constrainTrailing(to: orLabel.leadingAnchor, constant: -16)
            
            trailingHorizontalDivider.constrainTrailingToSuperview()
            trailingHorizontalDivider.constrainLeading(to: orLabel.trailingAnchor, constant: 16)

            leadingHorizontalDivider.constrainHeight(constant: 1)
            trailingHorizontalDivider.constrainHeight(constant: 1)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            leadingHorizontalDivider.backgroundColor = Asset.Colors.appGray.color
            trailingHorizontalDivider.backgroundColor = Asset.Colors.appGray.color
            orLabel.textColor = Asset.Colors.appGray.color
        }
    }
}
