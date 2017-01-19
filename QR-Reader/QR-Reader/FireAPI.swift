//
//  FireAPI.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/18/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import Foundation
import Firebase

var ref = FIRDatabase.database().reference()
var orderRef: FIRDatabaseReference!
fileprivate var _refHandle: FIRDatabaseHandle!

public var firebaseAuthCredential: FIRAuthCredential!

func registerFBListeners(_ idx: String = "0", completion: singleCompletion = nil) {
    print("Register FB for room \(idx)")
    // MARK - MAKE RF DATABASE
    if orderRef != nil && _refHandle != nil {
        orderRef!.removeObserver(withHandle: _refHandle)
    }
    orderRef = ref.child(idx)
    _refHandle = orderRef.observe(.value, with: { (snapshot) -> Void in
        print("Refhandle activated")
        guard let obj = snapshot.value as? [String:Any] else {
            print("Received malformed data \(snapshot)")
            return
        }
        guard let bill = Bill(obj) else {
            print("Received malformed data \(obj)")
            return
        }
        print(obj, bill, bill.items.count)
        guard let completionBlock =  completion else { return }
        completionBlock(bill)
    })
}
