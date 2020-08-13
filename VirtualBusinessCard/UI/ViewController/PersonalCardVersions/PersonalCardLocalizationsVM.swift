//
//  PersonalCardLocalizationsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

protocol PersonalCardLocalizationsVMDelegate: class {
    func refreshData()
    func presentErrorAlert(message: String)
    func popSelf()
    func dismissAlert()
    func presentLoadingAlert(title: String)
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval)
}

final class PersonalCardLocalizationsVM: CompleteUserViewModel, MotionDataSource {

    typealias DataModel = PersonalCardLocalizationsView.TableCell.DataModel
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>

    weak var delegate: PersonalCardLocalizationsVMDelegate?

    private(set) lazy var motionManager = CMMotionManager()

    private let cardID: BusinessCardID
    private let currentLocale = Locale.current

    private var card: PersonalBusinessCardMC?
    private var dataModels = [DataModel]()

    init(userID: UserID, cardID: BusinessCardID) {
        self.cardID = cardID
        super.init(userID: userID)
    }

    func didReceiveMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        delegate?.didUpdateMotionData(motion, over: timeFrame)
    }

    override func informDelegateAboutDataRefresh() {
        cardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
        }
    }
}

// MARK: - ViewController API

extension PersonalCardLocalizationsVM {

    var newBusinessCardImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }

    var pushChangesToExchangesImages: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        return UIImage(systemName: "arrow.branch", withConfiguration: imgConfig)!
    }

    func actionConfig(for indexPath: IndexPath) -> ActionConfiguration? {
        guard let languageVersion = card?.localization(withID: dataModels[indexPath.row].id) else { return nil }
        let dataModel = dataModels[indexPath.row]
        let titleFormat = NSLocalizedString("%@ Localization", comment: "%@: language name")
        return ActionConfiguration(
            title: String.localizedStringWithFormat(titleFormat, dataModel.title),
            deleteActionTitle: NSLocalizedString("Delete Localization", comment: ""),
            isDefault: languageVersion.isDefault
        )
    }

    func confirmDeleteConfig(for: IndexPath) -> (title: String, deleteActionTitle: String) {
        if dataModels.count >= 2 {
            return (NSLocalizedString("Delete Localization?", comment: ""), NSLocalizedString("Delete ", comment: ""))
        } else {
            let title = NSLocalizedString("Deleting the only localization of the card will delete the card itself. Are you sure you want to delete this card?", comment: "")
            return (title, NSLocalizedString("Delete Business Card", comment: ""))
        }
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataModels)
        return snapshot
    }

    func newVersionCardCoordinator(root: AppNavigationController, forLanguageCode langCode: String) -> Coordinator? {
        guard let card = self.card else { return nil }
        return EditCardCoordinator(
            collectionReference: cardCollectionReference,
            navigationController: root,
            userID: userID,
            mode: .newLocalization(card: card, localizationLanguageCode: langCode)
        )
    }

    func editCardCoordinator(for indexPath: IndexPath, root: AppNavigationController) -> Coordinator? {
        guard let card = self.card else { return nil }
        return EditCardCoordinator(
            collectionReference: cardCollectionReference,
            navigationController: root,
            userID: userID,
            mode: .editLocalization(card: card, localizationID: dataModels[indexPath.row].id)
        )
    }

    func newLocalizationLanguageVM() -> LanguagesVM {
        LanguagesVM(mode: .newLocalization, blacklistedCodes: blacklistedLanguageCodes())
    }

    func languagesVM(for indexPath: IndexPath) -> LanguagesVM? {
        guard let localization = card?.localization(withID: dataModels[indexPath.row].id) else { return nil }
        return LanguagesVM(mode: .editLocalization(id: localization.id, selectedLanguageCode: localization.languageCode), blacklistedCodes: blacklistedLanguageCodes())
    }

    func setLanguage(code: String, cardVersionID: UUID) {
        guard let card = self.card else { return }
        guard !card.localizations.contains(where: { $0.languageCode == code }) else { return }
        let editableCard = card.editPersonalBusinessCardLocalizationMC(userID: userID, editedLocalizationID: cardVersionID)
        editableCard.editedLocalization.languageCode = code
        editableCard.save(in: cardCollectionReference)
    }

    func setDefaultLocalization(at indexPath: IndexPath) {
        guard let card = self.card else { return }
        let editableCard = card.editPersonalBusinessCardMC(userID: userID)
        editableCard.setDefaultLocalization(toID: dataModels[indexPath.row].id)
        editableCard.save(in: cardCollectionReference)
    }

    func deleteLocalization(at indexPath: IndexPath) {
        if dataModels.count >= 2 {
            guard let editableCard = card?.editPersonalBusinessCardMC(userID: userID) else { return }
            editableCard.deleteLocalization(withID: dataModels[indexPath.row].id)
            editableCard.save(in: cardCollectionReference)
        } else {
            deleteCard()
        }
    }

    func pushChangesToExchanges() {
        guard let exchangeIDs = user?.committedExchanges(for: cardID) else { return }

        delegate?.presentLoadingAlert(title: NSLocalizedString("Pushing Changes", comment: ""))

        var ownerExchangeIDs = [DirectCardExchangeID]()
        var guestExchangeIDs = [DirectCardExchangeID]()

        var encounteredError: Error?

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()

        directCardExchangeReference
            .whereField(DirectCardExchange.CodingKeys.ownerID.rawValue, isEqualTo: userID)
            .getDocuments(source: .server) { querySnapshot, error in

                guard let snapshots = querySnapshot else {
                    print(#file, error?.localizedDescription ?? "")
                    encounteredError = error
                    dispatchGroup.leave()
                    return
                }

                ownerExchangeIDs = snapshots.documents.map(\.documentID)
                dispatchGroup.leave()
            }

        directCardExchangeReference
            .whereField(DirectCardExchange.CodingKeys.guestID.rawValue, isEqualTo: userID)
            .getDocuments(source: .server) { querySnapshot, error in

                guard let snapshots = querySnapshot else {
                    print(#file, error?.localizedDescription ?? "")
                    encounteredError = error
                    dispatchGroup.leave()
                    return
                }

                guestExchangeIDs = snapshots.documents.map(\.documentID)
                dispatchGroup.leave()
            }

        dispatchGroup.notify(queue: .main) {
            if encounteredError != nil {
                let message = NSLocalizedString("We could not push your changes. Please check your network connection and try again.", comment: "")
                self.delegate?.presentErrorAlert(message: message)
            } else {
                let exchangeWithCurrentCard =  (ownerExchangeIDs + guestExchangeIDs).filter { exchangeIDs.contains($0) }
                self.updateAllExchanges(ids: exchangeWithCurrentCard)
            }
        }
    }

    private func blacklistedLanguageCodes() -> [String] {
        card?.localizations.compactMap { ($0.languageCode ?? "").isEmpty ? nil : $0.languageCode } ?? []
    }

    private func deleteCard() {
        guard let editableCard = card?.editPersonalBusinessCardMC(userID: userID) else { return }
        delegate?.presentLoadingAlert(title: NSLocalizedString("Deleting Card", comment: ""))

        var encounteredError: Error?

        editableCard.delete(in: cardCollectionReference) { result in
            switch result {
            case .success: return
            case .failure(let error):
                encounteredError = error
                print(#file, "Failure deleting card", error.localizedDescription)
            }
        }

        // give firebase some time to return an error if something is very wrong
        // otherwise data will be stored in cache if offline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if encounteredError != nil {
                let errorMessage = NSLocalizedString("We could not delete the card. Please check your internet connection and try again.", comment: "")
                self?.delegate?.presentErrorAlert(message: errorMessage)
            } else {
                self?.delegate?.popSelf()
            }
        }
    }

    private func cellDataModel(for localization: BusinessCardLocalization) -> DataModel {
        DataModel(
            id: localization.id,
            title: cellTitle(forCardLanguageCode: localization.languageCode),
            isDefault: localization.isDefault,
            sceneDataModel: CardFrontBackView.URLDataModel(
                frontImageURL: localization.frontImage.url,
                backImageURL: localization.backImage.url,
                textureImageURL: localization.texture.image.url,
                normal: CGFloat(localization.texture.normal),
                specular: CGFloat(localization.texture.specular),
                cornerRadiusHeightMultiplier: CGFloat(localization.cornerRadiusHeightMultiplier)
            )
        )
    }

    private func cellTitle(forCardLanguageCode langCode: String?) -> String {
        if let code = langCode {
            return currentLocale.localizedString(forLanguageCode: code) ?? NSLocalizedString("Language unspecified", comment: "")
        } else {
            return NSLocalizedString("Language unspecified", comment: "")
        }
    }
}

// MARK: - Firebase

extension PersonalCardLocalizationsVM {
    private var cardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(PersonalBusinessCard.collectionName)
    }

    private var directCardExchangeReference: CollectionReference {
        db.collection(DirectCardExchange.collectionName)
    }

    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching personal card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        DispatchQueue.global().async { [self] in
            guard let card = PersonalBusinessCardMC(documentSnapshot: doc) else {
                print(#file, "Error mapping personal card:", error?.localizedDescription ?? "No error info available.")
                DispatchQueue.main.async {
                    self.card = nil
                    self.delegate?.refreshData()
                }
                return
            }
            let dataModels = card.localizations
                .map { cellDataModel(for: $0) }
                .sorted {
                    if $0.isDefault || $1.isDefault {
                        return $0.isDefault
                    }
                    return $0.title < $1.title
                }
            DispatchQueue.main.async {
                self.card = card
                self.dataModels = dataModels
                self.delegate?.refreshData()
            }
        }
    }

    private func updateAllExchanges(ids: [DirectCardExchangeID]) {
        let exchangeReferences = ids.map { directCardExchangeReference.document($0) }

        Self.sharedDataBase.runTransaction { [weak self] transaction, errorPointer in
            guard let self = self, let card = self.card else { return nil }
            let exchanges: [DirectCardExchangeMC]
            do {
                exchanges = try exchangeReferences.map {
                    let exchangeDocumentSnap = try transaction.getDocument($0)
                    return try DirectCardExchangeMC(unwrappedWithExchangeDocument: exchangeDocumentSnap)
                }
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            exchanges.forEach { exchange in
                if exchange.ownerID == self.userID {
                    exchange.ownerCardLocalizations = card.localizations
                    exchange.ownerMostRecentUpdate = Date()
                    exchange.save(in: self.directCardExchangeReference)
                } else {
                    exchange.guestCardLocalizations = card.localizations
                    exchange.guestMostRecentUpdate = Date()
                    exchange.save(in: self.directCardExchangeReference)
                }
            }

            exchanges.enumerated().forEach { idx, exchange in
                transaction.setData(exchange.asDocument(), forDocument: exchangeReferences[idx])
            }
            return nil
        } completion: { [weak self] _, error in
            if let err = error {
                print(#file, err.localizedDescription)
                let message = NSLocalizedString("We could not push your changes. Please check your network connection and try again.", comment: "")
                self?.delegate?.presentErrorAlert(message: message)
            } else {
                self?.delegate?.dismissAlert()
            }
        }
    }
}

extension PersonalCardLocalizationsVM {
    struct ActionConfiguration {
        let title: String
        let deleteActionTitle: String
        let isDefault: Bool
    }
}

// MARK: - Section

extension PersonalCardLocalizationsVM {
    enum Section {
        case main
    }
}
