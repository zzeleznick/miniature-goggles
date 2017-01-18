//
//  BaseExtension.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/18/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import Foundation

extension Double {
    var dollars: String {
        return NSString(format: "%.2f", self) as String
    }
    var pct: String {
        let trunc = NSString(format: "%.2f", self).doubleValue * 100
        return "\(Int(trunc.rounded()))%"
    }
}

typealias voidCompletion = (() -> ())?

typealias singleCompletion = ((Any?) -> ())?
