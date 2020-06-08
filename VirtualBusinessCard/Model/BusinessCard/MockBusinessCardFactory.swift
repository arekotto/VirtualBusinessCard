//
//  MockBusinessCardFactory.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 05/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

final class MockBusinessCardFactory {
    
    static let shared = MockBusinessCardFactory()
    
    private init() {}
    
    var cards: [ViewBusinessCardMC] {
        [
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card1",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),
                position: .init(title: "CEO", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card2",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),

                position: .init(title: "CFO", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card3",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),

                position: .init(title: "CTO", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card4",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),

                position: .init(title: "Manager", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card5",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),

                position: .init(title: "Manager", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
            ViewBusinessCardMC(businessCard: BusinessCard(
                id: "card6",
                originalID: nil,
                frontImage: .init(id: "card1front", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/SG9PehBemcUNLU8tajT3hmW5EJZ2%2Fcard1%2Fcard1front.png?alt=media&token=e38c0555-abf1-490d-8209-afc7456ff150")!),

                position: .init(title: "Manager", company: "IBM"),
                name: .init(prefix: "dr.", first: "John", middle: nil, last: "Smith"),
                contact: .init(email: "john@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: nil, fax: nil, website: "www.ibm.com"),
                address: .init(country: nil, city: nil, postCode: nil, street: nil))
            ),
        ]
    }
    
}
