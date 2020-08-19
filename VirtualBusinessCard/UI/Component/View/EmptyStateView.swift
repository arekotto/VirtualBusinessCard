//
//  EmptyStateView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EmptyStateView: AppView {

    public init(title: String? = nil, subtitle: String? = nil, isHidden: Bool = false) {
        super.init()
        titleLabel.text = title
        subtitleLabel.text = subtitle
        self.isHidden = isHidden
    }

    required convenience init() {
        self.init(title: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let titleLabel: UILabel = {
        let this = UILabel()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.font = .appDefault(size: 26, weight: .semibold, design: .rounded)
        this.adjustsFontSizeToFitWidth = true
        this.textAlignment = .center
        this.textColor = .secondaryLabel
        return this
    }()

    let subtitleLabel: UILabel = {
        let this = UILabel()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.font = .appDefault(size: 17, weight: .medium)
        this.numberOfLines = 0
        this.textAlignment = .center
        this.textColor = .secondaryLabel
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        this.axis = .vertical
        this.spacing = 8
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        addSubview(mainStackView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        mainStackView.constrainToEdgesOfSuperview()
    }

}
