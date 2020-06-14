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
        let bcCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(BusinessCard.collectionName)


        Name.samples.forEach { person in
            let docRef = bcCollectionRef.document()
            let bc = BusinessCard(id: docRef.documentID,
                                  frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Back.png?alt=media&token=6a28dce4-14d4-4d6c-abb4-9577615f447d")!),
                                  backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                                  textureImage: .init(id: "card1texture", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1texture.jpg?alt=media&token=66034eee-2edc-42cd-bbc4-1d83fb7c3e25")!),
                                  position: BusinessCard.Position(title: "Manager", company: "IBM"),
                                  name: BusinessCard.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                                  contact: BusinessCard.Contact(email: "\(person.lastName)@ibm.com", phoneNumberPrimary: "123321123"),
                                  address: BusinessCard.Address())
            docRef.setData(bc.asDocument())
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
