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
    func dismissSelfWithSystemAnimation()
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
    func presentEditCardTagsVC()
    func presentEditCardNotesVC(viewModel: EditCardNotesVM)
    func presentErrorAlert(message: String)
}

final class CardDetailsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, Item>

    weak var delegate: CardDetailsVMDelegate? {
        didSet { didSetDelegate() }
    }

    private(set) var mostRecentMotionData: CMDeviceMotion?

    private lazy var makeSectionsQueue = DispatchQueue(label: "makeSectionsQueue\(cardID)")

    private let cardID: BusinessCardID
    private var card: EditReceivedBusinessCardMC?
    private var updates: (localizations: [BusinessCardLocalization], version: Int)?

    private var tags = [BusinessCardTagMC]()
        
    private let prefetchedData: PrefetchedData
    
    private lazy var sections = [Section(type: .card, item: Item(itemNumber: 0, dataModel: .cardImagesCell(prefetchedData.dataModel), actions: []))]
    
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
                self.mostRecentMotionData = motion
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
        case .tagCell, .noTagsCell: return ""
        case .updateCell: return ""
        case .deleteCell: return ""
        }
    }

    private func performAction(_ action: Action, actionValue: String) {
        guard let card = self.card else { return }

        switch action {
        case .call: Self.openPhone(with: actionValue)
        case .sendEmail: delegate?.presentSendEmailViewController(recipient: actionValue)
        case .visitWebsite: Self.openBrowser(with: actionValue)
        case .navigate: Self.openMaps(card: card)
        case .copy: UIPasteboard.general.string = actionValue
        case .editNotes:
            let vm = EditCardNotesVM(notes: card.notes)
            vm.editingDelegate = self
            delegate?.presentEditCardNotesVC(viewModel: vm)
        case .editTags:
            delegate?.presentEditCardTagsVC()
        }
    }
}

// MARK: - Public API

extension CardDetailsVM {
    var titleImageURL: URL? {
        card?.displayedLocalization.frontImage.url
    }

    var closeButtonImage: UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        return UIImage(systemName: "xmark", withConfiguration: config)!
    }

    var hasLocalizationUpdates: Bool {
        !(updates?.localizations ?? []).isEmpty
    }

    var hapticSharpness: Float {
        card?.displayedLocalization.hapticFeedbackSharpness ?? prefetchedData.hapticSharpness
    }

    var cardCornerRadiusHeightMultiplier: CGFloat {
        CGFloat(card?.displayedLocalization.cornerRadiusHeightMultiplier ?? 0)
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(sections.map(\.type))
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section.type)
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
        
        performAction(action, actionValue: actionValue)
    }

    func saveLocalizationUpdates() {
        guard let card = self.card else { return }
        guard let updates = self.updates, !updates.localizations.isEmpty else { return }
        card.localizations = updates.localizations
        card.version = updates.version
        card.save(in: receivedCardCollectionReference)
    }

    func deleteCard() {
        guard let card = self.card else { return }
        card.delete(in: receivedCardCollectionReference)
        delegate?.dismissSelfWithSystemAnimation()
    }

    func editCardTagsVM() -> EditCardTagsVM? {
        guard let card = card else { return nil }
        let vm = EditCardTagsVM(userID: userID, selectedTagIDs: card.tagIDs)
        vm.selectionDelegate = self
        return vm
    }
}

// MARK: - Static Action Performers

extension CardDetailsVM {
    private static func openPhone(with actionValue: String) {
        guard !actionValue.isEmpty else { return }
        guard let number = URL(string: "tel://" + actionValue) else { return }
        UIApplication.shared.open(number)
    }

    private static func openMaps(card: EditReceivedBusinessCardMC) {
        let address = card.addressCondensed
        guard !address.isEmpty else { return }
        guard let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "http://maps.apple.com/?address=" + addressEncoded) else { return }
        UIApplication.shared.open(url)
    }

    private static func openBrowser(with actionValue: String) {
        guard !actionValue.isEmpty else { return }
        let urlString = actionValue.starts(with: "http") ? actionValue : "http://\(actionValue)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Row Creation

extension CardDetailsVM {
    
    private static let defaultImageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)

    static func iconImage(for action: Action) -> UIImage? {
        switch action {
        case .copy: return UIImage(systemName: "doc.on.doc.fill", withConfiguration: Self.defaultImageConfig)
        case .call: return UIImage(systemName: "phone.fill", withConfiguration: Self.defaultImageConfig)
        case .sendEmail: return UIImage(systemName: "envelope.fill", withConfiguration: Self.defaultImageConfig)
        case .visitWebsite: return UIImage(systemName: "safari.fill", withConfiguration: Self.defaultImageConfig)
        case .navigate: return UIImage(systemName: "map.fill", withConfiguration: Self.defaultImageConfig)
        case .editNotes: return UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        case .editTags: return UIImage(systemName: "tag.fill", withConfiguration: Self.defaultImageConfig)
        }
    }

    private func makeSections() {
        guard let card = self.card else { return }
        makeSectionsQueue.async {
            let selectedTags = self.tags.filter { card.tagIDs.contains($0.id) }
            let newSections = CardDetailsSectionFactory(
                card: card.receivedBusinessCardMC(),
                tags: selectedTags,
                isUpdateAvailable: self.hasLocalizationUpdates,
                imageProvider: Self.iconImage
            ).makeRows()
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

    private var directCardExchangeReference: CollectionReference {
        db.collection(DirectCardExchange.collectionName)
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
                DispatchQueue.main.async {
                    self.card = nil
                    self.sections = []
                    self.delegate?.reloadData()
                }
                return
            }

            if let exchangeID = card.exchangeID {
                self.directCardExchangeReference.document(exchangeID).addSnapshotListener { [weak self] documentSnapshot, error in
                    self?.exchangeDidChange(documentSnapshot, error)
                }
            }

            DispatchQueue.main.async {
                self.card = card
                self.makeSections()
            }
        }
    }

    private func exchangeDidChange(_ documentSnapshot: DocumentSnapshot?, _ error: Error?) {

        guard let card = self.card else { return }

        guard let document = documentSnapshot else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching exchange changed:", error?.localizedDescription ?? "No error info available.")
            return
        }

        guard let exchange = DirectCardExchangeMC(exchangeDocument: document) else {
            print(#file, "Error mapping exchange:", document.documentID)
            return
        }

        if exchange.ownerID == userID && exchange.guestCardVersion > card.version, let localizations = exchange.guestCardLocalizations, !localizations.isEmpty {
            self.updates = (localizations, exchange.guestCardVersion)
        } else if exchange.ownerCardVersion > card.version, !exchange.ownerCardLocalizations.isEmpty {
            self.updates = (exchange.ownerCardLocalizations, exchange.ownerCardVersion)
        } else {
            self.updates = nil
        }
        self.makeSections()
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

        var type: SectionType
        var items: [Item]

        init(type: SectionType, items: [CardDetailsVM.Item]) {
            self.type = type
            self.items = items
        }
        
        init(type: SectionType, item: CardDetailsVM.Item) {
            self.type = type
            self.items = [item]
        }
    }

    enum SectionType {
        case card, update, tags, notes, meta, personalData, contact, address, delete
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
        case tagCell(CardDetailsView.TagCell.DataModel)
        case noTagsCell
        case updateCell
        case deleteCell
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
