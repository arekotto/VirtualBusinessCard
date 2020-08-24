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

    // swiftlint:disable all
    func callAsFunction(completion: @escaping (Result<Void, Error>) -> Void) {
        
        // MARK: Data
        
        let userID = Auth.auth().currentUser!.uid
        let personalBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(PersonalBusinessCard.collectionName)
        let receivedBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(ReceivedBusinessCard.collectionName)
        let tagsCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(BusinessCardTag.collectionName)
        
        let imageURLs = [
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Back.png?alt=media&token=6a28dce4-14d4-4d6c-abb4-9577615f447d")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard2Front.jpg?alt=media&token=fbcd38a0-3e25-4391-ad43-e82e38ce91ba")!
        ]
        
        let texturesURLs = [
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsamplePaperNormalMap.jpg?alt=media&token=b9d0adf0-86a4-4912-805b-99212f87b269")!,
            URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FpaperNormalMap2.jpg?alt=media&token=5634474e-1a98-4f98-afc1-2d8fb40f5c12")!
        ]
        
        let specularValues: [Float] = [0.1, 0.5, 1.5]
        
        let companies = ["IBM", "Microsoft", "Sony", "Apple"]
        let tags = ["Important", "Conference in Copenhagen", "Can delete soon"]
        let tagIDs: [BusinessCardTagID] = tags.enumerated().map { idx, tag in
            let docRef = tagsCollectionRef.document()
            docRef.setData(BusinessCardTag(id: docRef.documentID, tagColor: BusinessCardTag.TagColor.allCases.randomElement()!, title: tag, priorityIndex: idx, description: nil).asDocument())
            return docRef.documentID
        }
        let hapticSharpness: [Float] = [0.1, 0.2, 0.4, 0.6, 0.8, 1]
        let cornerRadius: [Float] = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.1, 0.15, 0.2]
        // MARK: Data upload

        Name.samples.enumerated().forEach { idx, person in
            let docRef = personalBCCollectionRef.document()
            let bcData = BusinessCardLocalization(
                id: UUID(),
                frontImage: .init(id: "card1front", url: imageURLs.randomElement()!),
                backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                texture: .init(image: BusinessCardLocalization.Image(id: "test", url: texturesURLs.randomElement()!), specular: specularValues.randomElement()!, normal: specularValues.randomElement()!),
                position: BusinessCardLocalization.Position(title: "Manager", company: "IBM"),
                name: BusinessCardLocalization.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                contact: BusinessCardLocalization.Contact(email: "\(person.lastName.lowercased())@ibm.com", phoneNumberPrimary: "123321123", phoneNumberSecondary: "648265932", website: "www.ibm.com"),
                address: BusinessCardLocalization.Address(country: "Denmark", city: "Copenhagen", postCode: "2100", street: "Tasingegade 33"),
                hapticFeedbackSharpness: hapticSharpness.randomElement()!, cornerRadiusHeightMultiplier: cornerRadius.randomElement()!,
                isDefault: true
            )
            let date = day(from: Date(), offset: idx % 5)
            let personalBC = PersonalBusinessCard(
                id: docRef.documentID,
                creationDate: date,
                mostRecentPush: date,
                mostRecentUpdate: date,
                localizations: [bcData]
            )
            docRef.setData(personalBC.asDocument())
        }
        
        (Name.samples + Name.samples).enumerated().forEach { idx, person in
            let docRef = receivedBCCollectionRef.document()
            let company = companies.safeMod(idx)
            let bcData = BusinessCardLocalization(
                id: UUID(),
                frontImage: .init(id: "card1front", url: imageURLs[idx % imageURLs.count]),
                backImage: .init(id: "fasfds", url: URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsampleCard1Front.png?alt=media&token=d2961910-b886-4775-9322-23ec5ab68d9f")!),
                texture: .init(image: BusinessCardLocalization.Image(id: "test", url: texturesURLs.randomElement()!), specular: specularValues.randomElement()!, normal: specularValues.randomElement()!),
                position: BusinessCardLocalization.Position(title: "Manager", company: company),
                name: BusinessCardLocalization.Name(prefix: nil, first: person.firstName, middle: nil, last: person.lastName),
                contact: BusinessCardLocalization.Contact(email: "\(person.lastName.lowercased())@\(company.lowercased()).com", phoneNumberPrimary: "123321123", phoneNumberSecondary: "648265932", website: "www.\(company.lowercased()).com"),
                address: BusinessCardLocalization.Address(country: "Denmark", city: "Copenhagen", postCode: "2100", street: "Tasingegade 33"),
                hapticFeedbackSharpness: hapticSharpness.randomElement()!, cornerRadiusHeightMultiplier: cornerRadius.randomElement()!,
                isDefault: true
            )
            
            let cardTagIDs: [BusinessCardTagID]
            switch idx % 3 {
            case 0: cardTagIDs = [tagIDs[idx % tagIDs.count], tagIDs[(idx + 1) % tagIDs.count]]
            case 1: cardTagIDs = [tagIDs[idx % tagIDs.count]]
            default: cardTagIDs = []
            }
            
            let personalBC = ReceivedBusinessCard(id: docRef.documentID, exchangeID: nil, originalID: "some old ID", ownerID: "Test User", receivingDate: day(from: Date(), offset: idx % 5), mostRecentUpdateDate: Date(), languageVersions: [bcData], tagIDs: cardTagIDs)
            docRef.setData(personalBC.asDocument())
        }
    }

    // swiftlint:enable all
    
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

extension SampleBCUploadTask {

    var names: [String] {
        return [
            "Menachem Regan",
            "Regan Sosa",
            "Xander Sheehan",
            "Moses Dean",
            "Gregory Rahman",
            "Rosalind Avalos",
            "Taiba Chandler",
            "Levison Martinez",
            "Kurt Lawson",
            "Henna Werner",
            "Martha Gross",
            "Ruari Tang",
            "Eshan Price",
            "Cheyanne Hogg",
            "Milan Baird",
            "Aarav Cameron",
            "Callen Robertson",
            "Shaunna Albert",
            "Portia Daniels",
            "Shivam Finch",
            "Theodora Witt",
            "Kaine Metcalfe",
            "Fatema Lees",
            "Percy Franks",
            "Kofi Burgess",
            "Reggie Santos",
            "Suzanne Beattie",
            "Afsana Stott",
            "Huw Osborn",
            "Ayla Derrick",
            "Eloisa Major",
            "Kwame Conroy",
            "Laurel Burt",
            "Arlene Whitehouse",
            "Byron Byers",
            "Szymon Benton",
            "Maliha Holder",
            "Jaimee Mcdonald",
            "Gabrielle Edmonds",
            "Tj Austin",
            "Cleo Schwartz",
            "Shiv Maguire",
            "Minnie Charles",
            "Brennan Cuevas",
            "Cruz Prosser",
            "Harvir Roach",
            "Vishal Hanson",
            "Angelo Chaney",
            "George Mckenzie",
            "Jean-Luc Esparza",
            "Seren Stark",
            "Ayda Harris",
            "Jarrod King",
            "Lara Enriquez",
            "Landon Merritt",
            "Giovanni Cassidy",
            "Nannie Hart",
            "Frazer Goodwin",
            "Lianne Warner",
            "Mary Howe",
            "Mared Farrow",
            "Nayan Morton",
            "Tahir Buchanan",
            "Donte Coombes",
            "Erika Branch",
            "Ruby-May Mullen",
            "Shona Rush",
            "Chyna Wallace",
            "Tabatha Saunders",
            "Aysha Mendoza",
            "Alexandra Juarez",
            "Rhona North",
            "Jethro Mackay",
            "Fenton Burns",
            "Chardonnay Mora",
            "Orlando Grey",
            "Sameer Gay",
            "Henley Stephens",
            "Amanpreet Olson",
            "Ruby Cantrell",
            "Braxton Rios",
            "Courteney Flowers",
            "Saqlain Melia",
            "Arooj Mata",
            "Zayne Berger",
            "Raheel Downs",
            "Jill Kinney",
            "Junaid Alfaro",
            "Allison Vickers",
            "Poppie Hudson",
            "Zakariya Mcgregor",
            "Kerys Christensen",
            "Lillia Johnson",
            "Stan Wilkes",
            "Shea Sutton",
            "Montana Horne",
            "Charley Finnegan",
            "Kadie Roth",
            "Saniya Hogan",
            "Harper Collins",
        ]
    }

    var companies: [String] {
        return [
            "NGL Energy Partners",
            "Calpine",
            "Nucor",
            "eBay",
            "General Mills",
            "Realogy Holdings",
            "Caterpillar",
            "SpartanNash",
            "S&P Global",
            "Auto-Owners Insurance",
            "Guardian Life Ins. Co. of America",
            "Delta Air Lines",
            "Lowe's",
            "Prudential Financial",
            "HollyFrontier",
            "Leidos Holdings",
            "Cummins",
            "L Brands",
            "Caesars Entertainment",
            "Applied Materials",
            "Exxon Mobil",
            "Ameren",
            "Advance Auto Parts",
            "Procter & Gamble",
            "Alcoa",
            "HCA Healthcare",
            "Veritiv",
            "CSX",
            "Goldman Sachs Group",
            "Coty",
            "Home Depot",
            "Chemours",
            "Icahn Enterprises",
            "Hewlett Packard Enterprise",
            "Autoliv",
            "Eversource Energy",
            "Liberty Media",
            "Eli Lilly",
            "M&T Bank Corp.",
            "Walt Disney",
            "Ecolab",
            "Builders FirstSource",
            "Ryder System",
            "Lear",
            "ADP",
            "Harris",
            "Jones Lang LaSalle",
            "Freddie Mac",
            "American Axle & Manufacturing",
            "Bank of America",
            "Huntsman",
            "Westlake Chemical",
            "Kellogg",
            "Coca-Cola",
            "NRG Energy",
            "Chevron",
            "Voya Financial",
            "Northern Trust",
            "Henry Schein",
            "Analog Devices"
        ]
    }
}

