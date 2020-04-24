//
//  CardView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 17/04/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension DisplayVC {
    class CardView: UIView {
        lazy var imageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            return imageView
        }()
        
        let imageName: String
        
        init(imageName: String) {
            self.imageName = imageName
            super.init(frame: .zero)
            
            translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            layer.shadowOffset = CGSize(width: 4, height: 4)
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.6
            layer.shadowColor = UIColor.black.cgColor
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
