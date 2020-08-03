//
//  EditCardInfoSectionFactory.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

struct EditCardInfoSectionFactory {
    typealias Section = EditCardInfoVM.Section
    typealias Item = EditCardInfoVM.Item

    let cardData: BusinessCardData

    func makeRows() -> [Section] {
        return [
//            makeCardImagesSection()

        ]
    }

    func test () {
//        let imagesDataModel = CardFrontBackView.ImageDataModel(
//            frontImageURL: cardData.frontImage.url,
//            backImageURL: cardData.backImage.url,
//            textureImageURL: cardData.texture.image.url,
//            normal: CGFloat(cardData.texture.normal),
//            specular: CGFloat(cardData.texture.specular),
//            cornerRadiusHeightMultiplier: CGFloat(cardData.cornerRadiusHeightMultiplier)
//        )
    }

//    private func makeCardImagesSection() -> Section {
//        let cardData = card.cardData
//        let imagesDataModel = CardFrontBackView.ImageDataModel(
//            frontImageURL: cardData.frontImage.url,
//            backImageURL: cardData.backImage.url,
//            textureImageURL: cardData.texture.image.url,
//            normal: CGFloat(cardData.texture.normal),
//            specular: CGFloat(cardData.texture.specular),
//            cornerRadiusHeightMultiplier: CGFloat(cardData.cornerRadiusHeightMultiplier)
//        )
//        return Section(item: Item(dataModel: .cardImagesCell(imagesDataModel), actions: []))
//    }
}
