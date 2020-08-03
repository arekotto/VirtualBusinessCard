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
    let tag: Int
    let forceRefresh: Bool

    init(imageURLs: [URL], tag: Int, forceRefresh: Bool = false) {
        self.imageURLs = imageURLs
        self.tag = tag
        self.forceRefresh = false
    }
    
    func callAsFunction(completion: @escaping (Result<[UIImage], Error>, Int) -> Void) {
        let dispatchGroup = DispatchGroup()

        imageURLs.forEach { _ in dispatchGroup.enter() }

        var imagesDict = [Int: UIImage]()
        var error: Error?

        imageURLs.enumerated().forEach { idx, url in
            let options: KingfisherOptionsInfo = forceRefresh ? [.forceRefresh] : []
            KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
                switch result {
                case .success(let imageResult): imagesDict[idx] = imageResult.image
                case .failure(let err): error = err
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let err = error {
                completion(.failure(err), tag)
            } else {
                let indexes = Array(0 ..< self.imageURLs.count)
                completion(.success(indexes.map { imagesDict[$0]! }), tag)
            }
        }
    }
}
