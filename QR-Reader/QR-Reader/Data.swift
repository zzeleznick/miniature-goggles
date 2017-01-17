//
//  Data.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import Foundation

public var resultText: String = "" {
    didSet {
        if (resultText != oldValue) {
           print("Result Updated: \(resultText)")
        }
    }
}

public var myBill: Bill!

protocol fromModalDelegate {
    func fromModal()
}

protocol refreshDelegate {
    func refresh()
}

public var dummyText = "{\"items\": [\"pizza\", \"pasta\", \"wine\"],\"pizza\": {\"cost\": 12.60, \"count\": 3}, \"pasta\": {\"cost\": 8.40, \"count\": 1}, \"wine\": {\"cost\": 24.00, \"count\": 4}, \"total\":  45.00 }"

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

struct Order {
    var name: String
    var cost: Double
    var count: Int = 1
    var paid: Int = 0
}
public class Bill: CustomStringConvertible {
    struct Keys {
        static let _index = "items"
        static let Cost = "cost"
        static let Count = "count"
        static let Paid = "paid"
    }
    var items: [Order]!
    lazy var stringDesc: String = {
        if self.items != nil{
            let strArr = self.items.map {"\($0.name): $\($0.cost), \($0.paid) of \($0.count)"}
            return strArr.joined(separator: "; ")
        }
        return "<NULL>"
    }()
    public var description: String {
        return stringDesc
    }
    init?(_ dict: [String: Any]) {
        guard let keys = dict[Keys._index] as? [String] else {
            return
        }
        var items = [Order]()
        for key in keys {
            guard let datum = dict[key] as? [String: Double] else {
                return
            }
            var paid = 0
            if let _paid = datum[Keys.Paid]{
                paid = Int(_paid)
            }
            guard let cost = datum[Keys.Cost],
                let count = datum[Keys.Count] else {
                    return
            }
            let order = Order(name: key, cost: cost, count: Int(count), paid: paid)
            items.append(order)
        }
        self.items = items
    }
}
