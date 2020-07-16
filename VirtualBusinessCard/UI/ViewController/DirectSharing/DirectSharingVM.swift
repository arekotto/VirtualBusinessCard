//
//  DirectSharingVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol DirectSharingVMDelegate: class {
    func didFetchData()
    func didGenerateQRCode(image: UIImage)
    func presentErrorGeneratingQRCodeAlert()
    func presentErrorReadingQRCodeAlert()
    func playHapticFeedback()
    func presentLoadingAlert()
    func presentAcceptCardVC(with viewModel: AcceptCardVM)
}

final class DirectSharingVM: UserViewModel {
    
    weak var delegate: DirectSharingVMDelegate?
    
    private(set) var qrCode: UIImage?

    private let card: PersonalBusinessCardMC
    
    private var directSharingExchangeData: DirectSharingExchangeData?
    private var joinedExchangeSnapshotListener: ListenerRegistration?
    
    init(userID: UserID, sharedCard: PersonalBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }
    
    override func informDelegateAboutDataRefresh() {
        delegate?.didFetchData()
    }
}

// MARK: - Static helpers

private extension DirectSharingVM {
    static func randomAccessToken(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
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
    
    func generateQRCode() {
        let accessToken = Self.randomAccessToken(length: 20)
        
        let docRef = directCardExchangeReference.document()
        let exchange = DirectCardExchange(id: docRef.documentID, accessToken: accessToken, sharingUserID: userID, sharingUserCardID: card.id, sharingUserCardData: card.businessCard.cardData)
        docRef.setData(exchange.asDocument()) { [weak self] error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                print(#file, "Error creating exchange:", docRef.documentID)
                self.delegate?.presentErrorGeneratingQRCodeAlert()
                return
            }
            
            docRef.addSnapshotListener { [weak self] docSnapshot, error in
                self?.initiatedExchangeDidChange(docSnapshot, error)
            }
            
            self.directSharingExchangeData = DirectSharingExchangeData(userID: self.userID, exchangeID: docRef.documentID, accessToken: accessToken)
            guard let jsonData = try? JSONEncoder().encode(self.directSharingExchangeData!) else {
                self.delegate?.presentErrorGeneratingQRCodeAlert()
                return
            }
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                self.delegate?.presentErrorGeneratingQRCodeAlert()
                return
            }
            guard let qrCode = QRCodeGenerator.shared.generate(from: jsonString) else {
                self.delegate?.presentErrorGeneratingQRCodeAlert()
                return
            }
            
            self.delegate?.didGenerateQRCode(image: qrCode)
        }
    }
    
    func didScanCode(string: String) {
        guard let jsonData = string.data(using: .utf8) else {
            delegate?.presentErrorReadingQRCodeAlert()
            return
        }
        
        guard let exchange = try? JSONDecoder().decode(DirectSharingExchangeData.self, from: jsonData) else {
            delegate?.presentErrorReadingQRCodeAlert()
            return
        }

        guard exchange.userID != userID else {
            delegate?.presentErrorReadingQRCodeAlert()
            return
        }
        
        user?.addCardExchangeAccessToken(exchange.accessToken)
        user?.save() { [weak self] result in
            switch result {
            case .failure(_): self?.delegate?.presentErrorReadingQRCodeAlert()
            case .success:
                guard let joinedExchangeDoc = self?.directCardExchangeReference.document(exchange.exchangeID) else {
                    self?.delegate?.presentErrorReadingQRCodeAlert()
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
        guard let receivingUserCardData = initiatedExchange.receivingUserCardData else { return }

        guard receivingUserID != self.userID else { return }

        let receivedCard = ReceivedBusinessCardMC(originalID: receivingUserCardID, ownerID: receivingUserID, cardData: receivingUserCardData)

        delegate?.playHapticFeedback()
        delegate?.presentAcceptCardVC(with: AcceptCardVM(userID: userID, sharedCard: receivedCard))
    }
    
    private func joinedExchangeDidChange(_ documentSnapshot: DocumentSnapshot?, _ error: Error?) {
        guard let docSnap = documentSnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        
        guard let exchangeModel = DirectCardExchange(documentSnapshot: docSnap) else {
            print(#file, "Error mapping exchange:", docSnap.documentID)
            return
        }
        
        joinedExchangeSnapshotListener?.remove()
        let joinedExchange = DirectCardExchangeMC(exchange: exchangeModel)
        joinedExchange.receivingUserID = userID
        joinedExchange.receivingUserCardID = card.id
        joinedExchange.receivingUserCardData = card.businessCard.cardData
        joinedExchange.saveScanningUserData(in: directCardExchangeReference) { [weak self] result in

            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print(#file, "Error uploading data to joined exchange:", error.localizedDescription)
                self.delegate?.presentErrorReadingQRCodeAlert()
            case .success:

                self.delegate?.playHapticFeedback()
                let receivedCard = ReceivedBusinessCardMC(
                    originalID: joinedExchange.sharingUserID,
                    ownerID: joinedExchange.sharingUserID,
                    cardData: joinedExchange.sharingUserCardData
                )
                self.delegate?.presentAcceptCardVC(with: AcceptCardVM(userID: self.userID, sharedCard: receivedCard))
            }
        }
    }
}

private extension DirectSharingVM {
    struct DirectSharingExchangeData: Codable {
        var userID: UserID
        var exchangeID: DirectCardExchangeID
        var accessToken: String
    }
}

struct QRCodeGenerator {
    
    private(set) static var shared = Self()
    
    private init() {}
    
    func generate(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }
}
