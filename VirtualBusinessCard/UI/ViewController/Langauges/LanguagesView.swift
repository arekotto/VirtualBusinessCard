//
//  LanguagesView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

enum LanguagesView {

    final class TableCell: AppTableViewCell, Reusable {

        override func configureColors() {
            super.configureColors()
            tintColor = Asset.Colors.appAccent.color
        }
    }
}

extension LanguagesView.TableCell {
    
    struct DataModel: Hashable {
        let langCode: String
        let title: String
        let displayCheckmark: Bool
    }

    func setDataModel(_ dataModel: DataModel) {
        textLabel?.text = dataModel.title
        accessoryType = dataModel.displayCheckmark ? .checkmark : .none
    }
}
