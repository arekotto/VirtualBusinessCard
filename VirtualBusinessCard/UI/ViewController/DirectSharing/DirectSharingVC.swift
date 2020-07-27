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
    
    private lazy var cancelButton = UIBarButtonItem(title: viewModel.cancelButtonTitle, style: .plain, target: self, action: #selector(didTapCancelButton))
    
    var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupNavigationItem()
        setupContentView()
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func setupContentView() {
        contentView.goToSettingsButton.addTarget(self, action: #selector(didTapGoToSettingsButton), for: .touchUpInside)
        contentView.businessCardImageView.kf.setImage(with: viewModel.businessCardFrontImageURL)
        contentView.qrCodeActivityIndicator.startAnimating()
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title
        navigationItem.leftBarButtonItem = cancelButton
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

    func presentAcceptCardVC(with viewModel: AcceptCardVM) {
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
        viewModel.generateQRCode()
    }
    
    func presentErrorReadingQRCodeAlert() {
        let message = NSLocalizedString("QR code could not be read. Try pointing the camera at it again.", comment: "")
        if let loadingAlert = presentedViewController {
            loadingAlert.dismiss(animated: true) {
                self.presentErrorAlert(message: message) { _ in self.captureSession.startRunning() }
            }
        } else {
            presentErrorAlert(message: message) { _ in self.captureSession.startRunning() }
        }
    }
    
    func presentErrorGeneratingQRCodeAlert() {
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
        viewModel.didScanCode(string: scannedString)
    }
}



