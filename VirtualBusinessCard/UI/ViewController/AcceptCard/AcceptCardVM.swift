//
//  AcceptCardVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol AcceptCardVMDelegate: class {
    func didFetchData(image: UIImage, texture: UIImage, normal: Double, specular: Double)
}

final class AcceptCardVM: AppViewModel {

    weak var delegate: AcceptCardVMDelegate?

    let card: ReceivedBusinessCardMC

    init(userID: UserID, sharedCard: ReceivedBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }

    func fetchData() {
        let texture = card.cardData.texture
        let task = ImageAndTextureFetchTask(imageURLs: [card.cardData.frontImage.url, texture.image.url])
        task() { [weak self] result in
            switch result {
            case .failure(let error):
                return
            case .success(let images):
                self?.delegate?.didFetchData(image: images[0], texture: images[1], normal: texture.normal, specular: texture.specular)
            }
        }
    }

}
