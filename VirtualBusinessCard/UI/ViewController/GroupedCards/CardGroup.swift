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
        let groupingValue: String?
        let cardIDs: [BusinessCardID]
        
        internal init(groupingProperty: GroupingProperty, groupingValue: String?, cardIDs: [BusinessCardID]) {
            self.groupingProperty = groupingProperty
            self.groupingValue = groupingValue
            self.cardIDs = cardIDs
        }
    }
}

extension GroupedCardsVM.CardGroup {
    enum GroupingValue {
        case none
        case some(value: String)
    }

    enum GroupingProperty: Int, Hashable {
        case tag
        case company
        case dateDay
        case dateMonth
        case dateYear
        //        case location

        var localizedName: String {
            switch self {
            case .tag: return NSLocalizedString("Tag", comment: "")
            case .dateDay: return NSLocalizedString("Day", comment: "")
            //            case .location: return NSLocalizedString("Location", comment: "")
            case .company: return NSLocalizedString("Company", comment: "")
            case .dateMonth: return NSLocalizedString("Month", comment: "")
            case .dateYear: return NSLocalizedString("Year", comment: "")
            }
        }

        var defaultSorting: Sorting {
            switch self {
            case .tag: return .ascending
            case .company: return .ascending
            case .dateDay: return .descending
            case .dateMonth: return .descending
            case .dateYear: return .descending
            }
        }
    }

    enum Sorting {
        case ascending
        case descending
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
            GroupedCardsVM.CardGroup(groupingProperty: .company, groupingValue: company, cardIDs: groupedCards.map(\.id))
        }
        
        if privateCards.isEmpty {
            return companyCardGroups
        } else {
            let privateCardGroup = GroupedCardsVM.CardGroup(groupingProperty: .company, groupingValue: .none, cardIDs: privateCards.map(\.id))
            return companyCardGroups + [privateCardGroup]
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
        
        let groupedCardsDict = taggedCards.reduce(into: [BusinessCardTagID: [BusinessCardID]]()) { dict, card in
            card.tagIDs.forEach { tagID in
                let existingGroupedCardIDs = dict[tagID] ?? []
                dict[tagID] = existingGroupedCardIDs + [card.id]
            }
        }
        let taggedCardGroups = groupedCardsDict.map { tagID, groupedIDs in
            GroupedCardsVM.CardGroup(groupingProperty: .tag, groupingValue: tagID, cardIDs: groupedIDs)
        }
        
        if notTaggedCards.isEmpty {
            return taggedCardGroups
        } else {
            let notTaggedCardGroup = GroupedCardsVM.CardGroup(groupingProperty: .tag, groupingValue: .none, cardIDs: notTaggedCards.map(\.id))
            return taggedCardGroups + [notTaggedCardGroup]
        }
    }
    
    static func groupByReceivingDay(cards: [ReceivedBusinessCardMC], dateFormatter df: ISO8601DateFormatter) -> [GroupedCardsVM.CardGroup] {
        groupByReceivingDate(cards: cards, dateFormatter: df, range: [.year, .month, .day])

    }
    
    static func groupByReceivingMonth(cards: [ReceivedBusinessCardMC], dateFormatter df: ISO8601DateFormatter) -> [GroupedCardsVM.CardGroup] {
        groupByReceivingDate(cards: cards, dateFormatter: df, range: [.year, .month])
    }
    
    static func groupByReceivingYear(cards: [ReceivedBusinessCardMC], dateFormatter df: ISO8601DateFormatter) -> [GroupedCardsVM.CardGroup] {
        groupByReceivingDate(cards: cards, dateFormatter: df, range: [.year])
    }
    
    private static func groupByReceivingDate(cards: [ReceivedBusinessCardMC], dateFormatter df: ISO8601DateFormatter, range: Set<Calendar.Component>) -> [GroupedCardsVM.CardGroup] {
        let groupedCardsDict = cards.reduce(into: [Date: [BusinessCardID]]()) { dict, card in
            let components = Calendar.current.dateComponents(range, from: card.receivingDate)
            let date = Calendar.current.date(from: components)!
            let existingGroupedCardIDs = dict[date] ?? []
            dict[date] = existingGroupedCardIDs + [card.id]
        }
        return groupedCardsDict.map { date, groupedIDs in
            GroupedCardsVM.CardGroup(groupingProperty: .dateDay, groupingValue: df.string(from: date), cardIDs: groupedIDs)
        }        
    }
}
