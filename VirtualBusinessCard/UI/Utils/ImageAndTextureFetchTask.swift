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
   
    let imageURLs: [URL]
    
    init(imageURLs: [URL]) {
        self.imageURLs = imageURLs
    }
    
    func callAsFunction(completion: @escaping (Result<[UIImage], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()

        imageURLs.forEach{ _ in dispatchGroup.enter() }

        var imagesDict = [Int: UIImage]()
        var error: Error?

        imageURLs.enumerated().forEach { idx, url in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult): imagesDict[idx] = imageResult.image
                case .failure(let err): error = err
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let err = error {
                completion(.failure(err))
            } else {
                let indexes = Array(0 ..< self.imageURLs.count)
                completion(.success(indexes.map{ imagesDict[$0]! }))
            }
        }
    }
    

}
