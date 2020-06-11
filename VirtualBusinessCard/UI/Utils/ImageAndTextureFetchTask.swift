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
   
    let imageURL: URL
    let textureURL: URL
    
    init(imageURL: URL, textureURL: URL) {
        self.imageURL = imageURL
        self.textureURL = textureURL
    }
    
    func callAsFunction(completion: @escaping (Result<ImagesResult, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var image: UIImage?
        var texture: UIImage?
        
        var error: Error?
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let imageResult): image = imageResult.image
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
                completion(.success(ImagesResult(image: image!, texture: texture!)))
            }
        }
    }
    
    struct ImagesResult {
        let image: UIImage
        let texture: UIImage
    }
}
