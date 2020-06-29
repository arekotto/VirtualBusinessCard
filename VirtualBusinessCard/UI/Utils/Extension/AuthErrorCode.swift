//
//  AuthErrorCode.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

extension AuthErrorCode {
    var localizedMessageForUser: String {
        switch self {
        case .networkError:
             return NSLocalizedString("We're having connection issues. Make sure you're connected to the Internet.", comment: "")
        case .weakPassword:
            return NSLocalizedString("Your password needs to contain at least 6 characters.", comment: "")
        case .emailAlreadyInUse:
            return NSLocalizedString("This email has already been registered with a different account.", comment: "")
        case .invalidEmail:
            return NSLocalizedString("The email you provided is invalid.", comment: "")
        default:
            return AppError.localizedUnknownErrorDescription
        }
    }
}
