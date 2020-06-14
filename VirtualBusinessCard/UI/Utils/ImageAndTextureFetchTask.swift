//
//  ImageAndTextureFetchTask.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Kingfisher

struct ImageAndTextureFetchTask {
   
    let frontImageURL: URL
    let textureURL: URL
    let backImageURL: URL?
    
    init(frontImageURL: URL, textureURL: URL, backImageURL: URL? = nil) {
        self.frontImageURL = frontImageURL
        self.textureURL = textureURL
        self.backImageURL = backImageURL
    }
    
    func callAsFunction(completion: @escaping (Result<ImagesResult, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()

        var frontImage: UIImage?
        var backImage: UIImage?
        var texture: UIImage?
        
        var error: Error?
        
        if let backImageURL = self.backImageURL {
            dispatchGroup.enter()
            KingfisherManager.shared.retrieveImage(with: backImageURL) { result in
                switch result {
                case .success(let imageResult): backImage = imageResult.image
                case .failure(let err): error = err
                }
                dispatchGroup.leave()
            }
        }
        
        KingfisherManager.shared.retrieveImage(with: frontImageURL) { result in
            switch result {
            case .success(let imageResult): frontImage = imageResult.image
            case .failure(let err): error = err
            }
            dispatchGroup.leave()
        }
        
        KingfisherManager.shared.retrieveImage(with: textureURL) { result in
            switch result {
            case .success(let imageResult): texture = imageResult.image
            case .failure(let err): error = err
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.success(ImagesResult(frontImage: frontImage!, texture: texture!, backImage: backImage)))
            }
        }
    }
    
    struct ImagesResult {
        let frontImage: UIImage
        let texture: UIImage
        let backImage: UIImage?
    }
}
