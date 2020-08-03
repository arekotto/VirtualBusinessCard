//
//  EditCardInfoVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardInfoVMDelegate: class {

}

final class EditCardInfoVM: AppViewModel {

    weak var delegate: EditCardInfoVMDelegate?

//    private lazy var sections = EditCardInfoSectionFactory(card: self.card.personalBusinessCardMC()).makeRows()

    let card: EditPersonalBusinessCardMC

    init(businessCard: EditPersonalBusinessCardMC) {
        card = businessCard
    }
}

// MARK: - ViewController API

extension EditCardInfoVM {

    var title: String {
        NSLocalizedString("Card Info", comment: "")
    }

}

extension EditCardInfoVM {
    struct Section {

        var items: [Item]
        var title: String?

        init(items: [Item], title: String? = nil) {
            self.items = items
            self.title = title
        }

        init(item: Item, title: String? = nil) {
            self.items = [item]
            self.title = title
        }
    }

    struct Item {
        let dataModel: DataModel
    }

    enum DataModel {
        case dataCell(TitleValueCollectionCell.DataModel)
        case dataCellImage(TitleValueImageCollectionViewCell.DataModel)
        case cardImagesCell(CardFrontBackView.ImageDataModel)
    }
}
