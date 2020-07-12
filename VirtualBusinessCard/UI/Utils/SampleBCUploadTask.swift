//
//  SampleBCUploadTask.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

struct SampleBCUploadTask {
    
    func callAsFunction(completion: @escaping (Result<Void, Error>) -> Void) {
        
        // MARK: Data
        
        let userID = Auth.auth().currentUser!.uid
        let personalBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(PersonalBusinessCard.collectionName)
        let receivedBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(ReceivedBusinessCard.collectionName)
        let tagsCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(BusinessCardTag.collectionName)
        
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
        
        let companies = ["IBM", "Microsoft", "Sony", "Apple"]
        let tags = ["Important", "Conference in Copenhagen", "Can delete soon"]
        let tagIDs: [BusinessCardTagID] = tags.enumerated().map { idx, tag in
            let docRef = tagsCollectionRef.document()
            docRef.setData(BusinessCardTag(id: docRef.documentID, tagColor: BusinessCardTag.TagColor.allCases.randomElement()!, title: tag, priorityIndex: idx, description: nil).asDocument())
            return docRef.documentID
        }
        // MARK: Data upload

        Name.samples.enumerated().forEach { idx, person in
            let docRef = personalBCCollectionRef.document()
            let bcData = BusinessCardData(
                frontImage: .init(id: "card1front", url: imageURLs.randomElement()!),
                                  backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                                  texture: .init(image: BusinessCardData.Image(id: "test", url: texturesURLs.randomElement()!), specular: specularValues.randomElement()!, normal: specularValues.randomElement()!),
                                  position: BusinessCardData.Position(title: "Manager", company: "IBM"),
                                  name: BusinessCardData.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                                  contact: BusinessCardData.Contact(email: "\(person.lastName)@ibm.com", phoneNumberPrimary: "123321123"),
                                  address: BusinessCardData.Address())
            let personalBC = PersonalBusinessCard(id: docRef.documentID, creationDate: day(from: Date(), offset: idx % 5), cardData: bcData)
            docRef.setData(personalBC.asDocument())
        }
        
        (Name.samples + Name.samples).enumerated().forEach { idx, person in
            let docRef = receivedBCCollectionRef.document()
            let company = companies.safeMod(idx)
            let bcData = BusinessCardData(
                                  frontImage: .init(id: "card1front", url: imageURLs[idx % imageURLs.count]),
                                  backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                                  texture: .init(image: BusinessCardData.Image(id: "test", url: texturesURLs.randomElement()!), specular: specularValues.randomElement()!, normal: specularValues.randomElement()!),
                                  position: BusinessCardData.Position(title: "Manager", company: company),
                                  name: BusinessCardData.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                                  contact: BusinessCardData.Contact(email: "\(person.lastName.lowercased())@\(company.lowercased()).com", phoneNumberPrimary: "123321123", phoneNumberSecondary: "648265932", website: "www.\(company.lowercased()).com"),
                                  address: BusinessCardData.Address(country: "Denmark", city: "Copenhagen", postCode: "2100", street: "Tasingegade 33"))
            
            let cardTagIDs: [BusinessCardTagID]
            switch idx % 3 {
            case 0: cardTagIDs = [tagIDs[idx % tagIDs.count], tagIDs[(idx + 1) % tagIDs.count]]
            case 1: cardTagIDs = [tagIDs[idx % tagIDs.count]]
            default: cardTagIDs = []
            }
            
            let personalBC = ReceivedBusinessCard(id: docRef.documentID, originalID: "some old ID", ownerID: "Test User", receivingDate: day(from: Date(), offset: idx % 5), cardData: bcData, tagIDs: cardTagIDs)
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
    
    private func day(from date: Date, offset: Int) -> Date {
        var now = Calendar.current.dateComponents(in: .current, from: date)
        now.day = now.day! - offset
        now.month = now.month! - (offset % 3)
        now.year = now.year! - (offset % 2)
        return Calendar.current.date(from: now)!
    }
}


private extension Array {
    func safeMod(_ idx: Int) -> Element {
        self[idx % count]
    }
}
