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

    func configureView() { }

    func configureSubviews() { }

    func configureConstraints() { }
}

protocol Reusable: class {
    static var reuseId: String { get }
}

extension Reusable {
    static var reuseId: String {
        String(describing: self)
    }
}

class AppCollectionViewCell: UICollectionViewCell {
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView() { }

    func configureSubviews() { }

    func configureConstraints() { }
}
