//
//  QRCodeGenerator.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 24/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

struct QRCodeGenerator {

    private(set) static var shared = Self()

    private init() {}

    func generate(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }
}
