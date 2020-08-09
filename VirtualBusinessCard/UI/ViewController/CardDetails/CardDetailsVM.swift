//
//  CardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit
import CoreMotion

protocol CardDetailsVMDelegate: class {
    func reloadData()
    func presentSendEmailViewController(recipient: String)
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func presentEditCardTagsVC(viewModel: EditCardTagsVM)
    func presentEditCardNotesVC(viewModel: EditCardNotesVM)
    func presentErrorAlert(message: String)
}

final class CardDetailsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>

    weak var delegate: CardDetailsVMDelegate? {
        didSet { didSetDelegate() }
    }
    
    private let cardID: BusinessCardID
    private var card: EditReceivedBusinessCardMC?

    private var tags = [BusinessCardTagMC]()
        
    private let prefetchedData: PrefetchedData
    
    private lazy var sections = [Section(item: Item(itemNumber: 0, dataModel: .cardImagesCell(prefetchedData.dataModel), actions: []))]
    
    private lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.1
        return manager
    }()

    init(userID: UserID, cardID: BusinessCardID, initialLoadDataModel: PrefetchedData) {
        self.cardID = cardID
        self.prefetchedData = initialLoadDataModel
        super.init(userID: userID)
    }
    
    private func didSetDelegate() {
        if delegate != nil {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, _ in
                guard let self = self, let motion = motion else { return }
                self.delegate?.didUpdateMotionData(motion, over: self.motionManager.deviceMotionUpdateInterval)
            }
        } else {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func getActionValue(from selectedItem: Item) -> String {
        switch selectedItem.dataModel {
        case .dataCell(let dm): return dm.value ?? ""
        case .dataCellImage(let dm): return dm.value ?? ""
        case .cardImagesCell: return ""
        }
    }

    private func performAction(_ action: Action, actionValue: String) {
        guard let card = self.card else { return }

        switch action {
        case .call: Self.openPhone(with: actionValue)
        case .sendEmail: delegate?.presentSendEmailViewController(recipient: actionValue)
        case .visitWebsite: Self.openBrowser(with: actionValue)
        case .navigate: Self.openMaps(with: actionValue, card: card)
        case .copy: UIPasteboard.general.string = actionValue
        case .editNotes:
            let vm = EditCardNotesVM(notes: card.notes)
            vm.editingDelegate = self
            delegate?.presentEditCardNotesVC(viewModel: vm)
        case .editTags:
            let vm = EditCardTagsVM(userID: userID, selectedTagIDs: card.tagIDs)
            vm.selectionDelegate = self
            delegate?.presentEditCardTagsVC(viewModel: vm)
        }
    }
}

// MARK: - Public API

extension CardDetailsVM {
    var titleImageURL: URL? {
        card?.displayedCardData.frontImage.url
    }

    var hapticSharpness: Float {
        card?.displayedCardData.hapticFeedbackSharpness ?? prefetchedData.hapticSharpness
    }

    var cardCornerRadiusHeightMultiplier: CGFloat {
        CGFloat(card?.displayedCardData.cornerRadiusHeightMultiplier ?? 0)
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(Array(0..<sections.count))
        sections.enumerated().forEach { index, section in
            snapshot.appendItems(section.items, toSection: index)
        }
        return snapshot
    }

    func actions(for indexPath: IndexPath) -> [Action] {
        sections[indexPath.section].items[indexPath.item].actions
    }

    func didSelect(action: Action, at indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.item]
        guard selectedItem.actions.contains(action) else { return }

        let actionValue = getActionValue(from: selectedItem)
        
        guard !actionValue.isEmpty else { return }
        performAction(action, actionValue: actionValue)
    }
}

// MARK: - Static Action Performers

extension CardDetailsVM {
    private static func openPhone(with actionValue: String) {
        guard let number = URL(string: "tel://" + actionValue) else { return }
        UIApplication.shared.open(number)
    }

    private static func openMaps(with actionValue: String, card: EditReceivedBusinessCardMC) {
        let address = card.addressCondensed
        guard !address.isEmpty else { return }
        guard let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "http://maps.apple.com/?address=" + addressEncoded) else { return }
        UIApplication.shared.open(url)
    }

    private static func openBrowser(with actionValue: String) {
        let urlString = actionValue.starts(with: "http") ? "http://\(actionValue)" : actionValue
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Row Creation

extension CardDetailsVM {
    
    private static let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)

    static func iconImage(for action: Action) -> UIImage? {
        switch action {
        case .copy: return UIImage(systemName: "doc.on.doc.fill", withConfiguration: Self.imageConfig)
        case .call: return UIImage(systemName: "phone.fill", withConfiguration: Self.imageConfig)
        case .sendEmail: return UIImage(systemName: "envelope.fill", withConfiguration: Self.imageConfig)
        case .visitWebsite: return UIImage(systemName: "safari.fill", withConfiguration: Self.imageConfig)
        case .navigate: return UIImage(systemName: "map.fill", withConfiguration: Self.imageConfig)
        case .editNotes: return UIImage(systemName: "pencil", withConfiguration: Self.imageConfig)
        case .editTags: return UIImage(systemName: "tag.fill", withConfiguration: Self.imageConfig)
        }
    }

    private func makeSections() {
        guard let card = self.card else { return }
        DispatchQueue.global().async {
            let selectedTags = self.tags.filter { card.tagIDs.contains($0.id) }
            let newSections = CardDetailsSectionFactory(card: card.receivedBusinessCardMC(), tags: selectedTags, imageProvider: Self.iconImage).makeRows()
            DispatchQueue.main.async {
                self.sections = newSections
                self.delegate?.reloadData()
            }
        }
    }
}

// MARK: - Firebase fetch

extension CardDetailsVM {

    private var tagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }
    
    private var receivedCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    func fetchData() {
        receivedCardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
        }
        tagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.cardTagsDidChange(querySnapshot, error)
        }
    }
    
    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching received card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        DispatchQueue.global().async {
            guard let card = EditReceivedBusinessCardMC(documentSnapshot: doc) else {
                print(#file, "Error mapping received card:", error?.localizedDescription ?? "No error info available.")
                self.card = nil
                self.sections = []
                return
            }
            DispatchQueue.main.async {
                self.card = card
                self.makeSections()
            }
        }
    }

    private func cardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        DispatchQueue.global().async {
            var newTags: [BusinessCardTagMC] = querySnap.documents.compactMap {
                guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping tag:", $0.documentID)
                    return nil
                }
                return BusinessCardTagMC(tag: tag)
            }
            newTags.sort(by: BusinessCardTagMC.sortByPriority)
            DispatchQueue.main.async {
                self.tags = newTags
                self.makeSections()
            }
        }
    }
}

// MARK: - EditCardTagsVMSelectionDelegate

extension CardDetailsVM: EditCardTagsVMSelectionDelegate {
    func didChangeSelectedTags(to tags: [BusinessCardTagMC]) {
        guard let card = self.card else { return }
        card.tagIDs = tags.map(\.id)
        card.save(in: receivedCardCollectionReference, fields: [.tagIDs]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        makeSections()
    }
}

// MARK: - EditCardNotesVMEditingDelegate

extension CardDetailsVM: EditCardNotesVMEditingDelegate {
    func didEditNotes(to editedNotes: String) {
        guard let card = self.card else { return }
        card.notes = editedNotes
        card.save(in: receivedCardCollectionReference, fields: [.notes]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        makeSections()
    }
}

// MARK: - Section, Item

extension CardDetailsVM {
    struct Section: Hashable {
        
        var items: [Item]

        init(items: [CardDetailsVM.Item]) {
            self.items = items
        }
        
        init(item: CardDetailsVM.Item) {
            self.items = [item]
        }
    }
    
    struct Item: Hashable {
        let itemNumber: Int
        let dataModel: DataModel
        let actions: [Action]
    }
    
    enum DataModel: Hashable {
        case dataCell(TitleValueCollectionCell.DataModel)
        case dataCellImage(TitleValueImageCollectionViewCell.DataModel)
        case cardImagesCell(CardFrontBackView.URLDataModel)
    }
    
    enum Action {
        case copy
        case call
        case sendEmail
        case visitWebsite
        case navigate
        case editNotes
        case editTags
        
        var title: String {
            switch self {
            case .copy: return NSLocalizedString("Copy", comment: "")
            case .call: return NSLocalizedString("Make a Call", comment: "")
            case .sendEmail: return NSLocalizedString("Send an Email", comment: "")
            case .visitWebsite: return NSLocalizedString("Open Website in Browser", comment: "")
            case .navigate: return NSLocalizedString("Open in Maps", comment: "")
            case .editNotes: return NSLocalizedString("Edit Notes", comment: "")
            case .editTags: return NSLocalizedString("Edit Tags", comment: "")
            }
        }
    }
}

extension CardDetailsVM {
    struct PrefetchedData {
        let dataModel: CardFrontBackView.URLDataModel
        let hapticSharpness: Float
    }
}
