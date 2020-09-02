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
    func presentEditCardNotesVC()
    func presentErrorAlert(message: String)
}

class CardDetailsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, Item>

    weak var delegate: CardDetailsVMDelegate? {
        didSet { didSetDelegate() }
    }

    let cardID: BusinessCardID

    var cardLocalization: BusinessCardLocalization? { nil }

    private(set) var mostRecentMotionData: CMDeviceMotion?

    private lazy var makeSectionsQueue = DispatchQueue(label: "makeSectionsQueue\(cardID)")

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

    func fetchData() {
        // override
    }

    func saveLocalizationUpdates() {
        // Override in subclass
    }

    func deleteCard() {
        // Override in subclass
    }

    func editCardTagsVM() -> EditCardTagsVM? {
        // Override in subclass
        return nil
    }

    func editCardNotesVM() -> EditCardNotesVM? {
        // Override in subclass
        return nil
    }

    func sectionFactory() -> CardDetailsSectionFactory? {
        // Override in subclass
        nil
    }

    final func makeSections() {
        guard let factory = sectionFactory() else { return }
        makeSectionsQueue.async {
            let newSections = factory.makeSections()
            DispatchQueue.main.async {
                self.sections = newSections
                self.delegate?.reloadData()
            }
        }
    }

    final func clearSections() {
        sections = []
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
        guard let card = self.cardLocalization else { return }

        switch action {
        case .call: Self.openPhone(with: actionValue)
        case .sendEmail: delegate?.presentSendEmailViewController(recipient: actionValue)
        case .visitWebsite: Self.openBrowser(with: actionValue)
        case .navigate: Self.openMaps(card: card)
        case .copy: UIPasteboard.general.string = actionValue
        case .editNotes: delegate?.presentEditCardNotesVC()
        case .editTags: delegate?.presentEditCardTagsVC()
        }
    }
}

// MARK: - Public API

extension CardDetailsVM {
    var titleImageURL: URL? {
        cardLocalization?.frontImage.url
    }

    var closeButtonImage: UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        return UIImage(systemName: "xmark", withConfiguration: config)!
    }

    var hapticSharpness: Float {
        cardLocalization?.hapticFeedbackSharpness ?? prefetchedData.hapticSharpness
    }

    var cardCornerRadiusHeightMultiplier: CGFloat {
        CGFloat(cardLocalization?.cornerRadiusHeightMultiplier ?? 0)
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
}

// MARK: - Static Action Performers

extension CardDetailsVM {
    private static func openPhone(with actionValue: String) {
        guard !actionValue.isEmpty else { return }
        guard let number = URL(string: "tel://" + actionValue.replacingOccurrences(of: " ", with: "")) else { return }
        UIApplication.shared.open(number)
    }

    private static func condenseAddress(_ addressData: BusinessCardLocalization.Address) -> String {
        var address = ""
        if let street = addressData.street, !street.isEmpty {
            address.append(street + ",")
        }
        if let city = addressData.city, !city.isEmpty {
            address.append(city + ",")
        }
        if let postCode = addressData.postCode, !postCode.isEmpty {
            address.append(postCode + ",")
        }
        if let country = addressData.country, !country.isEmpty {
            address.append(country)
        }
        return address
    }

    private static func openMaps(card: BusinessCardLocalization) {
        let address = condenseAddress(card.address)
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
