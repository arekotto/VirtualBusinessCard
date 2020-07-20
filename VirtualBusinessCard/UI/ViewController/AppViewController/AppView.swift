//
//  AppView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class AppView: UIView {

    required init() {
        super.init(frame: .zero)
        configureView()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureColors()
    }

    func configureView() { }

    func configureSubviews() { }

    func configureConstraints() { }

    func configureColors() { }
}

