//
//  CardDetailsSectionFactory.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

struct CardDetailsSectionFactory {
        
    typealias Section = CardDetailsVM.Section
    typealias Item = CardDetailsVM.Item
    typealias Action = CardDetailsVM.Action

    let card: ReceivedBusinessCardMC
    var imageProvider: (_ action: Action) -> UIImage?
    
    func makeRows() -> [Section] {
        let sections: [Section?] = [
            makeCardImagesSection(),
            makePersonalDataSection(),
            makeContactSection(),
            makeAddressSection()
        ]
        return sections.compactMap { $0 }
    }
    
    private func makeCardImagesSection() -> Section? {
        let cardData = card.cardData
        let imagesDataModel = CardFrontBackView.DataModel(
            frontImageURL: cardData.frontImage.url,
            backImageURL: cardData.backImage.url,
            textureImageURL: cardData.texture.image.url,
            normal: CGFloat(cardData.texture.normal),
            specular: CGFloat(cardData.texture.specular)
        )
        
        return Section(items: [Item(dataModel: .cardImagesCell(imagesDataModel), actions: [.copy])])
    }
    
    private func makePersonalDataSection() -> Section? {
        let personalData = [
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Name", comment: ""), value: card.ownerDisplayName),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Position", comment: ""), value: card.cardData.position.title),
            TitleValueCollectionCell.DataModel(title: NSLocalizedString("Company", comment: ""), value: card.cardData.position.company)
        ]
        
        let includedPersonalDataRows = personalData.filter { $0.value ?? "" != "" }
        if includedPersonalDataRows.isEmpty {
            return nil
        }
        return Section(items: includedPersonalDataRows.map { Item(dataModel: .dataCell($0), actions: [.copy]) })
    }
    
    private func makeContactSection() -> Section? {
        let cardData = card.cardData
        
        let phoneItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone", comment: ""),
            value: cardData.contact.phoneNumberPrimary,
            primaryImage: imageProvider(.call)
        )
        
        let phoneSecondaryItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Phone Secondary", comment: ""),
            value: cardData.contact.phoneNumberSecondary,
            primaryImage: imageProvider(.call)
        )
        
        let emailItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Email", comment: ""),
            value: cardData.contact.email,
            primaryImage: imageProvider(.sendEmail)
        )
        
        let websiteItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Website", comment: ""),
            value: cardData.contact.website,
            primaryImage: imageProvider(.visitWebsite)
        )
        
        let faxItem = TitleValueImageCollectionViewCell.DataModel(
            title: NSLocalizedString("Fax", comment: ""),
            value: cardData.contact.fax,
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
        
        return Section(items: includedContactDataRows.map { Item(dataModel: .dataCellImage($0.dataModel), actions: $0.actions) })
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
        return Section(singleItem: Item(dataModel: .dataCellImage(dm), actions: [.copy, .navigate]))
    }
}
