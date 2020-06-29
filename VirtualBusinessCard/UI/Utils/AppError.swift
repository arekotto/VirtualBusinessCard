//
//  AppError.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

enum AppError: Error {
    case unknown
    
    static var localizedUnknownErrorDescription: String {
        NSLocalizedString("We have encountered an unknown error. Please try again later.", comment: "")
    }
}
