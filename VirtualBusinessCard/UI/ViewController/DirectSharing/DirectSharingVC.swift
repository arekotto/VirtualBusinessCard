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
        contentView.goToSettingsButton.addTarget(self, action: #selector(didTapGoToSettingsButton), for: .touchUpInside)
        contentView.businessCardImageView.kf.setImage(with: viewModel.businessCardFrontImageURL)
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
    
    func found(code: String) {
        print(code)
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
        show(AcceptCardVC(viewModel: viewModel), sender: nil)
    }
    
    func didFetchData() {
        viewModel.generateQRCode()
    }
    
    func presentErrorReadingQRCodeAlert() {
        let title = NSLocalizedString("QR Could Not Be Read", comment: "")
        let message = NSLocalizedString("Try reading the code again.", comment: "")
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .alert)
        alert.addOkAction() { _ in self.captureSession.startRunning() }
        present(alert, animated: true)
    }
    
    func presentLoadingAlert() {
        // TODO:
    }
    
    func playHapticFeedback() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func presentErrorGeneratingQRCodeAlert() {
        presentUnknownErrorAlert(title: NSLocalizedString("Error Generating QR Code", comment: ""))
    }
    
    func didGenerateQRCode(image: UIImage) {
        contentView.qrCodeImageView.image = image
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



