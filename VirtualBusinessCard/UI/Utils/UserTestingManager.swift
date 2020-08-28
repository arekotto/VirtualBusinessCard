//
//  UserTestingManager.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

// swiftlint:disable all

struct UserTestingManager {

    static private var userID: String { Auth.auth().currentUser!.uid }
    static let personalBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(PersonalBusinessCard.collectionName)
    static let receivedBCCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(ReceivedBusinessCard.collectionName)
    static let tagsCollectionRef = Firestore.firestore().collection(UserPublic.collectionName).document(userID).collection(BusinessCardTag.collectionName)

    static let hapticSharpness: [Float] = [0.1, 0.2, 0.4, 0.6, 0.8, 1]
    static let cornerRadius: [Float] = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.1, 0.15, 0.2]
    static let specularValues: [Float] = [0.3, 0.5, 1.5]
    static let numbers = Array(0...9).map { "\($0)" }
    static let texturesURLs = [
        URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FsamplePaperNormalMap.jpg?alt=media&token=b9d0adf0-86a4-4912-805b-99212f87b269")!,
        URL(string: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/sampleImages%2FpaperNormalMap2.jpg?alt=media&token=5634474e-1a98-4f98-afc1-2d8fb40f5c12")!
    ]

    static func saveLocalization(_ transaction: Transaction, name: String, company: String, front: String, tagID: String? = nil, exchangeID: String? = nil) {
        let firstName = String(name.split(separator: " ")[0])
        let lastName = String(name.split(separator: " ")[1])
        let loc = BusinessCardLocalization(
            id: UUID(),
            frontImage: .init(id: "", url: URL(string: front)!),
            backImage: .init(id: "", url: URL(string: front)!),
            texture: .init(image: BusinessCardLocalization.Image(id: "test", url: texturesURLs.randomElement()!), specular: specularValues.randomElement()!, normal: specularValues.randomElement()!),
            position: BusinessCardLocalization.Position(title: "Partner", company: company),
            name: BusinessCardLocalization.Name(prefix: nil, first: firstName, middle: nil, last: lastName),
            contact: BusinessCardLocalization.Contact(email: "partner@cmail.com", phoneNumberPrimary: "+45 34 54 34 54", website: "www.website.com"),
            address: BusinessCardLocalization.Address(country: "Denmark", city: "Copenhagen", postCode: "2100", street: "Tasingegade 33"),
            hapticFeedbackSharpness: hapticSharpness.randomElement()!, cornerRadiusHeightMultiplier: cornerRadius.randomElement()!,
            isDefault: true
        )
        let docRef = receivedBCCollectionRef.document()
        let card = ReceivedBusinessCard(
            id: docRef.documentID,
            exchangeID: exchangeID,
            originalID: "",
            ownerID: "",
            receivingDate: generateRandomDate(daysBack: 500) ?? Date(),
            version: 0,
            localizations: [loc],
            tagIDs: tagID != nil ? [tagID!] : []
        )
        transaction.setData(card.asDocument(), forDocument: docRef)
    }

    @discardableResult
    static func saveTag(title: String, priority: Int, color: BusinessCardTag.TagColor) -> String {
        let docRef = tagsCollectionRef.document()
        let tag = BusinessCardTag(id: docRef.documentID, tagColor: color, title: title, priorityIndex: priority, description: nil)
        docRef.setData(tag.asDocument())
        return docRef.documentID
    }

    static func deleteAllDocs(in collection: CollectionReference, completion: (() -> Void)? = nil) {
        var listener: ListenerRegistration?
        listener = collection.addSnapshotListener { querySnapshot, error in
            if let err = error {
                print("couldn't fetch", err.localizedDescription)
            } else {
                collection.firestore.runTransaction { transaction, _ -> Any? in
                    querySnapshot?.documents.forEach {
                        transaction.deleteDocument(collection.document($0.documentID))
                    }
                    return nil
                } completion: { _, _ in
                    completion?()
                }
                listener?.remove()
            }
        }
    }

    static private func generateRandomDate(daysBack: Int)-> Date?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)

        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = -1 * Int(day - 1)
        offsetComponents.hour = -1 * Int(hour)
        offsetComponents.minute = -1 * Int(minute)

        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate
    }

    static func task1() {
        deleteAllDocs(in: tagsCollectionRef)
        deleteAllDocs(in: receivedBCCollectionRef)
        deleteAllDocs(in: personalBCCollectionRef)
        saveTag(title: "Important", priority: 0, color: .red)
    }

    static func task3() {
        deleteAllDocs(in: tagsCollectionRef) {
            saveTag(title: "Important", priority: 0, color: .red)
        }
        deleteAllDocs(in: receivedBCCollectionRef)
    }

    static func task4() {
        deleteAllDocs(in: tagsCollectionRef) {
            saveTag(title: "Important", priority: 0, color: .red)
        }
        deleteAllDocs(in: receivedBCCollectionRef) {
            receivedBCCollectionRef.firestore.runTransaction { transaction, _ -> Any? in
                createUnorganizedCollection(transaction, updates: true)
                return nil
            } completion: { _, _ in }
        }
    }

    static func task51() {
        deleteAllDocs(in: tagsCollectionRef) {
            saveTag(title: "Important", priority: 0, color: .red)
        }
        deleteAllDocs(in: receivedBCCollectionRef) {
            receivedBCCollectionRef.firestore.runTransaction { transaction, _ -> Any? in
                createUnorganizedCollection(transaction, updates: false)
                return nil
            } completion: { _, _ in }
        }
    }

    static func task52() {
        deleteAllDocs(in: tagsCollectionRef) {

            let tag1 = saveTag(title: "Important", priority: 0, color: .red)
            let tag2 = saveTag(title: "Conference in Copenhagen", priority: 1, color: .blue)
            let tag3 = saveTag(title: "Conference in London", priority: 2, color: .gray)
            let tag4 = saveTag(title: "Conference in Berlin", priority: 3, color: .green)
            let tag5 = saveTag(title: "Potential Suppliers", priority: 4, color: .indigo)
            let tag6 = saveTag(title: "Unimportant", priority: 5, color: .purple)

            deleteAllDocs(in: receivedBCCollectionRef) {
                receivedBCCollectionRef.firestore.runTransaction { transaction, _ -> Any? in
                    createOrganizedCollection(transaction, tagIDs: [tag1, tag2, tag3, tag4, tag5, tag6])
                    return nil
                } completion: { _, _ in }
            }
        }
    }

    static func task6() {
        deleteAllDocs(in: tagsCollectionRef)
        deleteAllDocs(in: receivedBCCollectionRef)
        saveTag(title: "Important", priority: 0, color: .red)
    }

    static func createUnorganizedCollection(_ transaction: Transaction, updates: Bool) {
        saveLocalization(transaction, name: "Menachem Regan", company: "NGL Energy Partners", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMenachem%20Regan.jpg?alt=media&token=e9ebe96f-dd07-4588-809e-3a85b710c680")
        saveLocalization(transaction, name: "Regan Sosa", company: "Exxon Mobil", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRegan%20Sosa.jpg?alt=media&token=bed8fd6e-2dee-432a-a5cc-b486131de706")
        saveLocalization(transaction, name: "Xander Sheehan", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FXander%20Sheehan.jpg?alt=media&token=f49e284c-a64d-45c8-bc0a-5ecab638cb95")
        saveLocalization(transaction, name: "Moses Dean", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMoses%20Dean.jpg?alt=media&token=ae03e0b5-1005-4db7-9c8c-59b5a55c55e7")
        saveLocalization(transaction, name: "Gregory Rahman", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGregory%20Rahman.jpg?alt=media&token=79cc96f7-d9a1-4d43-8920-443f9ce35c24")
        saveLocalization(transaction, name: "Rosalind Avalos", company: "Goldman Sachs Group", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRosalind%20Avalos.jpg?alt=media&token=24bc2dc6-548d-4910-8bad-07325393a78d")
        saveLocalization(transaction, name: "Taiba Chandler", company: "Exxon Mobil", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTaiba%20Chandler.jpg?alt=media&token=5eb964a8-5f40-4328-b7c9-9668a2946d36")
        saveLocalization(transaction, name: "Levison Martinez", company: "Goldman Sachs Group", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FLevison%20Martinez.jpg?alt=media&token=242ffc41-b611-45cb-9646-517aa78f747b")
        saveLocalization(transaction, name: "Kurt Lawson", company: "eBay", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKurt%20Lawson.jpg?alt=media&token=fc08d944-4ed7-4102-afe6-47b8e26d6814")
        saveLocalization(transaction, name: "Henna Werner", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHenna%20Werner.jpg?alt=media&token=b7a0d60d-c7f7-4597-9d37-ddfb8420a81e")
        saveLocalization(transaction, name: "Martha Gross", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMartha%20Gross.jpg?alt=media&token=9a8bfd40-e4f7-489a-8b86-9edf6cca8444")
        saveLocalization(transaction, name: "Ruari Tang", company: "Procter & Gamble", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRuari%20Tang.jpg?alt=media&token=3e66e85b-af15-435f-8aad-7038d5900c12")
        saveLocalization(transaction, name: "Eshan Price", company: "Coty", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FEshan%20Price.jpg?alt=media&token=51fc2507-55b0-4df1-ac3e-74b8688fc02d")
        saveLocalization(transaction, name: "Cheyanne Hogg", company: "Freddie Mac", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCheyanne%20Hogg.jpg?alt=media&token=d8f28bd3-3d8b-4614-9718-b0653803a4ff")
        saveLocalization(transaction, name: "Milan Baird", company: "American Axle & Manufacturing", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMilan%20Baird.jpg?alt=media&token=da49cd23-ad6f-4cc8-a735-cd5b7ded4801")
        saveLocalization(transaction, name: "Aarav Cameron", company: "Calpine", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAarav%20Cameron.jpg?alt=media&token=5a8108fc-0a78-4f47-8873-1fc892781641")
        saveLocalization(transaction, name: "Callen Robertson", company: "Bank of America", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCallen%20Robertson.jpg?alt=media&token=205d95d8-f8b0-4c74-8945-359567f21749")
        saveLocalization(transaction, name: "Shaunna Albert", company: "Huntsman", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShaunna%20Albert.jpg?alt=media&token=8f054849-ece0-4409-a333-7e13ef6fa9f0")
        saveLocalization(transaction, name: "Portia Daniels", company: "Westlake Chemical", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FPortia%20Daniels.jpg?alt=media&token=c056ed23-1f27-4830-a040-ff57b6741c7a")
        saveLocalization(transaction, name: "Shivam Finch", company: "Kellogg", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShivam%20Finch.jpg?alt=media&token=c598072f-b9e1-4180-a642-f44a817a8c54")
        saveLocalization(transaction, name: "Theodora Witt", company: "Coca-Cola", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTheodora%20Witt.jpg?alt=media&token=fd09acd6-bc3f-4b0c-a6f5-fec03c6dcf40")
        saveLocalization(transaction, name: "Kaine Metcalfe", company: "NRG Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKaine%20Metcalfe.jpg?alt=media&token=cfb5b759-2319-4d6a-92cf-55b58016de86")
        saveLocalization(transaction, name: "Fatema Lees", company: "NGL Energy Partners", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FFatema%20Lees.jpg?alt=media&token=4deeba34-7ddb-441f-a41e-7f585727cadb")
        saveLocalization(transaction, name: "Percy Franks", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FPercy%20Franks.jpg?alt=media&token=b30a8307-cb2b-462e-b4b5-967bab7cf323")
        saveLocalization(transaction, name: "Kofi Burgess", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKofi%20Burgess.jpg?alt=media&token=e8cd71ab-584b-42a7-98b3-1208262abe4e")
        saveLocalization(transaction, name: "Reggie Santos", company: "ADP", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FReggie%20Santos.jpg?alt=media&token=685e6d7c-9242-404e-99ca-8ba0a746152c")
        saveLocalization(transaction, name: "Suzanne Beattie", company: "General Mills", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSuzanne%20Beattie.jpg?alt=media&token=2e1deba1-2124-490a-94a6-4c77d8c1d889")
        saveLocalization(transaction, name: "Afsana Stott", company: "Harris", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAfsana%20Stott.jpg?alt=media&token=436c6e13-95e5-4694-8179-ddb2994b4acb")
        saveLocalization(transaction, name: "Huw Osborn", company: "General Mills", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHuw%20Osborn.jpg?alt=media&token=bee46f15-48cd-40a2-abac-a0fce44fb5f2")
        saveLocalization(transaction, name: "Ayla Derrick", company: "SpartanNash", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAyla%20Derrick.jpg?alt=media&token=a6702337-99ab-484f-8024-14d9ee732268")
        saveLocalization(transaction, name: "Eloisa Major", company: "Procter & Gamble", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FEloisa%20Major.jpg?alt=media&token=767c4307-6b4e-49f6-a89a-de8482f7fc50")
        saveLocalization(transaction, name: "Kwame Conroy", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKwame%20Conroy.jpg?alt=media&token=4506ed98-c40f-498f-921c-805aecc3c2b5")
        saveLocalization(transaction, name: "Laurel Burt", company: "SpartanNash", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FLaurel%20Burt.jpg?alt=media&token=695319a9-43e2-4c19-9ca0-68c15864f480")
        saveLocalization(transaction, name: "Arlene Whitehouse", company: "Jones Lang LaSalle", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FArlene%20Whitehouse.jpg?alt=media&token=0d98cfb6-bb68-412a-91ee-b2a698745852")
        saveLocalization(transaction, name: "Byron Byers", company: "Nucor", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FByron%20Byers.jpg?alt=media&token=2ccde132-bc3e-4f7b-a711-e40b6d1a6b84")
        saveLocalization(transaction, name: "Szymon Benton", company: "Lear", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSzymon%20Benton.jpg?alt=media&token=b76b63a1-087d-4e1b-9c37-dab13c831dfc")
        saveLocalization(transaction, name: "Maliha Holder", company: "Nucor", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMaliha%20Holder.jpg?alt=media&token=05eaf244-8c35-41b7-b2b0-c2fddd947dfe")
        saveLocalization(transaction, name: "Jaimee Mcdonald", company: "S&P Global", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJaimee%20Mcdonald.jpg?alt=media&token=4730fb77-2e6d-44cf-8dad-1f0772fcbc86")
        saveLocalization(transaction, name: "Gabrielle Edmonds", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGabrielle%20Edmonds.jpg?alt=media&token=f9992511-4b6b-4038-8090-b5b318ad7d34")
        saveLocalization(transaction, name: "Tj Austin", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTj%20Austin.jpg?alt=media&token=527ffd12-5e1d-4d61-9897-633cbe7c3764")
        saveLocalization(transaction, name: "Cleo Schwartz", company: "Caterpillar", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCleo%20Schwartz.jpg?alt=media&token=94b512dc-b560-4ad4-bb5b-c44fd20b4141")
        saveLocalization(transaction, name: "Shiv Maguire", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShiv%20Maguire.jpg?alt=media&token=a9728984-f444-430b-987d-1cb2d6819db6")
        saveLocalization(transaction, name: "Minnie Charles", company: "Calpine", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMinnie%20Charles.jpg?alt=media&token=175fe2a3-f091-4d7f-b4f0-747345d95860")
        saveLocalization(transaction, name: "Brennan Cuevas", company: "Ryder System", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FBrennan%20Cuevas.jpg?alt=media&token=61ff241a-592b-498d-9f40-533b358c5f13")
        saveLocalization(transaction, name: "Cruz Prosser", company: "Applied Materials", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCruz%20Prosser.jpg?alt=media&token=8941e6c9-14b3-4bbf-8d1a-7480b5360cd6")
        saveLocalization(transaction, name: "Harvir Roach", company: "Builders FirstSource", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHarvir%20Roach.jpg?alt=media&token=638e1e83-48a2-48e1-9f4b-0f0d6982567c")
        saveLocalization(transaction, name: "Vishal Hanson", company: "Auto-Owners Insurance", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FVishal%20Hanson.jpg?alt=media&token=f020f27d-8a76-4e59-a0c9-237f9f84e6f6")
        saveLocalization(transaction, name: "Angelo Chaney", company: "Auto-Owners Insurance", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAngelo%20Chaney.jpg?alt=media&token=856b3bc6-7948-4453-a25e-ace5e1a6a74f")
        saveLocalization(transaction, name: "George Mckenzie", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGeorge%20Mckenzie.jpg?alt=media&token=1ffceef7-aea5-4c37-b8ba-1b6e741f3b10")
        saveLocalization(transaction, name: "Jean-Luc Esparza", company: "Builders FirstSource", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJean-Luc%20Esparza.jpg?alt=media&token=cfe9ba69-51f8-4624-9e21-b5b31b0161ee")
        saveLocalization(transaction, name: "Seren Stark", company: "Applied Materials", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSeren%20Stark.jpg?alt=media&token=e06f8729-503c-4430-9c4e-a941dc9dd640")
        saveLocalization(transaction, name: "Ayda Harris", company: "Coty", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAyda%20Harris.jpg?alt=media&token=46c1b94a-187e-4ec7-a4b0-1a821753d323")
        saveLocalization(transaction, name: "Jarrod King", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJarrod%20King.jpg?alt=media&token=0905720f-631b-46f9-918a-29e211f3ffc1")

        // task 4
        saveLocalization(transaction, name: "Lara Enriquez", company: "International Wearables", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLara%20Enriquez.jpg?alt=media&token=4a27ff91-b08b-42d8-8922-dbc7cd4b7643", exchangeID: updates ? "7aHQ1EdNDQaa8qnLhHY5" : nil)
        saveLocalization(transaction, name: "Landon Merritt", company: "International Wearables", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLandon%20Merritt.jpg?alt=media&token=e2b6bd88-8391-4873-83c1-b4ae4a00d3d3", exchangeID: updates ? "RRRy9xEJssngdz3hAmOb" : nil)

        // task 5
        saveLocalization(transaction, name: "Giovanni Cassidy", company: "Liberty Media", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FGiovanni%20Cassidy.jpg?alt=media&token=4081ce2f-e39f-4d7c-94b1-5534dd135bb0")
        saveLocalization(transaction, name: "Nannie Hart", company: "Ecolab", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FNannie%20Hart.jpg?alt=media&token=aeded4ff-af51-4bf3-b697-bd9d5c7f095c")
        saveLocalization(transaction, name: "Frazer Goodwin", company: "Advance Auto Parts", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FFrazer%20Goodwin.jpg?alt=media&token=692cfc3d-749d-4bf4-a2ce-d1c9fd099180")

        // task 5.5
        saveLocalization(transaction, name: "Lianne Warner", company: "Alcoa", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLianne%20Warner.jpg?alt=media&token=97be6624-19d1-4190-bd28-ef9b6f70be95")
        saveLocalization(transaction, name: "Mary Howe", company: "Veritiv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMary%20Howe.jpg?alt=media&token=52e5ec0d-77ed-444b-989c-7f17284fbf08")
        saveLocalization(transaction, name: "Mared Farrow", company: "CSX", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMared%20Farrow.jpg?alt=media&token=6b2f4b46-d4b3-488a-881d-c0b71ef29050")


        saveLocalization(transaction, name: "Nayan Morton", company: "Prudential Financial", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FNayan%20Morton.jpg?alt=media&token=44b055ae-3f17-4b0d-bd3a-9021e53f0a7e")
        saveLocalization(transaction, name: "Tahir Buchanan", company: "HollyFrontier", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FTahir%20Buchanan.jpg?alt=media&token=77aaa3c6-91a4-49b3-97bf-41a3f48fb27e")
        saveLocalization(transaction, name: "Donte Coombes", company: "HollyFrontier", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FDonte%20Coombes.jpg?alt=media&token=f76dff6d-df8e-4dec-8b35-120ad8474ab6")
        saveLocalization(transaction, name: "Erika Branch", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FErika%20Branch.jpg?alt=media&token=588aa7e4-7742-4a81-be96-0da55b8260f2")
        saveLocalization(transaction, name: "Ruby-May Mullen", company: "Caterpillar", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRuby-May%20Mullen.jpg?alt=media&token=1f2577d4-0c85-4830-8cee-7a981fe4e40b")
        saveLocalization(transaction, name: "Shona Rush", company: "Lowe's", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FShona%20Rush.jpg?alt=media&token=e6ae0580-4a57-4d7b-9bd3-3f7cf9f9b2fb")
        saveLocalization(transaction, name: "Chyna Wallace", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FChyna%20Wallace.jpg?alt=media&token=3b60eb3a-c613-49f3-ba81-43b52a025363")
        saveLocalization(transaction, name: "Tabatha Saunders", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FTabatha%20Saunders.jpg?alt=media&token=2c12738e-e041-4f12-b56b-9ad846601d37")
        saveLocalization(transaction, name: "Aysha Mendoza", company: "Lowe's", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAysha%20Mendoza.jpg?alt=media&token=2bf6bda3-5a6c-4bff-8a78-59013810cbea")
        saveLocalization(transaction, name: "Alexandra Juarez", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAlexandra%20Juarez.jpg?alt=media&token=f77af1c2-3db4-4d20-bbc6-bd118bd71db1")
        saveLocalization(transaction, name: "Rhona North", company: "Home Depot", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRhona%20North.jpg?alt=media&token=8f7e24bd-3ca9-40b0-b144-70a9f9fa5f11")
        saveLocalization(transaction, name: "Jethro Mackay", company: "Guardian Life Ins. Co. of America", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FJethro%20Mackay.jpg?alt=media&token=6ae6d993-8f21-4bd7-8731-901537098a4a")
        saveLocalization(transaction, name: "Fenton Burns", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FFenton%20Burns.jpg?alt=media&token=6fc50f06-832f-40eb-8543-d2947e083db4")
        saveLocalization(transaction, name: "Chardonnay Mora", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FChardonnay%20Mora.jpg?alt=media&token=80006393-ba2c-4ec1-8f65-22529b37ed1a")
        saveLocalization(transaction, name: "Orlando Grey", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FOrlando%20Grey.jpg?alt=media&token=61501977-f7c0-424d-a021-f4e4fccc112c")
        saveLocalization(transaction, name: "Sameer Gay", company: "Caesars Entertainment", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSameer%20Gay.jpg?alt=media&token=b3c58322-82b4-4cc0-833e-05a9784d1891")
        saveLocalization(transaction, name: "Henley Stephens", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FHenley%20Stephens.jpg?alt=media&token=87705a51-6c6b-446e-a280-24df2cc6f538")
        saveLocalization(transaction, name: "Amanpreet Olson", company: "Chemours", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAmanpreet%20Olson.jpg?alt=media&token=7abe0900-1a69-42ce-953d-e2ffd32e3e36")
        saveLocalization(transaction, name: "Ruby Cantrell", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRuby%20Cantrell.jpg?alt=media&token=f70eda1e-9a2f-41f2-8647-bba1d8ee3dfb")
        saveLocalization(transaction, name: "Braxton Rios", company: "Chemours", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FBraxton%20Rios.jpg?alt=media&token=f97379aa-3734-4db7-944f-b38d50dad920")
        saveLocalization(transaction, name: "Courteney Flowers", company: "Eli Lilly", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FCourteney%20Flowers.jpg?alt=media&token=d7ebd355-f487-4e0b-b923-331a646ea5ac")
        saveLocalization(transaction, name: "Saqlain Melia", company: "M&T Bank Corp.", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSaqlain%20Melia.jpg?alt=media&token=a88b2075-6e3b-4779-9810-6ea8ad6df22a")
        saveLocalization(transaction, name: "Arooj Mata", company: "M&T Bank Corp.", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FArooj%20Mata.jpg?alt=media&token=46908e1d-27b9-4ce1-9b9f-61eb8a178a99")
        saveLocalization(transaction, name: "Zayne Berger", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FZayne%20Berger.jpg?alt=media&token=42612d29-10b0-47a5-8f9a-030b29d441a5")
        saveLocalization(transaction, name: "Raheel Downs", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FRaheel%20Downs.jpg?alt=media&token=e99427d7-6f99-4f72-bcbb-70910f97c9c3")
        saveLocalization(transaction, name: "Jill Kinney", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FJill%20Kinney.jpg?alt=media&token=0e124cbc-7f55-40fe-9120-331ed9b310e0")
        saveLocalization(transaction, name: "Junaid Alfaro", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FJunaid%20Alfaro.jpg?alt=media&token=e16b9abc-a37b-4f51-a442-d7bda5ae9016")
        saveLocalization(transaction, name: "Allison Vickers", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FAllison%20Vickers.jpg?alt=media&token=bc2465c2-5a08-49ca-a2ed-2c2bb42fbf9c")
        saveLocalization(transaction, name: "Poppie Hudson", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FPoppie%20Hudson.jpg?alt=media&token=093d464f-5922-46ba-a4f3-c1586b2c3d20")
        saveLocalization(transaction, name: "Zakariya Mcgregor", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FZakariya%20Mcgregor.jpg?alt=media&token=ecdf4396-fc79-4909-b8aa-d8d963d45beb")
        saveLocalization(transaction, name: "Kerys Christensen", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FKerys%20Christensen.jpg?alt=media&token=82a92adc-3c7d-4300-932c-271938e01e76")
        saveLocalization(transaction, name: "Lillia Johnson", company: "Autoliv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLillia%20Johnson.jpg?alt=media&token=8217c2b9-d8ec-4221-820a-b0f9d2ebe12b")
        saveLocalization(transaction, name: "Stan Wilkes", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FStan%20Wilkes.jpg?alt=media&token=feafe129-a819-4acb-889f-61f7bcae016f")
        saveLocalization(transaction, name: "Shea Sutton", company: "Autoliv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FShea%20Sutton.jpg?alt=media&token=eba33548-b8b9-44ed-8304-c1d1c88dc8c7")
        saveLocalization(transaction, name: "Montana Horne", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMontana%20Horne.jpg?alt=media&token=e3ef95e3-65ed-4e19-840c-6932d3803402")
        saveLocalization(transaction, name: "Charley Finnegan", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FCharley%20Finnegan.jpg?alt=media&token=51634a91-7212-479b-a6f3-7f7220ead1aa")
        saveLocalization(transaction, name: "Kadie Roth", company: "Home Depot", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FKadie%20Roth.jpg?alt=media&token=e9bd5395-440a-4bc3-ac33-be9c96ef1234")
        saveLocalization(transaction, name: "Saniya Hogan", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSaniya%20Hogan.jpg?alt=media&token=f5fa44bf-1a5d-4c42-93b8-28303cb9a1e3")
        saveLocalization(transaction, name: "Harper Collins", company: "Eli Lilly", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FHarper%20Collins.jpg?alt=media&token=77308089-739a-419d-bd60-0437667c93ce")
    }

    static func createOrganizedCollection(_ transaction: Transaction, tagIDs: [String]) {
        let tag1 = tagIDs[0]
        let tag2 = tagIDs[1]
        let tag3 = tagIDs[2]
        let tag4 = tagIDs[3]
        let tag5 = tagIDs[4]
        let tag6 = tagIDs[5]
        saveLocalization(transaction, name: "Menachem Regan", company: "NGL Energy Partners", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMenachem%20Regan.jpg?alt=media&token=c951eabe-dad5-4a58-9bb4-b114c2042f5f", tagID: tag1)
        saveLocalization(transaction, name: "Regan Sosa", company: "Exxon Mobil", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRegan%20Sosa.jpg?alt=media&token=bed8fd6e-2dee-432a-a5cc-b486131de706", tagID: tag1)
        saveLocalization(transaction, name: "Xander Sheehan", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FXander%20Sheehan.jpg?alt=media&token=f49e284c-a64d-45c8-bc0a-5ecab638cb95", tagID: tag1)
        saveLocalization(transaction, name: "Moses Dean", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMoses%20Dean.jpg?alt=media&token=ae03e0b5-1005-4db7-9c8c-59b5a55c55e7", tagID: tag1)
        saveLocalization(transaction, name: "Gregory Rahman", company: "Ameren", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGregory%20Rahman.jpg?alt=media&token=79cc96f7-d9a1-4d43-8920-443f9ce35c24", tagID: tag1)
        saveLocalization(transaction, name: "Rosalind Avalos", company: "Goldman Sachs Group", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRosalind%20Avalos.jpg?alt=media&token=24bc2dc6-548d-4910-8bad-07325393a78d", tagID: tag1)
        saveLocalization(transaction, name: "Taiba Chandler", company: "Exxon Mobil", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTaiba%20Chandler.jpg?alt=media&token=5eb964a8-5f40-4328-b7c9-9668a2946d36", tagID: tag1)
        saveLocalization(transaction, name: "Levison Martinez", company: "Goldman Sachs Group", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FLevison%20Martinez.jpg?alt=media&token=242ffc41-b611-45cb-9646-517aa78f747b", tagID: tag1)
        saveLocalization(transaction, name: "Kurt Lawson", company: "eBay", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKurt%20Lawson.jpg?alt=media&token=fc08d944-4ed7-4102-afe6-47b8e26d6814", tagID: tag2)
        saveLocalization(transaction, name: "Henna Werner", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHenna%20Werner.jpg?alt=media&token=b7a0d60d-c7f7-4597-9d37-ddfb8420a81e", tagID: tag2)
        saveLocalization(transaction, name: "Martha Gross", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMartha%20Gross.jpg?alt=media&token=9a8bfd40-e4f7-489a-8b86-9edf6cca8444", tagID: tag2)
        saveLocalization(transaction, name: "Ruari Tang", company: "Procter & Gamble", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FRuari%20Tang.jpg?alt=media&token=3e66e85b-af15-435f-8aad-7038d5900c12", tagID: tag2)
        saveLocalization(transaction, name: "Eshan Price", company: "Coty", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FEshan%20Price.jpg?alt=media&token=51fc2507-55b0-4df1-ac3e-74b8688fc02d", tagID: tag2)
        saveLocalization(transaction, name: "Cheyanne Hogg", company: "Freddie Mac", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCheyanne%20Hogg.jpg?alt=media&token=d8f28bd3-3d8b-4614-9718-b0653803a4ff", tagID: tag2)
        saveLocalization(transaction, name: "Milan Baird", company: "American Axle & Manufacturing", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMilan%20Baird.jpg?alt=media&token=da49cd23-ad6f-4cc8-a735-cd5b7ded4801", tagID: tag2)
        saveLocalization(transaction, name: "Aarav Cameron", company: "Calpine", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAarav%20Cameron.jpg?alt=media&token=5a8108fc-0a78-4f47-8873-1fc892781641", tagID: tag2)
        saveLocalization(transaction, name: "Callen Robertson", company: "Bank of America", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCallen%20Robertson.jpg?alt=media&token=205d95d8-f8b0-4c74-8945-359567f21749", tagID: tag2)
        saveLocalization(transaction, name: "Shaunna Albert", company: "Huntsman", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShaunna%20Albert.jpg?alt=media&token=8f054849-ece0-4409-a333-7e13ef6fa9f0", tagID: tag2)
        saveLocalization(transaction, name: "Portia Daniels", company: "Westlake Chemical", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FPortia%20Daniels.jpg?alt=media&token=c056ed23-1f27-4830-a040-ff57b6741c7a", tagID: tag2)
        saveLocalization(transaction, name: "Shivam Finch", company: "Kellogg", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShivam%20Finch.jpg?alt=media&token=c598072f-b9e1-4180-a642-f44a817a8c54", tagID: tag2)
        saveLocalization(transaction, name: "Theodora Witt", company: "Coca-Cola", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTheodora%20Witt.jpg?alt=media&token=fd09acd6-bc3f-4b0c-a6f5-fec03c6dcf40", tagID: tag2)
        saveLocalization(transaction, name: "Kaine Metcalfe", company: "NRG Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKaine%20Metcalfe.jpg?alt=media&token=cfb5b759-2319-4d6a-92cf-55b58016de86", tagID: tag2)
        saveLocalization(transaction, name: "Fatema Lees", company: "NGL Energy Partners", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FFatema%20Lees.jpg?alt=media&token=4deeba34-7ddb-441f-a41e-7f585727cadb", tagID: tag2)
        saveLocalization(transaction, name: "Percy Franks", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FPercy%20Franks.jpg?alt=media&token=b30a8307-cb2b-462e-b4b5-967bab7cf323", tagID: tag2)
        saveLocalization(transaction, name: "Kofi Burgess", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKofi%20Burgess.jpg?alt=media&token=e8cd71ab-584b-42a7-98b3-1208262abe4e", tagID: tag2)
        saveLocalization(transaction, name: "Reggie Santos", company: "ADP", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FReggie%20Santos.jpg?alt=media&token=685e6d7c-9242-404e-99ca-8ba0a746152c", tagID: tag2)
        saveLocalization(transaction, name: "Suzanne Beattie", company: "General Mills", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSuzanne%20Beattie.jpg?alt=media&token=2e1deba1-2124-490a-94a6-4c77d8c1d889", tagID: tag3)
        saveLocalization(transaction, name: "Afsana Stott", company: "Harris", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAfsana%20Stott.jpg?alt=media&token=436c6e13-95e5-4694-8179-ddb2994b4acb", tagID: tag3)
        saveLocalization(transaction, name: "Huw Osborn", company: "General Mills", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHuw%20Osborn.jpg?alt=media&token=bee46f15-48cd-40a2-abac-a0fce44fb5f2", tagID: tag3)
        saveLocalization(transaction, name: "Ayla Derrick", company: "SpartanNash", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAyla%20Derrick.jpg?alt=media&token=a6702337-99ab-484f-8024-14d9ee732268", tagID: tag3)
        saveLocalization(transaction, name: "Eloisa Major", company: "Procter & Gamble", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FEloisa%20Major.jpg?alt=media&token=767c4307-6b4e-49f6-a89a-de8482f7fc50", tagID: tag3)
        saveLocalization(transaction, name: "Kwame Conroy", company: "Realogy Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FKwame%20Conroy.jpg?alt=media&token=4506ed98-c40f-498f-921c-805aecc3c2b5", tagID: tag3)
        saveLocalization(transaction, name: "Laurel Burt", company: "SpartanNash", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FLaurel%20Burt.jpg?alt=media&token=695319a9-43e2-4c19-9ca0-68c15864f480", tagID: tag3)
        saveLocalization(transaction, name: "Arlene Whitehouse", company: "Jones Lang LaSalle", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FArlene%20Whitehouse.jpg?alt=media&token=0d98cfb6-bb68-412a-91ee-b2a698745852", tagID: tag3)
        saveLocalization(transaction, name: "Byron Byers", company: "Nucor", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FByron%20Byers.jpg?alt=media&token=2ccde132-bc3e-4f7b-a711-e40b6d1a6b84", tagID: tag4)
        saveLocalization(transaction, name: "Szymon Benton", company: "Lear", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSzymon%20Benton.jpg?alt=media&token=b76b63a1-087d-4e1b-9c37-dab13c831dfc", tagID: tag4)
        saveLocalization(transaction, name: "Maliha Holder", company: "Nucor", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMaliha%20Holder.jpg?alt=media&token=05eaf244-8c35-41b7-b2b0-c2fddd947dfe", tagID: tag4)
        saveLocalization(transaction, name: "Jaimee Mcdonald", company: "S&P Global", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJaimee%20Mcdonald.jpg?alt=media&token=4730fb77-2e6d-44cf-8dad-1f0772fcbc86", tagID: tag4)
        saveLocalization(transaction, name: "Gabrielle Edmonds", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGabrielle%20Edmonds.jpg?alt=media&token=f9992511-4b6b-4038-8090-b5b318ad7d34", tagID: tag4)
        saveLocalization(transaction, name: "Tj Austin", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FTj%20Austin.jpg?alt=media&token=527ffd12-5e1d-4d61-9897-633cbe7c3764", tagID: tag4)
        saveLocalization(transaction, name: "Cleo Schwartz", company: "Caterpillar", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCleo%20Schwartz.jpg?alt=media&token=94b512dc-b560-4ad4-bb5b-c44fd20b4141", tagID: tag4)
        saveLocalization(transaction, name: "Shiv Maguire", company: "Walt Disney", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FShiv%20Maguire.jpg?alt=media&token=a9728984-f444-430b-987d-1cb2d6819db6", tagID: tag4)
        saveLocalization(transaction, name: "Minnie Charles", company: "Calpine", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FMinnie%20Charles.jpg?alt=media&token=175fe2a3-f091-4d7f-b4f0-747345d95860", tagID: tag4)
        saveLocalization(transaction, name: "Brennan Cuevas", company: "Ryder System", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FBrennan%20Cuevas.jpg?alt=media&token=61ff241a-592b-498d-9f40-533b358c5f13", tagID: tag4)
        saveLocalization(transaction, name: "Cruz Prosser", company: "Applied Materials", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FCruz%20Prosser.jpg?alt=media&token=8941e6c9-14b3-4bbf-8d1a-7480b5360cd6")
        saveLocalization(transaction, name: "Harvir Roach", company: "Builders FirstSource", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FHarvir%20Roach.jpg?alt=media&token=638e1e83-48a2-48e1-9f4b-0f0d6982567c")
        saveLocalization(transaction, name: "Vishal Hanson", company: "Auto-Owners Insurance", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FVishal%20Hanson.jpg?alt=media&token=f020f27d-8a76-4e59-a0c9-237f9f84e6f6")
        saveLocalization(transaction, name: "Angelo Chaney", company: "Auto-Owners Insurance", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAngelo%20Chaney.jpg?alt=media&token=856b3bc6-7948-4453-a25e-ace5e1a6a74f")
        saveLocalization(transaction, name: "George Mckenzie", company: "HCA Healthcare", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FGeorge%20Mckenzie.jpg?alt=media&token=1ffceef7-aea5-4c37-b8ba-1b6e741f3b10")
        saveLocalization(transaction, name: "Jean-Luc Esparza", company: "Builders FirstSource", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJean-Luc%20Esparza.jpg?alt=media&token=cfe9ba69-51f8-4624-9e21-b5b31b0161ee")
        saveLocalization(transaction, name: "Seren Stark", company: "Applied Materials", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FSeren%20Stark.jpg?alt=media&token=e06f8729-503c-4430-9c4e-a941dc9dd640")
        saveLocalization(transaction, name: "Ayda Harris", company: "Coty", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FAyda%20Harris.jpg?alt=media&token=46c1b94a-187e-4ec7-a4b0-1a821753d323")
        saveLocalization(transaction, name: "Jarrod King", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting%2FJarrod%20King.jpg?alt=media&token=0905720f-631b-46f9-918a-29e211f3ffc1")

        // task 4
        saveLocalization(transaction, name: "Lara Enriquez", company: "International Wearables", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLara%20Enriquez.jpg?alt=media&token=4a27ff91-b08b-42d8-8922-dbc7cd4b7643")
        saveLocalization(transaction, name: "Landon Merritt", company: "International Wearables", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLandon%20Merritt.jpg?alt=media&token=e2b6bd88-8391-4873-83c1-b4ae4a00d3d3")

        // task 5
        saveLocalization(transaction, name: "Giovanni Cassidy", company: "Liberty Media", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FGiovanni%20Cassidy.jpg?alt=media&token=4081ce2f-e39f-4d7c-94b1-5534dd135bb0")
        saveLocalization(transaction, name: "Nannie Hart", company: "Ecolab", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FNannie%20Hart.jpg?alt=media&token=aeded4ff-af51-4bf3-b697-bd9d5c7f095c")
        saveLocalization(transaction, name: "Frazer Goodwin", company: "Advance Auto Parts", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FFrazer%20Goodwin.jpg?alt=media&token=692cfc3d-749d-4bf4-a2ce-d1c9fd099180")

        // task 6
        saveLocalization(transaction, name: "Lianne Warner", company: "Alcoa", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLianne%20Warner.jpg?alt=media&token=97be6624-19d1-4190-bd28-ef9b6f70be95")
        saveLocalization(transaction, name: "Mary Howe", company: "Veritiv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMary%20Howe.jpg?alt=media&token=52e5ec0d-77ed-444b-989c-7f17284fbf08")
        saveLocalization(transaction, name: "Mared Farrow", company: "CSX", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMared%20Farrow.jpg?alt=media&token=6b2f4b46-d4b3-488a-881d-c0b71ef29050")


        saveLocalization(transaction, name: "Nayan Morton", company: "Prudential Financial", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FNayan%20Morton.jpg?alt=media&token=44b055ae-3f17-4b0d-bd3a-9021e53f0a7e", tagID: tag5)
        saveLocalization(transaction, name: "Tahir Buchanan", company: "HollyFrontier", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FTahir%20Buchanan.jpg?alt=media&token=77aaa3c6-91a4-49b3-97bf-41a3f48fb27e", tagID: tag5)
        saveLocalization(transaction, name: "Donte Coombes", company: "HollyFrontier", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FDonte%20Coombes.jpg?alt=media&token=f76dff6d-df8e-4dec-8b35-120ad8474ab6", tagID: tag5)
        saveLocalization(transaction, name: "Erika Branch", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FErika%20Branch.jpg?alt=media&token=588aa7e4-7742-4a81-be96-0da55b8260f2", tagID: tag5)
        saveLocalization(transaction, name: "Ruby-May Mullen", company: "Caterpillar", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRuby-May%20Mullen.jpg?alt=media&token=1f2577d4-0c85-4830-8cee-7a981fe4e40b", tagID: tag5)
        saveLocalization(transaction, name: "Shona Rush", company: "Lowe's", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FShona%20Rush.jpg?alt=media&token=e6ae0580-4a57-4d7b-9bd3-3f7cf9f9b2fb", tagID: tag5)
        saveLocalization(transaction, name: "Chyna Wallace", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FChyna%20Wallace.jpg?alt=media&token=3b60eb3a-c613-49f3-ba81-43b52a025363", tagID: tag5)
        saveLocalization(transaction, name: "Tabatha Saunders", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FTabatha%20Saunders.jpg?alt=media&token=2c12738e-e041-4f12-b56b-9ad846601d37", tagID: tag5)
        saveLocalization(transaction, name: "Aysha Mendoza", company: "Lowe's", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAysha%20Mendoza.jpg?alt=media&token=2bf6bda3-5a6c-4bff-8a78-59013810cbea", tagID: tag5)
        saveLocalization(transaction, name: "Alexandra Juarez", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAlexandra%20Juarez.jpg?alt=media&token=f77af1c2-3db4-4d20-bbc6-bd118bd71db1", tagID: tag5)
        saveLocalization(transaction, name: "Rhona North", company: "Home Depot", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRhona%20North.jpg?alt=media&token=8f7e24bd-3ca9-40b0-b144-70a9f9fa5f11", tagID: tag5)
        saveLocalization(transaction, name: "Jethro Mackay", company: "Guardian Life Ins. Co. of America", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FJethro%20Mackay.jpg?alt=media&token=6ae6d993-8f21-4bd7-8731-901537098a4a", tagID: tag5)
        saveLocalization(transaction, name: "Fenton Burns", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FFenton%20Burns.jpg?alt=media&token=6fc50f06-832f-40eb-8543-d2947e083db4", tagID: tag5)
        saveLocalization(transaction, name: "Chardonnay Mora", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FChardonnay%20Mora.jpg?alt=media&token=80006393-ba2c-4ec1-8f65-22529b37ed1a", tagID: tag6)
        saveLocalization(transaction, name: "Orlando Grey", company: "Icahn Enterprises", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FOrlando%20Grey.jpg?alt=media&token=61501977-f7c0-424d-a021-f4e4fccc112c", tagID: tag6)
        saveLocalization(transaction, name: "Sameer Gay", company: "Caesars Entertainment", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSameer%20Gay.jpg?alt=media&token=b3c58322-82b4-4cc0-833e-05a9784d1891", tagID: tag6)
        saveLocalization(transaction, name: "Henley Stephens", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FHenley%20Stephens.jpg?alt=media&token=87705a51-6c6b-446e-a280-24df2cc6f538", tagID: tag6)
        saveLocalization(transaction, name: "Amanpreet Olson", company: "Chemours", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FAmanpreet%20Olson.jpg?alt=media&token=7abe0900-1a69-42ce-953d-e2ffd32e3e36", tagID: tag6)
        saveLocalization(transaction, name: "Ruby Cantrell", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FRuby%20Cantrell.jpg?alt=media&token=f70eda1e-9a2f-41f2-8647-bba1d8ee3dfb", tagID: tag6)
        saveLocalization(transaction, name: "Braxton Rios", company: "Chemours", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FBraxton%20Rios.jpg?alt=media&token=f97379aa-3734-4db7-944f-b38d50dad920", tagID: tag6)
        saveLocalization(transaction, name: "Courteney Flowers", company: "Eli Lilly", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FCourteney%20Flowers.jpg?alt=media&token=d7ebd355-f487-4e0b-b923-331a646ea5ac", tagID: tag6)
        saveLocalization(transaction, name: "Saqlain Melia", company: "M&T Bank Corp.", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSaqlain%20Melia.jpg?alt=media&token=a88b2075-6e3b-4779-9810-6ea8ad6df22a", tagID: tag6)
        saveLocalization(transaction, name: "Arooj Mata", company: "M&T Bank Corp.", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FArooj%20Mata.jpg?alt=media&token=46908e1d-27b9-4ce1-9b9f-61eb8a178a99", tagID: tag6)
        saveLocalization(transaction, name: "Zayne Berger", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FZayne%20Berger.jpg?alt=media&token=42612d29-10b0-47a5-8f9a-030b29d441a5", tagID: tag6)
        saveLocalization(transaction, name: "Raheel Downs", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FRaheel%20Downs.jpg?alt=media&token=e99427d7-6f99-4f72-bcbb-70910f97c9c3", tagID: tag6)
        saveLocalization(transaction, name: "Jill Kinney", company: "Delta Air Lines", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FJill%20Kinney.jpg?alt=media&token=0e124cbc-7f55-40fe-9120-331ed9b310e0", tagID: tag6)
        saveLocalization(transaction, name: "Junaid Alfaro", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FJunaid%20Alfaro.jpg?alt=media&token=e16b9abc-a37b-4f51-a442-d7bda5ae9016", tagID: tag6)
        saveLocalization(transaction, name: "Allison Vickers", company: "Cummins", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FAllison%20Vickers.jpg?alt=media&token=bc2465c2-5a08-49ca-a2ed-2c2bb42fbf9c", tagID: tag6)
        saveLocalization(transaction, name: "Poppie Hudson", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FPoppie%20Hudson.jpg?alt=media&token=093d464f-5922-46ba-a4f3-c1586b2c3d20", tagID: tag6)
        saveLocalization(transaction, name: "Zakariya Mcgregor", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FZakariya%20Mcgregor.jpg?alt=media&token=ecdf4396-fc79-4909-b8aa-d8d963d45beb", tagID: tag6)
        saveLocalization(transaction, name: "Kerys Christensen", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FKerys%20Christensen.jpg?alt=media&token=82a92adc-3c7d-4300-932c-271938e01e76", tagID: tag6)
        saveLocalization(transaction, name: "Lillia Johnson", company: "Autoliv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FLillia%20Johnson.jpg?alt=media&token=8217c2b9-d8ec-4221-820a-b0f9d2ebe12b", tagID: tag6)
        saveLocalization(transaction, name: "Stan Wilkes", company: "Leidos Holdings", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FStan%20Wilkes.jpg?alt=media&token=feafe129-a819-4acb-889f-61f7bcae016f", tagID: tag6)
        saveLocalization(transaction, name: "Shea Sutton", company: "Autoliv", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FShea%20Sutton.jpg?alt=media&token=eba33548-b8b9-44ed-8304-c1d1c88dc8c7")
        saveLocalization(transaction, name: "Montana Horne", company: "L Brands", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FMontana%20Horne.jpg?alt=media&token=e3ef95e3-65ed-4e19-840c-6932d3803402")
        saveLocalization(transaction, name: "Charley Finnegan", company: "Hewlett Packard Enterprise", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FCharley%20Finnegan.jpg?alt=media&token=51634a91-7212-479b-a6f3-7f7220ead1aa")
        saveLocalization(transaction, name: "Kadie Roth", company: "Home Depot", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTest3%2FKadie%20Roth.jpg?alt=media&token=e9bd5395-440a-4bc3-ac33-be9c96ef1234")
        saveLocalization(transaction, name: "Saniya Hogan", company: "Eversource Energy", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FSaniya%20Hogan.jpg?alt=media&token=f5fa44bf-1a5d-4c42-93b8-28303cb9a1e3")
        saveLocalization(transaction, name: "Harper Collins", company: "Eli Lilly", front: "https://firebasestorage.googleapis.com/v0/b/virtual-business-card-ff129.appspot.com/o/UserTesting2%2FHarper%20Collins.jpg?alt=media&token=77308089-739a-419d-bd60-0437667c93ce")
    }

}
// swiftlint:enable all
