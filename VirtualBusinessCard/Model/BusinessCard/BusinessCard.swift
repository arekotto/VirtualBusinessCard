//
//  BusinessCard.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias BusinessCardID = String

struct BusinessCard: Codable {

    let id: BusinessCardID
    let originalID: BusinessCardID?

    var frontImage: Image?
    var backImage: Image?
    var textureImage: Image?
    
    var position: Position
    var name: Name
    var contact: Contact
    var address: Address
    
    internal init(id: BusinessCardID, originalID: BusinessCardID? = nil, frontImage: BusinessCard.Image? = nil, backImage: BusinessCard.Image? = nil, textureImage: BusinessCard.Image? = nil, position: BusinessCard.Position, name: BusinessCard.Name, contact: BusinessCard.Contact, address: BusinessCard.Address) {
        self.id = id
        self.originalID = originalID
        self.frontImage = frontImage
        self.backImage = backImage
        self.textureImage = textureImage
        self.position = position
        self.name = name
        self.contact = contact
        self.address = address
    }
}

extension BusinessCard: Equatable {
    static func == (lhs: BusinessCard, rhs: BusinessCard) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BusinessCard {
    struct Address: Codable {
        var country: String?
        var city: String?
        var postCode: String?
        var street: String?
        
        init(country: String? = nil, city: String? = nil, postCode: String? = nil, street: String? = nil) {
            self.country = country
            self.city = city
            self.postCode = postCode
            self.street = street
        }
    }

    struct Contact: Codable {
        var email: String?
        var phoneNumberPrimary: String?
        var phoneNumberSecondary: String?
        var fax: String?
        var website: String?
        
        init(email: String? = nil, phoneNumberPrimary: String? = nil, phoneNumberSecondary: String? = nil, fax: String? = nil, website: String? = nil) {
            self.email = email
            self.phoneNumberPrimary = phoneNumberPrimary
            self.phoneNumberSecondary = phoneNumberSecondary
            self.fax = fax
            self.website = website
        }
    }
    
    struct Name: Codable {
        var prefix: String?
        var first: String?
        var middle: String?
        var last: String?
        
        init(prefix: String? = nil, first: String? = nil, middle: String? = nil, last: String? = nil) {
            self.prefix = prefix
            self.first = first
            self.middle = middle
            self.last = last
        }
    }
    
    struct Position: Codable {
        var title: String?
        var company: String?
        
        init(title: String? = nil, company: String? = nil) {
            self.title = title
            self.company = company
        }
    }
    
    typealias ImageID = String
    
    struct Image: Codable {
        var id: String
        var url: URL
        
        init(id: String, url: URL) {
            self.id = id
            self.url = url
        }
    }
}
