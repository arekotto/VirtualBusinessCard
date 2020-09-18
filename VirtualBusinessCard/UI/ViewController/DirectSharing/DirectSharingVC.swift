//
//  DirectSharingVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import AVFoundation
import UIKit
import Kingfisher

final class DirectSharingVC: AppViewController<DirectSharingView, DirectSharingVM> {
    
    private var captureSession: AVCaptureSession!
    private var appearanceCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        navigationItem.title = viewModel.title
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupContentView()
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startUpdatingMotionData(in: 0.2)
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
        if appearanceCounter != 0 && viewModel.hasPerformedInitialFetch {
            contentView.qrCodeActivityIndicator.startAnimating()
            contentView.qrCodeImageView.image = nil
            viewModel.beginSharing()
        }
        appearanceCounter += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.pauseUpdatingMotionData()
    }
    
    private func setupContentView() {
        contentView.goToSettingsButton.addTarget(self, action: #selector(didTapGoToSettingsButton), for: .touchUpInside)
        contentView.businessCardView.setDataModel(viewModel.cardDataModel)
        contentView.cancelButtonView.button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        contentView.qrCodeActivityIndicator.startAnimating()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            contentView.disableCameraPreview()
            return
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            contentView.disableCameraPreview()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()

        guard captureSession.canAddInput(videoInput) else {
            contentView.disableCameraPreview()
            return
        }
        guard captureSession.canAddOutput(metadataOutput) else {
            contentView.disableCameraPreview()
            return
        }

        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        contentView.setupPreviewLayer(usingSession: captureSession)
        captureSession.startRunning()
    }
}

// MARK: - DirectSharingVMDelegate

extension DirectSharingVC: DirectSharingVMDelegate {
    func didChangeDeviceOrientationX(_ orientation: DirectSharingVM.GeneralDeviceOrientationX) {
        switch orientation {
        case .horizontal:
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.contentView.businessCardView.transform = CGAffineTransform.identity.rotated(by: .pi)
            })
        case .vertical:
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.contentView.businessCardView.transform = CGAffineTransform.identity
            })
        }
    }

    func didBecomeReadyToAcceptCard(with viewModel: AcceptCardVM) {
        if let loadingAlert = presentedViewController {
            loadingAlert.dismiss(animated: true) {
                self.show(AcceptCardVC(viewModel: viewModel), sender: nil)
            }
        } else {
            show(AcceptCardVC(viewModel: viewModel), sender: nil)
        }
    }
    
    func didFetchData() {
        guard viewModel.qrCode == nil else { return }
        viewModel.beginSharing()
    }
    
    func didFailReadingQRCode() {
        let message = NSLocalizedString("QR code could not be read. Try pointing the camera at it again.", comment: "")
        if let loadingAlert = presentedViewController {
            loadingAlert.dismiss(animated: true) {
                self.presentErrorAlert(message: message) { _ in self.captureSession.startRunning() }
            }
        } else {
            presentErrorAlert(message: message) { _ in self.captureSession.startRunning() }
        }
    }
    
    func didFailToGenerateQRCode() {
        presentErrorAlert(message: NSLocalizedString("We couldn't generate a QR code for your card. Please try again.", comment: ""))
    }
    
    func didGenerateQRCode(image: UIImage) {
        contentView.qrCodeImageView.image = image
        contentView.qrCodeActivityIndicator.stopAnimating()
    }
}

// MARK: - Actions

@objc
private extension DirectSharingVC {
    func didTapCancelButton() {
        viewModel.cancelSharing()
        dismiss(animated: true)
    }
    
    func didTapGoToSettingsButton() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension DirectSharingVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        guard let scannedString = (metadataObjects.first as? AVMetadataMachineReadableCodeObject)?.stringValue else {
            return
        }
        viewModel.joinExchange(using: scannedString)
    }
}
