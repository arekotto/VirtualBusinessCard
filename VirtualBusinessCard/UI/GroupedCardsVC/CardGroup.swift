//
//  CardGroup.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

extension GroupedCardsVM {
    struct CardGroup {
        let groupingProperty: GroupingProperty
        let groupingValue: GroupingValue
        let cardIDs: [BusinessCardID]
        
        internal init(groupingProperty: GroupingProperty, groupingValue: GroupingValue, cardIDs: [BusinessCardID]) {
            self.groupingProperty = groupingProperty
            self.groupingValue = groupingValue
            self.cardIDs = cardIDs
        }
        
        enum GroupingValue {
            case none
            case some(value: String)
        }
        
        enum GroupingProperty {
            case tag
            case date
            //        case location
            case company
            
            var localizedName: String {
                switch self {
                case .tag: return NSLocalizedString("Tag", comment: "")
                case .date: return NSLocalizedString("Date", comment: "")
                //            case .location: return NSLocalizedString("Location", comment: "")
                case .company: return NSLocalizedString("Company", comment: "")
                }
            }
        }
    }
}

extension GroupedCardsVM.CardGroup {
    static func groupByCompany(cards: [ReceivedBusinessCardMC]) -> [GroupedCardsVM.CardGroup] {
        var privateCards = [ReceivedBusinessCardMC]()
        var companyCards = [ReceivedBusinessCardMC]()
        cards.forEach { card in
            if card.cardData.position.company != nil {
                companyCards.append(card)
            } else {
                privateCards.append(card)
            }
        }
        
        let groupedDict = Dictionary(grouping: companyCards) { $0.cardData.position.company }
        let companyCardGroups = groupedDict.map { company, groupedCards in
            GroupedCardsVM.CardGroup(groupingProperty: .company, groupingValue: .some(value: company!), cardIDs: groupedCards.map(\.id))
        }
        
        if privateCards.isEmpty {
            return companyCardGroups
        } else {
            let privateCardGroup = GroupedCardsVM.CardGroup(groupingProperty: .company, groupingValue: .none, cardIDs: privateCards.map(\.id))
            return [privateCardGroup] + companyCardGroups
        }
    }
    
    static func groupByTag(cards: [ReceivedBusinessCardMC]) -> [GroupedCardsVM.CardGroup] {

        var notTaggedCards = [ReceivedBusinessCardMC]()
        var taggedCards = [ReceivedBusinessCardMC]()
        cards.forEach { card in
            if card.tagIDs.isEmpty {
                notTaggedCards.append(card)
            } else {
                taggedCards.append(card)
            }
        }
        
        var groupedCardsDict = [BusinessCardTagID: [BusinessCardID]]()
        groupedCardsDict = taggedCards.reduce(into: groupedCardsDict) { dict, card in
            card.tagIDs.forEach { tagID in
                let existingGroupedCardIDs = dict[tagID] ?? []
                dict[tagID] = existingGroupedCardIDs + [card.id]
            }
        }
        let taggedCardGroups = groupedCardsDict.map { tagID, groupedIDs in
            GroupedCardsVM.CardGroup(groupingProperty: .tag, groupingValue: .some(value: tagID), cardIDs: groupedIDs)
        }
        
        if notTaggedCards.isEmpty {
            return taggedCardGroups
        } else {
            let notTaggedCardGroup = GroupedCardsVM.CardGroup(groupingProperty: .tag, groupingValue: .none, cardIDs: notTaggedCards.map(\.id))
            return [notTaggedCardGroup] + taggedCardGroups
        }
    }
    
    static func groupByDate(cards: [ReceivedBusinessCardMC], dateFormatter df: ISO8601DateFormatter) -> [GroupedCardsVM.CardGroup] {
        var groupedCardsDict = [Date: [BusinessCardID]]()
        groupedCardsDict = cards.reduce(into: groupedCardsDict) { dict, card in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: card.receivingDate)
            let date = Calendar.current.date(from: components)!
            let existingGroupedCardIDs = dict[date] ?? []
            dict[date] = existingGroupedCardIDs + [card.id]
        }
        return groupedCardsDict.map { date, groupedIDs in
            GroupedCardsVM.CardGroup(groupingProperty: .date, groupingValue: .some(value: df.string(from: date)), cardIDs: groupedIDs)
        }
    }
}
