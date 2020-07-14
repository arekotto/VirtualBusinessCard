//
//  DirectSharingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import AVFoundation

final class DirectSharingView: AppBackgroundView {
    
    let qrCodeImageView: UIImageView = {
        let this = UIImageView()
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
        this.text = NSLocalizedString("QR code scanning could be enabled. Make sure the app has access to the camera in Settings.", comment: "")
        this.numberOfLines = 0
        this.textAlignment = .center
        return this
    }()
    
    let goToSettingsButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Take me to Settings", comment: ""), for: .normal)
        this.setTitleColor(.appAccent, for: .normal)
        return this
    }()
    
    private lazy var cameraPreviewDisabledStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [cameraPreviewDisabledLabel, goToSettingsButton])
        this.axis = .vertical
        this.spacing = 16
        this.isHidden = true
        return this
    }()
    
    
    private let cameraDescriptionLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Scan the QR code of your business partner's card", comment: "")
        this.textAlignment = .center
        this.numberOfLines = 2
        this.font = .appDefault(size: 14)
        return this
    }()
    
    private let qrCodeDescriptionLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("show them your card's QR code.", comment: "")
        this.textAlignment = .center
        this.numberOfLines = 2
        this.font = .appDefault(size: 14)
        return this
    }()
    
    private let horizontalOrDivider = HorizontalOrDivider()
    
    override func configureSubviews() {
        super.configureSubviews()
        [cameraPreviewView, horizontalOrDivider, cameraDescriptionLabel, qrCodeDescriptionLabel, qrCodeImageView].forEach { addSubview($0) }
        cameraPreviewView.addSubview(cameraPreviewDisabledStackView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        
        cameraPreviewDisabledStackView.constrainCenterYToSuperview()
        cameraPreviewDisabledStackView.constrainHorizontallyToSuperview(sideInset: 24)

        horizontalOrDivider.constrainCenterToSuperview()
        horizontalOrDivider.constrainHeight(constant: 20)
        horizontalOrDivider.constrainHorizontallyToSuperview(sideInset: 40)
        
        cameraPreviewView.constrainHorizontallyToSuperview()
        cameraPreviewView.constrainTopToSuperviewSafeArea()
        cameraPreviewView.constrainBottom(to: cameraDescriptionLabel.topAnchor, constant: -16)
        
        cameraDescriptionLabel.constrainHorizontallyToSuperview(sideInset: 16)
        cameraDescriptionLabel.constrainBottom(to: horizontalOrDivider.topAnchor, constant: -8)

        qrCodeDescriptionLabel.constrainHorizontallyToSuperview(sideInset: 16)
        qrCodeDescriptionLabel.constrainTop(to: horizontalOrDivider.bottomAnchor, constant: 8)

        qrCodeImageView.constrainCenterXToSuperview()
        qrCodeImageView.constrainTop(to: qrCodeDescriptionLabel.bottomAnchor, constant: 16)
        qrCodeImageView.constrainHeight(constant: 100)
        qrCodeImageView.constrainWidth(constant: 100)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cameraPreviewDisabledLabel.textColor = .secondaryLabel
        cameraDescriptionLabel.textColor = .secondaryLabel
        qrCodeDescriptionLabel.textColor = .secondaryLabel
        cameraPreviewView.backgroundColor = .appDefaultBackground

        previewLayer?.frame = cameraPreviewView.layer.bounds
    }
    
    func setupPreviewLayer(usingSession session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        cameraPreviewView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    func disableCameraPreview() {
        previewLayer?.removeFromSuperlayer()
        cameraPreviewDisabledStackView.isHidden = false
    }
}

extension DirectSharingView {
    final class HorizontalOrDivider: AppView {
        
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
            leadingHorizontalDivider.backgroundColor = .appGray
            trailingHorizontalDivider.backgroundColor = .appGray
            orLabel.textColor = .appGray
        }
    }
}
