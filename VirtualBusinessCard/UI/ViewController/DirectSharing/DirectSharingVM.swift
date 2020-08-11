//
//  DirectSharingVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

protocol DirectSharingVMDelegate: class {
    func didFetchData()
    func didGenerateQRCode(image: UIImage)
    func didFailToGenerateQRCode()
    func didFailReadingQRCode()
    func presentLoadingAlert(viewModel: LoadingPopoverVM)
    func didBecomeReadyToAcceptCard(with viewModel: AcceptCardVM)
    func didChangeDeviceOrientationX(_ orientation: DirectSharingVM.GeneralDeviceOrientationX)
}

final class DirectSharingVM: CompleteUserViewModel, MotionDataSource {
    
    weak var delegate: DirectSharingVMDelegate?
    
    private(set) var qrCode: UIImage?
    private(set) lazy var motionManager = CMMotionManager()

    private(set) var generalDeviceOrientationX = GeneralDeviceOrientationX.vertical
    private var motionPitchForLastOrientationUpdate = 1.5

    private let card: PersonalBusinessCardMC

    private var ownSharingExchangeData: DirectSharingExchangeData?
    private var ownSharingExchangeDataDocumentRef: DocumentReference?
    private var ownExchangeSnapshotListener: ListenerRegistration?

    private var joinedSharingExchangeData: DirectCardExchangeMC?
    private var joinedExchangeSnapshotListener: ListenerRegistration?

    init(userID: UserID, sharedCard: PersonalBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }
    
    override func informDelegateAboutDataRefresh() {
        delegate?.didFetchData()
    }

    private func playHapticFeedback(of sharpness: Float) {
        HapticFeedbackEngine(sharpness: sharpness, intensity: 0.6).play()
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {

        let pitch = motion.attitude.pitch
        let isDifferenceSignificantEnoughToUpdate = abs(pitch - motionPitchForLastOrientationUpdate) > 0.15
        guard isDifferenceSignificantEnoughToUpdate else { return }
        let newOrientation: GeneralDeviceOrientationX = pitch <= 0.3 ? .horizontal : .vertical
        guard newOrientation != generalDeviceOrientationX else { return }
        changeOrientation(to: newOrientation, motionPitch: pitch)
    }

    private func changeOrientation(to newOrientation: GeneralDeviceOrientationX, motionPitch: Double) {
        generalDeviceOrientationX = newOrientation
        motionPitchForLastOrientationUpdate = motionPitch
        delegate?.didChangeDeviceOrientationX(newOrientation)
    }
}

// MARK: - Static helpers

private extension DirectSharingVM {
    static func randomAccessToken(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}

// MARK: - ViewController API

extension DirectSharingVM {
    var title: String {
        NSLocalizedString("Share Card", comment: "")
    }
    
    var cancelButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }

    var businessCardFrontImageURL: URL? {
        card.frontImage.url
    }

    var hasPerformedInitialFetch: Bool {
        user?.containsPrivateData ?? false
    }

    func cancelSharing() {
        ownSharingExchangeDataDocumentRef?.delete()
        ownExchangeSnapshotListener?.remove()
        joinedExchangeSnapshotListener?.remove()
    }
    
    func beginSharing() {
        let accessToken = Self.randomAccessToken(length: 20)
        
        let docRef = directCardExchangeReference.document()
        let exchange = DirectCardExchange(
            id: docRef.documentID,
            accessToken: accessToken,
            sharingUserID: userID,
            sharingUserCardID: card.id,
            sharingUserCardLocalizations: card.languageVersions,
            sharingUserMostRecentUpdate: Date()
        )

        docRef.setData(exchange.asDocument()) { [weak self] error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                print(#file, "Error creating exchange:", docRef.documentID)
                self.delegate?.didFailToGenerateQRCode()
                return
            }

            self.ownExchangeSnapshotListener?.remove()
            self.ownSharingExchangeDataDocumentRef = docRef
            self.ownExchangeSnapshotListener = docRef.addSnapshotListener { [weak self] docSnapshot, error in
                self?.initiatedExchangeDidChange(docSnapshot, error)
            }
            
            self.ownSharingExchangeData = DirectSharingExchangeData(userID: self.userID, exchangeID: docRef.documentID, accessToken: accessToken)
            guard let jsonData = try? JSONEncoder().encode(self.ownSharingExchangeData!) else {
                self.delegate?.didFailToGenerateQRCode()
                return
            }
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                self.delegate?.didFailToGenerateQRCode()
                return
            }
            guard let qrCode = QRCodeGenerator.shared.generate(from: jsonString) else {
                self.delegate?.didFailToGenerateQRCode()
                return
            }
            self.qrCode = qrCode
            self.delegate?.didGenerateQRCode(image: qrCode)
        }
    }
    
    func joinExchange(using string: String) {
        guard let jsonData = string.data(using: .utf8) else {
            delegate?.didFailReadingQRCode()
            return
        }
        
        guard let exchange = try? JSONDecoder().decode(DirectSharingExchangeData.self, from: jsonData) else {
            delegate?.didFailReadingQRCode()
            return
        }

        guard exchange.userID != userID else {
            delegate?.didFailReadingQRCode()
            return
        }

        delegate?.presentLoadingAlert(viewModel: LoadingPopoverVM(title: NSLocalizedString("Sharing card", comment: "")))

        user?.addCardExchangeAccessToken(exchange.accessToken)
        user?.save { [weak self] result in
            switch result {
            case .failure: self?.delegate?.didFailReadingQRCode()
            case .success:
                guard let joinedExchangeDoc = self?.directCardExchangeReference.document(exchange.exchangeID) else {
                    self?.delegate?.didFailReadingQRCode()
                    return
                }
                self?.joinedExchangeSnapshotListener?.remove()
                self?.joinedExchangeSnapshotListener = joinedExchangeDoc.addSnapshotListener { [weak self] documentSnapshot, error in
                    self?.joinedExchangeDidChange(documentSnapshot, error)
                }
            }
        }
    }
}

// MARK: - Firebase

extension DirectSharingVM {
    private var directCardExchangeReference: CollectionReference {
        db.collection(DirectCardExchange.collectionName)
    }
    
    private func initiatedExchangeDidChange(_ documentSnapshot: DocumentSnapshot?, _ error: Error?) {
        guard let docSnap = documentSnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        guard let initiatedExchange = DirectCardExchange(documentSnapshot: docSnap) else {
            print(#file, "Error mapping exchange:", docSnap.documentID)
            return
        }

        guard let receivingUserID = initiatedExchange.receivingUserID else { return }
        guard let receivingUserCardID = initiatedExchange.receivingUserCardID else { return }
        guard let receivingUserCardLocalizations = initiatedExchange.receivingUserCardLocalizations else { return }

        guard receivingUserID != self.userID else { return }

        let receivedCard = EditReceivedBusinessCardMC(
            originalID: receivingUserCardID,
            exchangeID: initiatedExchange.id,
            ownerID: receivingUserID,
            languageVersions: receivingUserCardLocalizations
        )

        user?.addExchange(id: initiatedExchange.id, toCardID: card.id)
        user?.save()

        ownExchangeSnapshotListener?.remove()
        playHapticFeedback(of: receivedCard.displayedLocalization.hapticFeedbackSharpness)
        delegate?.didBecomeReadyToAcceptCard(with: AcceptCardVM(userID: userID, sharedCard: receivedCard))
    }
    
    private func joinedExchangeDidChange(_ documentSnapshot: DocumentSnapshot?, _ error: Error?) {
        guard let docSnap = documentSnapshot else {
            delegate?.didFailReadingQRCode()
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        guard let exchangeModel = DirectCardExchange(documentSnapshot: docSnap) else {
            delegate?.didFailReadingQRCode()
            print(#file, "Error mapping exchange:", docSnap.documentID)
            return
        }
        
        joinedExchangeSnapshotListener?.remove()
        let joinedExchange = DirectCardExchangeMC(exchange: exchangeModel)
        joinedExchange.receivingUserID = userID
        joinedExchange.receivingUserCardID = card.id
        joinedExchange.receivingUserCardLocalizations = card.languageVersions
        joinedExchange.receivingUserMostRecentUpdate = Date()

        joinedSharingExchangeData = joinedExchange
        joinedSharingExchangeData?.saveScanningUserData(in: directCardExchangeReference) { [weak self] result in

            guard let self = self else { return }
            guard let joinedSharingExchangeData = self.joinedSharingExchangeData else { return }

            switch result {
            case .failure(let error):
                print(#file, "Error uploading data to joined exchange:", error.localizedDescription)
                self.delegate?.didFailReadingQRCode()
            case .success:

                let receivedCard = EditReceivedBusinessCardMC(
                    originalID: joinedSharingExchangeData.sharingUserID,
                    exchangeID: joinedSharingExchangeData.id,
                    ownerID: joinedSharingExchangeData.sharingUserID,
                    languageVersions: joinedSharingExchangeData.sharingUserCardLocalizations
                )

                self.ownSharingExchangeDataDocumentRef?.delete()

                self.user?.addExchange(id: joinedSharingExchangeData.id, toCardID: self.card.id)
                self.user?.save()

                self.playHapticFeedback(of: receivedCard.displayedLocalization.hapticFeedbackSharpness)
                self.delegate?.didBecomeReadyToAcceptCard(with: AcceptCardVM(userID: self.userID, sharedCard: receivedCard))
            }
        }
    }
}

extension DirectSharingVM {
    enum GeneralDeviceOrientationX {
        case horizontal, vertical

        static func calculate(for deviceMotion: CMDeviceMotion) -> GeneralDeviceOrientationX {
            deviceMotion.attitude.pitch <= 0.3 ? .horizontal : .vertical
        }
    }
}

// MARK: - DirectSharingExchangeData

private extension DirectSharingVM {
    struct DirectSharingExchangeData: Codable {
        var userID: UserID
        var exchangeID: DirectCardExchangeID
        var accessToken: String
    }
}
