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

extension String {
    var firebaseString: String {
        let arrCharacterToReplace = [".","#","$","[","]"]
        var finalString = self
        for character in arrCharacterToReplace{
            finalString = finalString.replacingOccurrences(of: character, with: " ")
        }
        return finalString
    }
}

// your GCD queue
let queue = DispatchQueue(label: "queuename")


func registerFBListeners(_ idx: String = "0", completion: singleCompletion = nil, failedCompletion: voidCompletion = nil) {
    print("Register FB for room \(idx)")
    // MARK - MAKE RF DATABASE
    if orderRef != nil && _refHandle != nil {
        orderRef!.removeObserver(withHandle: _refHandle)
    }
    let safeIdx = idx.firebaseString
    if safeIdx != idx {
        print("Warning FB room \(idx) != \(safeIdx)")
    }
    var didObserve = false
    orderRef = ref.child(safeIdx)
    _refHandle = orderRef.observe(.value, with: { (snapshot) -> Void in
        print("Refhandle activated")
        didObserve = true
        guard let obj = snapshot.value as? [String:Any] else {
            print("Received malformed data \(snapshot)")
            if let callback = failedCompletion {
                callback()
            }
            return
        }
        guard let bill = Bill(obj) else {
            print("Received malformed data \(obj)")
            if let callback = failedCompletion {
                callback()
            }
            return
        }
        print(obj, bill, bill.items.count)
        guard let completionBlock =  completion else { return }
        completionBlock(bill)
    })
    let delaySeconds: Double = 5.0
    let delayTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delaySeconds * 1000.0))
    DispatchQueue.main.asyncAfter(deadline: delayTime)
    {
        print("Timeout")
        if !didObserve {
            print("Did not observe")
            if let callback = failedCompletion {
                callback()
            }
        } else {
            print("Did Observe")
        }
    }
    DispatchQueue.global(qos: .background).async { () -> Void in
        print("Background Dispatch")
        DispatchQueue.main.async {
            () -> Void in
                print("Inner Dispatch")
        }
    }
    
}
