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
    func dismissSelf()
}

final class CardDetailsVM: PartialUserViewModel {
        
    weak var delegate: CardDetailsVMDelegate? {
        didSet { didSetDelegate() }
    }
    
    private let cardID: BusinessCardID
    private var card: ReceivedBusinessCardMC?
        
    private let prefetchedData: PrefetchedData
    
    private lazy var sections = [Section(singleItem: Item(dataModel: .cardImagesCell(prefetchedData.dataModel), actions: []))]
    
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
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] motion, error in
                guard let self = self, let motion = motion else { return }
                self.delegate?.didUpdateMotionData(motion, over: self.motionManager.deviceMotionUpdateInterval)
            }
        } else {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}
// MARK: - Public API

extension CardDetailsVM {
    var titleImageURL: URL? {
        card?.cardData.frontImage.url
    }

    var hapticSharpness: Float {
        card?.cardData.hapticFeedbackSharpness ?? prefetchedData.hapticSharpness
    }
    
    func numberOrSections() -> Int {
        sections.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        sections[section].items.count
    }
    
    func item(at indexPath: IndexPath) -> Item {
        sections[indexPath.section].items[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        sections[section].title
    }
    
    func didSelect(action: Action, at indexPath: IndexPath) {
        let selectedItem = item(at: indexPath)
        guard selectedItem.actions.contains(action) else { return }
        var actionValue = ""
        
        switch selectedItem.dataModel {
        case .dataCell(let dm): actionValue = dm.value ?? ""
        case .dataCellImage(let dm): actionValue = dm.value ?? ""
        case .cardImagesCell(_): actionValue = ""
        }
        
        guard !actionValue.isEmpty else { return }
        
        switch action {
        case .call:
            guard let number = URL(string: "tel://" + actionValue) else { return }
            UIApplication.shared.open(number)
        case .sendEmail:
            delegate?.presentSendEmailViewController(recipient: actionValue)
        case .visitWebsite:
            if !actionValue.starts(with: "http") {
                actionValue = "http://" + actionValue
            }
            guard let url = URL(string: actionValue) else { return }
            UIApplication.shared.open(url)
        case .navigate:
            guard let address = card?.addressCondensed, !address.isEmpty else { return }
            guard let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
            guard let url = URL(string: "http://maps.apple.com/?address=" + addressEncoded) else { return }
            UIApplication.shared.open(url)
        case .copy:
            UIPasteboard.general.string = actionValue
        }
    }
    
    func didTapCloseButton() {
        delegate?.dismissSelf()
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
        }
    }
}

// MARK: - Firebase fetch

extension CardDetailsVM {
    
    private var receivedCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
    
    func fetchData() {
        receivedCardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
        }
    }
    
    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching received card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        guard let card = ReceivedBusinessCardMC(documentSnapshot: doc) else {
            print(#file, "Error mapping received card:", error?.localizedDescription ?? "No error info available.")
            self.card = nil
            sections = []
            return
        }
        self.card = card
        sections = CardDetailsSectionFactory(card: card, imageProvider: Self.iconImage).makeRows()
        delegate?.reloadData()
    }
}

// MARK: - Section, Item

extension CardDetailsVM {
    struct Section {
        
        var items: [Item]
        var title: String?
        
        init(items: [CardDetailsVM.Item], title: String? = nil) {
            self.items = items
            self.title = title
        }
        
        init(singleItem: CardDetailsVM.Item, title: String? = nil) {
            self.items = [singleItem]
            self.title = title
        }
    }
    
    struct Item {
        let dataModel: DataModel
        let actions: [Action]
    }
    
    enum DataModel {
        case dataCell(TitleValueCollectionCell.DataModel)
        case dataCellImage(TitleValueImageCollectionViewCell.DataModel)
        case cardImagesCell(CardFrontBackView.DataModel)
    }
    
    enum Action {
        case copy
        case call
        case sendEmail
        case visitWebsite
        case navigate
        
        var title: String {
            switch self {
            case .copy: return NSLocalizedString("Copy", comment: "")
            case .call: return NSLocalizedString("Make a Call", comment: "")
            case .sendEmail: return NSLocalizedString("Send an Email", comment: "")
            case .visitWebsite: return NSLocalizedString("Open Website in Browser", comment: "")
            case .navigate: return NSLocalizedString("Open in Maps", comment: "")
            }
        }
    }
}

extension CardDetailsVM {
    struct PrefetchedData {
        let dataModel: CardFrontBackView.DataModel
        let hapticSharpness: Float
    }
}
