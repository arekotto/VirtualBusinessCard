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
    func presentLoadingAlert(title: String)
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
    }
    
    func beginSharing() {
        let accessToken = Self.randomAccessToken(length: 20)
        
        let docRef = directCardExchangeReference.document()
        let exchange = DirectCardExchange(
            id: docRef.documentID,
            accessToken: accessToken,
            ownerID: userID,
            ownerCardID: card.id,
            ownerCardLocalizations: card.localizations,
            ownerCardVersion: 0,
            guestCardVersion: 0
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
        guard let user = self.user, user.containsPrivateData else { return }

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

        delegate?.presentLoadingAlert(title: NSLocalizedString("Sharing card", comment: ""))

        user.addCardExchangeAccessToken(exchange.accessToken)

        directCardExchangeReference.firestore.runTransaction { transaction, errorPointer in
            user.save(using: transaction)
            return nil
        } completion: { [weak self] _, error in
            if let err = error {
                print(#file, err.localizedDescription)
                self?.delegate?.didFailReadingQRCode()
            } else {
                self?.runJoinExchangeTransaction(exchangeID: exchange.exchangeID)
            }
        }
    }

    private func runJoinExchangeTransaction(exchangeID: DirectCardExchangeID) {
        db.runTransaction { [weak self] transaction, errorPointer in
            guard let self = self else { return nil }

            let exchangeReference = self.directCardExchangeReference.document(exchangeID)
            let joinedExchange: DirectCardExchangeMC
            let user: UserMC
            do {
                let publicUserDoc = try transaction.getDocument(self.userPublicDocumentReference)
                let publicUser = try UserPublic(unwrappedWithDocumentSnapshot: publicUserDoc)

                let privateUserDoc = try transaction.getDocument(self.userPrivateDocumentReference)
                let privateUser = try UserPrivate(unwrappedWithDocumentSnapshot: privateUserDoc)

                user = UserMC(userPublic: publicUser, userPrivate: privateUser)
                joinedExchange = try DirectCardExchangeMC(unwrappedWithExchangeDocument: try transaction.getDocument(exchangeReference))
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            user.addExchange(id: joinedExchange.id, toCardID: self.card.id)

            user.save(using: transaction)

            joinedExchange.guestID = self.userID
            joinedExchange.guestCardID = self.card.id
            joinedExchange.guestCardLocalizations = self.card.localizations
            joinedExchange.guestCardVersion = self.card.currentVersion

            transaction.updateData(joinedExchange.asDocument(), forDocument: exchangeReference)

            return joinedExchange

        } completion: { [weak self] exchange, error in

            guard let joinedExchange = exchange as? DirectCardExchangeMC else {
                print(#file, error?.localizedDescription ?? "")
                self?.delegate?.didFailReadingQRCode()
                return
            }

            self?.prepareCardAfterSuccessfulTransaction(for: joinedExchange)
        }
    }

    private func prepareCardAfterSuccessfulTransaction(for exchange: DirectCardExchangeMC) {

        let receivedCard = EditReceivedBusinessCardMC(
            originalID: exchange.ownerID,
            exchangeID: exchange.id,
            ownerID: exchange.ownerID,
            version: exchange.ownerCardVersion,
            localizations: exchange.ownerCardLocalizations
        )

        ownSharingExchangeDataDocumentRef?.delete()

        playHapticFeedback(of: receivedCard.displayedLocalization.hapticFeedbackSharpness)
        delegate?.didBecomeReadyToAcceptCard(with: AcceptCardVM(userID: userID, sharedCard: receivedCard))
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

        guard let receivingUserID = initiatedExchange.guestID else { return }
        guard let receivingUserCardID = initiatedExchange.guestCardID else { return }
        guard let receivingUserCardLocalizations = initiatedExchange.guestCardLocalizations else { return }

        guard receivingUserID != self.userID else { return }

        let receivedCard = EditReceivedBusinessCardMC(
            originalID: receivingUserCardID,
            exchangeID: initiatedExchange.id,
            ownerID: receivingUserID,
            version: initiatedExchange.guestCardVersion,
            localizations: receivingUserCardLocalizations
        )

        user?.addExchange(id: initiatedExchange.id, toCardID: card.id)
        user?.save()

        ownExchangeSnapshotListener?.remove()
        playHapticFeedback(of: receivedCard.displayedLocalization.hapticFeedbackSharpness)
        delegate?.didBecomeReadyToAcceptCard(with: AcceptCardVM(userID: userID, sharedCard: receivedCard))
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
