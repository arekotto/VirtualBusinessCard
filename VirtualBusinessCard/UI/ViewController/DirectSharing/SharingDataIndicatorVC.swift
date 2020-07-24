//
//  SharingDataIndicatorVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 24/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit


final class SharingDataIndicatorVC: AppViewController<SharingDataIndicatorView, AppViewModel> {


}

final class SharingDataIndicatorView: AppView {

    private let activityIndicator: UIActivityIndicatorView = {
        let this = UIActivityIndicatorView(style: .large)
        this.startAnimating()
        return this
    }()

    private let effectView: UIView = {
        let this = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        this.clipsToBounds = true
        this.layer.cornerRadius = 20
        return this
    }()

    private let effectViewContainer: UIView = {
        let this = UIView()
        this.layer.shadowRadius = 80
        this.layer.shadowOpacity = 0.5
        this.layer.shadowPath = CGPath(rect: CGRect(x: -50, y: -50, width: 300, height: 300), transform: nil);
        return this
    }()

    override func configureView() {
        super.configureView()
        backgroundColor = .clear
    }

    override func configureSubviews() {
        super.configureSubviews()
        effectViewContainer.addSubview(effectView)
        [effectViewContainer, activityIndicator].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        effectView.constrainToEdgesOfSuperview()

        effectViewContainer.constrainHeight(constant: 200)
        effectViewContainer.constrainWidth(constant: 200)
        effectViewContainer.constrainCenterToSuperview()

        activityIndicator.constrainHeight(constant: 50)
        activityIndicator.constrainWidth(constant: 50)
        activityIndicator.constrainCenterToSuperview()
    }

    override func configureColors() {
        super.configureColors()
        activityIndicator.tintColor = .appAccent
    }
}
