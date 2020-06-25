//
//  UITableView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UITableView {
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellReuseIdentifier: T.reuseId)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as! T
    }
}
