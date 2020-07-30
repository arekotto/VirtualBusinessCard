//
//  EditBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

/*
import Firebase
import UIKit

class EditBusinessCardMC: BusinessCardMC {
    typealias Model = BusinessCardData

    var newFrontImage: UIImage?

    private(set) var businessCard: BusinessCardData

    private var userID: UserID { Auth.auth().currentUser!.uid }

    var id: String { businessCard.id }

    var originalID: String? { businessCard.originalID }

    var frontImage: BusinessCardData.Image? { businessCard.frontImage }

    var position: BusinessCardData.Position { businessCard.position }

    var name: BusinessCardData.Name { businessCard.name }

    var contact: BusinessCardData.Contact { businessCard.contact }

    var address: BusinessCardData.Address { businessCard.address }

    init() {
        self.businessCard = BusinessCardData(id: "", position: .init(), name: .init(), contact: .init(), address: .init())
    }

    func save() {
        let storage = Storage.storage().reference()
//        if let imageStoragePath = event.imageStoragePath {
//            storage.child(imageStoragePath).delete()
//            event.imageStoragePath = nil
//        }
        if let imageData = newFrontImage?.jpegData(compressionQuality: 0.7) {
            let imageRef = storage.child(Self.imagePath(userID: userID, businessCardID: id, imageID: UUID().uuidString))
//            event.imageStoragePath = imageRef.fullPath
//            storage.put(imageRef)
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                guard let mData = metadata else {
                    return
                }
                imageRef.downloadURL { url, error in

                }
            }
        }
    }
}
*/
