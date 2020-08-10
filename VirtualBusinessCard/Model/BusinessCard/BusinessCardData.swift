//
//  BusinessCardData.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias BusinessCardID = String

struct BusinessCardData: DocumentRepresentable {

    var id: UUID

    var frontImage: Image
    var backImage: Image
    var texture: Texture
    
    var position: Position
    var name: Name
    var contact: Contact
    var address: Address

    var hapticFeedbackSharpness: Float
    var cornerRadiusHeightMultiplier: Float

    var isDefault: Bool
    var languageCode: String?
}

extension BusinessCardData {
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
    
    struct Texture: Codable {
        var image: Image
        var specular: Float
        var normal: Float
        
        init(image: BusinessCardData.Image, specular: Float, normal: Float) {
            self.image = image
            self.specular = specular
            self.normal = normal
        }
    }
}
