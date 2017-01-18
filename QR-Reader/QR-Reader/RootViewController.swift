//
//  RootViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/18/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import Firebase

class RootViewController: EZSwipeController {
    override func setupView() {
        datasource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        navigationBarShouldNotExist = true
    }
}

extension RootViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let redVC = HomeViewController()
        redVC.view.backgroundColor = .red
        
        let blueVC = ScanViewController()
        blueVC.view.backgroundColor = .blue
        
        return [redVC, blueVC]
    }
}

extension RootViewController: pusherDelegate  {
    func pushFBV(key: String, value: Any) {
        orderRef.child(key).setValue(value)
        // ref.runTransactionBlock ?
    }
    func multiPushFBV(dict: [String: Any]) {
        print("Running multipush: \(dict)")
        orderRef.updateChildValues(dict)
    }
}

