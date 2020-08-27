//
//  DirectCardExchangeMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Firebase

final class DirectCardExchangeMC {
    
    private var exchange: DirectCardExchange
    
    var id: DirectCardExchangeID { exchange.id }
    
    var accessToken: String { exchange.accessToken }
    
    var ownerID: UserID { exchange.ownerID }

    var ownerCardLocalizations: [BusinessCardLocalization] {
        get { exchange.ownerCardLocalizations }
        set { exchange.ownerCardLocalizations = newValue }
    }

    var ownerCardVersion: Int {
        get { exchange.ownerCardVersion }
        set { exchange.ownerCardVersion = newValue }
    }
    
    var guestID: UserID? {
        get { exchange.guestID }
        set { exchange.guestID = newValue }
    }

    var guestCardID: BusinessCardID? {
        get { exchange.guestCardID }
        set { exchange.guestCardID = newValue }
    }
    
    var guestCardLocalizations: [BusinessCardLocalization]? {
        get { exchange.guestCardLocalizations }
        set { exchange.guestCardLocalizations = newValue }
    }

    var guestCardVersion: Int {
        get { exchange.guestCardVersion }
        set { exchange.guestCardVersion = newValue }
    }

    func asDocument() -> [String: Any] {
        exchange.asDocument()
    }
    
    init(exchange: DirectCardExchange) {
        self.exchange = exchange
    }
}

// MARK: - Saving

extension DirectCardExchangeMC {

    func save(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        collectionReference.document(exchange.id).updateData(exchange.asDocument()) { error in
            if let err = error {
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
}

extension DirectCardExchangeMC {

    convenience init?(exchangeDocument: DocumentSnapshot) {
        guard let exchange = DirectCardExchange(documentSnapshot: exchangeDocument) else { return nil }
        self.init(exchange: exchange)
    }

    convenience init(unwrappedWithExchangeDocument exchangeDocument: DocumentSnapshot) throws {
        self.init(exchange: try DirectCardExchange(unwrappedWithDocumentSnapshot: exchangeDocument))
    }
}

extension DirectCardExchangeMC: Equatable {
    
    static func == (lhs: DirectCardExchangeMC, rhs: DirectCardExchangeMC) -> Bool {
        lhs.exchange == rhs.exchange
    }
}
