//
//  GroupedCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol GroupedCardsVMDelegate: class {
    func refreshData(animated: Bool)
    func presentReceivedCards(with viewModel: ReceivedCardsVM)
}

final class GroupedCardsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<GroupedCardsVM.Section, GroupedCardsView.TableCell.DataModel>

    weak var delegate: GroupedCardsVMDelegate?
    
    var selectedGroupingProperty = CardGroup.GroupingProperty.tag {
        didSet { didSetGroupingProperty() }
    }

    private var searchedQuery = ""

    private lazy var groupingQueue = DispatchQueue(label: "GroupedCardsVMQueue")

    private let groupingProperties: [CardGroup.GroupingProperty] = [.tag, .company, .dateDay, .dateMonth, .dateYear]

    private let encodeValueDateFormatter = ISO8601DateFormatter()
    private let dateTitleFormatter = DateTitleFormatter()
    
    private lazy var sortingPerGroupingProperty: [CardGroup.GroupingProperty: CardGroup.Sorting] = {
        var this = [CardGroup.GroupingProperty: CardGroup.Sorting]()
        groupingProperties.forEach {
            this[$0] = $0.defaultSorting
        }
        return this
    }()

    private var cards = [ReceivedBusinessCardMC]()
    private var tags = [BusinessCardTagID: BusinessCardTagMC]()
    
    private var groups = [CardGroup]()
    private var displayedGroupIndexes = [Int]()
    
    private func updateGrouping() {
        switch selectedGroupingProperty {
        case .tag: groups = CardGroup.groupByTag(cards: cards)
        case .dateDay: groups = CardGroup.groupByReceivingDay(cards: cards, dateFormatter: encodeValueDateFormatter)
        case .company: groups = CardGroup.groupByCompany(cards: cards)
        case .dateMonth: groups = CardGroup.groupByReceivingMonth(cards: cards, dateFormatter: encodeValueDateFormatter)
        case .dateYear: groups = CardGroup.groupByReceivingYear(cards: cards, dateFormatter: encodeValueDateFormatter)
        }
        updateSorting()
        displayedGroupIndexes = Array(0 ..< groups.count)
    }
    
    private func updateSorting() {
        switch selectedGroupingProperty {
        case .tag:
            groups = groups.sorted {
                if let tagID0 = $0.groupingValue, let tagID1 = $1.groupingValue {
                    return tags[tagID0]?.priorityIndex ?? Int.max < tags[tagID1]?.priorityIndex ?? Int.max
                } else {
                    return $1.groupingValue == nil
                }
            }
        default:
            let sorting = sortingPerGroupingProperty[selectedGroupingProperty]!
            switch sorting {
            case .ascending: groups = groups.sorted { $0.groupingValue ?? "" < $1.groupingValue ?? "" }
            case .descending: groups = groups.sorted { $0.groupingValue ?? "" > $1.groupingValue ?? "" }
            }
        }
    }
    
    private func didSetGroupingProperty() {
        groupingQueue.async {
            self.updateGrouping()
            DispatchQueue.main.async {
                self.delegate?.refreshData(animated: false)
            }
        }
    }
}

// MARK: - Item Data

extension GroupedCardsVM {
    
    private func shouldDisplayGroup(_ group: CardGroup, forQuery query: String) -> Bool {
        switch selectedGroupingProperty {
        case .tag:
            guard let tagID = group.groupingValue else { return false }
            return tags[tagID]?.title.range(of: query, options: .caseInsensitive) != nil
        case .company:
            return group.groupingValue?.range(of: query, options: .caseInsensitive) != nil
        case .dateDay:
            return itemTitle(groupingValue: group.groupingValue).range(of: query, options: .caseInsensitive) != nil
        case .dateMonth:
            return itemTitle(groupingValue: group.groupingValue).range(of: query, options: .caseInsensitive) != nil
        case .dateYear:
            return itemTitle(groupingValue: group.groupingValue).range(of: query, options: .caseInsensitive) != nil
        }
    }
    
    private static func itemSubtitle(cards: [ReceivedBusinessCardMC]) -> String {
        cards
            .map(\.ownerDisplayName)
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    private func itemTitle(groupingValue: String?) -> String {
        switch selectedGroupingProperty {
        case .tag: return itemTitleForTag(groupingValue: groupingValue)
        case .company: return itemTitleForCompany(groupingValue: groupingValue)
        case .dateDay: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.dayFormatter)
        case .dateMonth: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.monthFormatter)
        case .dateYear: return itemTitleForDate(groupingValue: groupingValue, dateFormatter: dateTitleFormatter.yearFormatter)
        }
    }
    
    private func itemTitleForTag(groupingValue: String?) -> String {
        if let tagID = groupingValue {
            return tags[tagID]?.title ?? ""
        }
        return NSLocalizedString("Not Tagged", comment: "")
    }

    private func itemTagColor(groupingValue: String?) -> UIColor? {
        if let tagID = groupingValue {
            return tags[tagID]?.displayColor
        }
        return nil
    }
    
    private func itemTitleForCompany(groupingValue: String?) -> String {
        if let company = groupingValue {
            return company
        }
        return NSLocalizedString("Personal Cards", comment: "")
    }
    
    private func itemTitleForDate(groupingValue: String?, dateFormatter: DateFormatter) -> String {
        guard let dateString = groupingValue else {
            return "" // this should never happen
        }
        guard let date = encodeValueDateFormatter.date(from: dateString) else {
            return "" // this should never happen
        }
        return dateFormatter.string(from: date)
    }
}

// MARK: - ViewController API

extension GroupedCardsVM {
    var title: String {
        NSLocalizedString("Collection", comment: "")
    }

    var showsEmptyState: Bool {
        cards.isEmpty
    }
    
    var seeAllCardsButtonTitle: String {
        NSLocalizedString("See All", comment: "")
    }
    
    var tabBarIconImage: UIImage {
        Asset.Images.Icon.collection.image
    }
    
    var availableGroupingModes: [String] {
        groupingProperties.map(\.localizedName)
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(displayedGroupIndexes.map { groupDataModel(at: $0) })
        return snapshot
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let title = groupDataModel(at: displayedGroupIndexes[indexPath.item]).title
        let group = groups[displayedGroupIndexes[indexPath.item]]
        let viewModel: ReceivedCardsVM
        if group.groupingProperty == .tag, let tagID = group.groupingValue, let tag = tags[tagID] {
            viewModel = ReceivedCardsVM(userID: userID, dataFetchMode: .tagWithSpecifiedIDs(group.cardIDs, tag: tag), title: title)
        } else {
            viewModel = ReceivedCardsVM(userID: userID, dataFetchMode: .specifiedIDs(group.cardIDs), title: title)
        }
        delegate?.presentReceivedCards(with: viewModel)
    }
    
    func didSelectGroupingMode(at index: Int) {
        selectedGroupingProperty = groupingProperties[index]
    }
    
    func didTapSeeAll() {
        let title = NSLocalizedString("All Cards", comment: "")
        let vm = ReceivedCardsVM(userID: userID, dataFetchMode: .allReceivedCards, title: title)
        delegate?.presentReceivedCards(with: vm)
    }
    
    func didSearch(for query: String) {
        searchedQuery = query
        if query.isEmpty {
            displayedGroupIndexes = Array(0 ..< groups.count)
            delegate?.refreshData(animated: true)
        } else {
            groupingQueue.async {
                let displayedGroupIndexes = self.groups
                    .enumerated()
                    .filter { _, group in self.shouldDisplayGroup(group, forQuery: query) }
                    .map { idx, _ in idx }
                
                DispatchQueue.main.async {
                    self.displayedGroupIndexes = displayedGroupIndexes
                    self.delegate?.refreshData(animated: true)
                }
            }
        }
    }

    func tagsVM() -> TagsVM {
        TagsVM(userID: userID)
    }

    private func groupDataModel(at index: Int) -> GroupedCardsView.TableCell.DataModel {
        let group = groups[index]
        let cardsInGroup = cards.filter { group.cardIDs.contains($0.id) }

        return GroupedCardsView.TableCell.DataModel(
            modelNumber: index,
            frontImageURL: cardsInGroup[optional: 0]?.displayedLocalization.frontImage.url,
            frontImageCornerRadiusHeightMultiplier: CGFloat(cardsInGroup[optional: 0]?.displayedLocalization.cornerRadiusHeightMultiplier ?? 0),
            middleImageURL: cardsInGroup[optional: 1]?.displayedLocalization.frontImage.url,
            middleImageCornerRadiusHeightMultiplier: CGFloat(cardsInGroup[optional: 1]?.displayedLocalization.cornerRadiusHeightMultiplier ?? 0),
            backImageURL: cardsInGroup[optional: 2]?.displayedLocalization.frontImage.url,
            backImageCornerRadiusHeightMultiplier: CGFloat(cardsInGroup[optional: 2]?.displayedLocalization.cornerRadiusHeightMultiplier ?? 0),
            title: itemTitle(groupingValue: group.groupingValue),
            subtitle: Self.itemSubtitle(cards: cardsInGroup),
            cardCountText: "\(cardsInGroup.count)",
            tagColor: itemTagColor(groupingValue: group.groupingValue)
        )
    }
}

// MARK: - Firebase fetch

extension GroupedCardsVM {
    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    private var tagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }
    
    func fetchData() {
        receivedCardsCollectionReference.order(by: "receivingDate", descending: true).addSnapshotListener { [weak self] querySnapshot, error in
            self?.receivedCardCollectionDidChange(querySnapshot, error)
        }
        tagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.cardTagsDidChange(querySnapshot, error)
        }
    }
    
    private func receivedCardCollectionDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }
        groupingQueue.async {
            self.cards = querySnap.documents.compactMap {
                guard let bc = ReceivedBusinessCard(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping business card:", $0.documentID)
                    return nil
                }
                return ReceivedBusinessCardMC(card: bc)
            }
            self.updateGrouping()
            DispatchQueue.main.async {
                self.searchIfActiveAndRefresh()
            }
        }
    }
    
    private func cardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        groupingQueue.async {
            var newTags = [BusinessCardTagID: BusinessCardTagMC]()
            querySnap.documents.forEach {
                guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping business card:", $0.documentID)
                    return
                }
                newTags[tag.id] = BusinessCardTagMC(tag: tag)
            }
            self.tags = newTags
            if self.selectedGroupingProperty == .tag {
                self.updateGrouping()
            }
            if !self.cards.isEmpty {
                DispatchQueue.main.async {
                    self.searchIfActiveAndRefresh()
                }
            }
        }
    }

    private func searchIfActiveAndRefresh() {
        if !searchedQuery.isEmpty {
            didSearch(for: searchedQuery)
        } else {
            self.delegate?.refreshData(animated: false)
        }
    }
}

// MARK: - DateTitleFormatter

extension GroupedCardsVM {
    private struct DateTitleFormatter {
        
        let dayFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateStyle = UIScreen.main.bounds.width > 320 ? .long : .medium
            return this
        }()
        
        let monthFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMYYYY", options: 0, locale: Locale.current)
            return this
        }()
        
        let yearFormatter: DateFormatter = {
            let this = DateFormatter()
            this.timeStyle = .none
            this.dateStyle = UIScreen.main.bounds.width > 320 ? .long : .medium
            this.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale.current)
            return this
        }()
    }
}

// MARK: - Section

extension GroupedCardsVM {
    enum Section {
        case main
    }
}
