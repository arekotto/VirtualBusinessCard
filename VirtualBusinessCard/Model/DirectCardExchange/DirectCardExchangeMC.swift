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
    
    var sharingUserID: UserID { exchange.sharingUserID }
    var sharingUserCardData: BusinessCardData { exchange.sharingUserCardData }
    
    var receivingUserID: UserID? {
        get { exchange.receivingUserID }
        set { exchange.receivingUserID = newValue }
    }

    var receivingUserCardID: BusinessCardID? {
        get { exchange.receivingUserCardID }
        set { exchange.receivingUserCardID = newValue }
    }
    
    var receivingUserCardData: BusinessCardData? {
        get { exchange.receivingUserCardData }
        set { exchange.receivingUserCardData = newValue }
    }
    
    init(exchange: DirectCardExchange) {
        self.exchange = exchange
    }
}

// MARK: - Saving

extension DirectCardExchangeMC {
    
    func saveScanningUserData(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        var updateDict: [AnyHashable: Any] = [:]
        updateDict[DirectCardExchange.CodingKeys.receivingUserID.rawValue] = exchange.receivingUserID ?? nil
        updateDict[DirectCardExchange.CodingKeys.receivingUserCardData.rawValue] = exchange.receivingUserCardData?.asDocument() ?? nil
        updateDict[DirectCardExchange.CodingKeys.receivingUserCardID.rawValue] = exchange.receivingUserCardID ?? nil
        collectionReference.document(exchange.id).updateData(updateDict) { error in
            if let err = error {
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
}

extension DirectCardExchangeMC {
    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let exchange = DirectCardExchange(documentSnapshot: userPublicDocument) else { return nil }
        self.init(exchange: exchange)
    }
}

extension DirectCardExchangeMC: Equatable {
    static func == (lhs: DirectCardExchangeMC, rhs: DirectCardExchangeMC) -> Bool {
        lhs.exchange == rhs.exchange
    }
}
