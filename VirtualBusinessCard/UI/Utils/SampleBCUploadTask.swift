//
//  SampleBCUploadTask.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

struct SampleBCUploadTask {

    
    func callAsFunction(completion: @escaping (Result<Void, Error>) -> Void) {

        let userID = Auth.auth().currentUser!.uid
        let personalBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(PersonalBusinessCard.collectionName)
        let receivedBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(ReceivedBusinessCard.collectionName)

        let imageURLs = [
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Back.png?alt=media&token=6a28dce4-14d4-4d6c-abb4-9577615f447d")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard2Front.jpg?alt=media&token=fbcd38a0-3e25-4391-ad43-e82e38ce91ba")!
        ]
        
        let texturesURLs = [
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsamplePaperNormalMap.jpg?alt=media&token=b9d0adf0-86a4-4912-805b-99212f87b269")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FpaperNormalMap2.jpg?alt=media&token=5634474e-1a98-4f98-afc1-2d8fb40f5c12")!
        ]
        
        let specularValues = [0.1, 0.5, 1.5]
//        let normlas = [0.1, 0.5, 1.5]

        Name.samples.enumerated().forEach { idx, person in
            let docRef = personalBCCollectionRef.document()
            let bcData = BusinessCardData(
                                  frontImage: .init(id: "card1front", url: imageURLs[idx % imageURLs.count]),
                                  backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                                  texture: .init(image: BusinessCardData.Image(id: "test", url: texturesURLs[idx % texturesURLs.count]), specular: specularValues[idx % specularValues.count], normal: specularValues[idx % specularValues.count]),
                                  position: BusinessCardData.Position(title: "Manager", company: "IBM"),
                                  name: BusinessCardData.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                                  contact: BusinessCardData.Contact(email: "\(person.lastName)@ibm.com", phoneNumberPrimary: "123321123"),
                                  address: BusinessCardData.Address())
            let personalBC = PersonalBusinessCard(id: docRef.documentID, creationDate: Date(), cardData: bcData)
            docRef.setData(personalBC.asDocument())
        }
        
        (Name.samples + Name.samples).enumerated().forEach { idx, person in
            let docRef = receivedBCCollectionRef.document()
            let bcData = BusinessCardData(
                                  frontImage: .init(id: "card1front", url: imageURLs[idx % imageURLs.count]),
                                  backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                                  texture: .init(image: BusinessCardData.Image(id: "test", url: texturesURLs[idx % texturesURLs.count]), specular: specularValues[idx % specularValues.count], normal: specularValues[idx % specularValues.count]),
                                  position: BusinessCardData.Position(title: "Manager", company: "IBM"),
                                  name: BusinessCardData.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                                  contact: BusinessCardData.Contact(email: "\(person.lastName)@ibm.com", phoneNumberPrimary: "123321123"),
                                  address: BusinessCardData.Address())
            let personalBC = ReceivedBusinessCard(id: docRef.documentID, originalID: "some old ID", receivingDate: Date(), cardData: bcData)
            docRef.setData(personalBC.asDocument())
        }
    }
    
    private struct Name {
        let firstName: String
        let lastName: String
        
        static var samples: [Name] {
            [
                Name(firstName: "Alia", lastName: "Huff"),
                Name(firstName: "Maddie", lastName: "Bone"),
                Name(firstName: "Ella", lastName: "Potts"),
                Name(firstName: "Brenda", lastName: "Mckeown"),
                Name(firstName: "Jenna", lastName: "Povey"),
                Name(firstName: "Hetty", lastName: "Hackett"),
                Name(firstName: "Mahdi", lastName: "Barker"),
                Name(firstName: "Isabel", lastName: "Wilkes"),
                Name(firstName: "Izzy", lastName: "Corrigan"),
                Name(firstName: "Kaitlan", lastName: "Solis")
            ]
        }
    }
}
