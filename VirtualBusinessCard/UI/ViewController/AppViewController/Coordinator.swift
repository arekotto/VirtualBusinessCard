//
//  Coordinator.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get }

    func start(completion: @escaping (Result<Void, Error>) -> Void)
}
