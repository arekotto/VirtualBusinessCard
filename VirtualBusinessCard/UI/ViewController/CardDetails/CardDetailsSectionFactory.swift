//
//  CardDetailsSectionFactory.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Contacts

protocol CardDetailsSectionFactory {
    typealias Section = CardDetailsVM.Section
    typealias Item = CardDetailsVM.Item
    typealias Action = CardDetailsVM.Action

    func makeSections() -> [Section]
}

extension CardDetailsSectionFactory {
    static func formatAddress(_ addressData: BusinessCardLocalization.Address) -> String {
        let address = CNMutablePostalAddress()
        address.street = addressData.street ?? ""
        address.city = addressData.city ?? ""
        address.country = addressData.country ?? ""
        address.postalCode = addressData.postCode ?? ""

        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }

    static func fullDisplayName(_ name: BusinessCardLocalization.Name) -> String {
        [name.prefix, name.first, name.middle, name.last]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

struct ReceivedCardDetailsSectionFactory: CardDetailsSectionFactory {

    let card: ReceivedBusinessCardMC
    let tags: [BusinessCardTagMC]
    let isUpdateAvailable: Bool

    var imageProvider: (_ action: Action) -> UIImage?
    
    func makeSections() -> [Section] {
        let sections: [Section?] = [
            makeCardImagesSection(),
            makeUpdateSection(),
            makeTagsSection(),
            makeNotesSection(),
            makeMetaSection(),
            makePersonalDataSection(),
            makeContactSection(),
            makeAddressSection(),
            makeDeleteSection()
        ]
        return sections.compactMap { $0 }
    }

    private func makeMetaSection() -> Section? {
        let dataModel = TitleValueCollectionCell.DataModel(title: NSLocalizedString("Date Received", comment: ""), value: card.receivingDataFormatted)
        return Section(type: .meta, item: Item(itemNumber: 0, dataModel: .dataCell(dataModel), actions: [.copy]))
    }

    private func makeUpdateSection() -> Section? {
        isUpdateAvailable ? Section(type: .update, item: Item(itemNumber: 0, dataModel: .updateCell, actions: [])) : nil
    }

    private func makeDeleteSection() -> Section? {
        Section(type: .delete, item: Item(itemNumber: 0, dataModel: .deleteCell, actions: []))
    }

    private func makeTagsSection() -> Section? {
        guard !tags.isEmpty else {
            return Section(type: .tags, item: Item(itemNumber: 0, dataModel: .noTagsCell, actions: []))
        }
        let dataModels = tags.map {
            CardDetailsView.TagCell.DataModel(tagID: $0.id, title: $0.title, tagColor: $0.displayColor)
        }

        return Section(type: .tags, items: dataModels.enumerated().map { idx, dm in
            Item(itemNumber: idx, dataModel: .tagCell(dm), actions: [.editTags])
        })
    }

    private func makeCardImagesSection() -> Section? {
        let localization = card.displayedLocalization
        let imagesDataModel = CardFrontBackView.URLDataModel(
            frontImageURL: localization.frontImage.url,
            backImageURL: localization.backImage.url,
            textureImageURL: localization.texture.image.url,
            normal: CGFloat(localization.texture.normal),
            specular: CGFloat(localization.texture.specular),
            cornerRadiusHeightMultiplier: CGFloat(localization.cornerRadiusHeightMultiplier)
        )
        return Section(type: .card, item: Item(itemNumber: 0, dataModel: .cardImagesCell(imagesDataModel), actions: []))
    }

    private func makeNotesSection() -> Section? {

        let hasNotes = !card.notes.isEmpty
        let notesItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Notes", comment: ""),
            value: hasNotes ? card.notes : NSLocalizedString("No notes.", comment: ""),
            primaryImage: imageProvider(.editNotes)
        )

        let editableData: [(dataModel: TitleValueImageCollectionViewCell.DataModel, actions: [Action])] = [
            (notesItem, hasNotes ? [.copy, .editNotes] : [.editNotes])
        ]

        return Section(type: .notes, items: editableData.enumerated().map { index, dm in
            Item(itemNumber: index, dataModel: .dataCellImage(dm.dataModel), actions: dm.actions)
        })
    }
    
    private func makePersonalDataSection() -> Section? {
        let personalData = [
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Name", comment: ""), value: card.ownerDisplayName),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Position", comment: ""), value: card.displayedLocalization.position.title),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Company", comment: ""), value: card.displayedLocalization.position.company)
        ]
        
        let includedPersonalDataRows = personalData.filter { $0.value ?? "" != "" }
        if includedPersonalDataRows.isEmpty {
            return nil
        }
        return Section(type: .personalData, items: includedPersonalDataRows.enumerated().map { index, dm in
            Item(itemNumber: index, dataModel: .dataCell(dm), actions: [.copy])
        })
    }
    
    private func makeContactSection() -> Section? {
        let localization = card.displayedLocalization
        
        let phoneItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone", comment: ""),
            value: localization.contact.phoneNumberPrimary,
            primaryImage: imageProvider(.call)
        )
        
        let phoneSecondaryItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone Secondary", comment: ""),
            value: localization.contact.phoneNumberSecondary,
            primaryImage: imageProvider(.call)
        )
        
        let emailItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Email", comment: ""),
            value: localization.contact.email,
            primaryImage: imageProvider(.sendEmail)
        )
        
        let websiteItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Website", comment: ""),
            value: localization.contact.website,
            primaryImage: imageProvider(.visitWebsite)
        )
        
        let faxItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Fax", comment: ""),
            value: localization.contact.fax,
            primaryImage: nil
        )
        
        let contactData: [(dataModel: TitleValueImageCollectionViewCell.DataModel, actions: [Action])] = [
            (phoneItem, [.copy, .call]),
            (phoneSecondaryItem, [.copy, .call]),
            (emailItem, [.copy, .sendEmail]),
            (websiteItem, [.copy, .visitWebsite]),
            (faxItem, [.copy])
        ]
        
        let includedContactDataRows = contactData.filter { $0.dataModel.value ?? "" != "" }
        if includedContactDataRows.isEmpty {
            return nil
        }
        
        return Section(type: .contact, items: includedContactDataRows.enumerated().map { index, dm in
            Item(itemNumber: index, dataModel: .dataCellImage(dm.dataModel), actions: dm.actions)
        })
    }
    
    private func makeAddressSection() -> Section? {
        let address = card.addressFormatted
        if address == "" {
            return nil
        }
        let dm = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Address", comment: ""),
            value: address,
            primaryImage: imageProvider(.navigate)
        )
        return Section(type: .address, item: Item(itemNumber: 0, dataModel: .dataCellImage(dm), actions: [.copy, .navigate]))
    }
}

struct PersonalCardDetailsSectionFactory: CardDetailsSectionFactory {

    let card: BusinessCardLocalization

    var imageProvider: (_ action: Action) -> UIImage?

    func makeSections() -> [Section] {
        let sections: [Section?] = [
            makeCardImagesSection(),
            makePersonalDataSection(),
            makeContactSection(),
            makeAddressSection()
//            makeDeleteSection()
        ]
        return sections.compactMap { $0 }
    }

    private func makeDeleteSection() -> Section? {
        Section(type: .delete, item: Item(itemNumber: 0, dataModel: .deleteCell, actions: []))
    }

    private func makeCardImagesSection() -> Section? {
        let localization = card
        let imagesDataModel = CardFrontBackView.URLDataModel(
            frontImageURL: localization.frontImage.url,
            backImageURL: localization.backImage.url,
            textureImageURL: localization.texture.image.url,
            normal: CGFloat(localization.texture.normal),
            specular: CGFloat(localization.texture.specular),
            cornerRadiusHeightMultiplier: CGFloat(localization.cornerRadiusHeightMultiplier)
        )
        return Section(type: .card, item: Item(itemNumber: 0, dataModel: .cardImagesCell(imagesDataModel), actions: []))
    }

    private func makePersonalDataSection() -> Section? {
        let personalData = [
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Name", comment: ""), value: Self.fullDisplayName(card.name)),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Position", comment: ""), value: card.position.title),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Company", comment: ""), value: card.position.company)
        ]

        let includedPersonalDataRows = personalData.filter { $0.value ?? "" != "" }
        if includedPersonalDataRows.isEmpty {
            return nil
        }
        return Section(type: .personalData, items: includedPersonalDataRows.enumerated().map { index, dm in
            Item(itemNumber: index, dataModel: .dataCell(dm), actions: [.copy])
        })
    }

    private func makeContactSection() -> Section? {
        let localization = card

        let phoneItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone", comment: ""),
            value: localization.contact.phoneNumberPrimary,
            primaryImage: imageProvider(.call)
        )

        let phoneSecondaryItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone Secondary", comment: ""),
            value: localization.contact.phoneNumberSecondary,
            primaryImage: imageProvider(.call)
        )

        let emailItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Email", comment: ""),
            value: localization.contact.email,
            primaryImage: imageProvider(.sendEmail)
        )

        let websiteItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Website", comment: ""),
            value: localization.contact.website,
            primaryImage: imageProvider(.visitWebsite)
        )

        let faxItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Fax", comment: ""),
            value: localization.contact.fax,
            primaryImage: nil
        )

        let contactData: [(dataModel: TitleValueImageCollectionViewCell.DataModel, actions: [Action])] = [
            (phoneItem, [.copy, .call]),
            (phoneSecondaryItem, [.copy, .call]),
            (emailItem, [.copy, .sendEmail]),
            (websiteItem, [.copy, .visitWebsite]),
            (faxItem, [.copy])
        ]

        let includedContactDataRows = contactData.filter { $0.dataModel.value ?? "" != "" }
        if includedContactDataRows.isEmpty {
            return nil
        }

        return Section(type: .contact, items: includedContactDataRows.enumerated().map { index, dm in
            Item(itemNumber: index, dataModel: .dataCellImage(dm.dataModel), actions: dm.actions)
        })
    }

    private func makeAddressSection() -> Section? {

        let address = Self.formatAddress(card.address)
        if address == "" {
            return nil
        }
        let dm = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Address", comment: ""),
            value: address,
            primaryImage: imageProvider(.navigate)
        )
        return Section(type: .address, item: Item(itemNumber: 0, dataModel: .dataCellImage(dm), actions: [.copy, .navigate]))
    }
}
