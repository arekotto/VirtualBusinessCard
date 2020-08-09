//
//  NavigationTitleView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class NavigationTitleView: AppView {

    private let titleLabel: UILabel = {
        let this = UILabel()
        this.font = .appDefault(size: 17, weight: .semibold)
        this.textAlignment = .center
        return this
    }()

    private let subtitleLabel: UILabel = {
        let this = UILabel()
        this.font = .appDefault(size: 13)
        this.textAlignment = .center
        return this
    }()

    private lazy var stackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel])
        this.axis = .vertical
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        addSubview(stackView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        stackView.constrainToEdgesOfSuperview()
    }

    func setTitle(_ title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
