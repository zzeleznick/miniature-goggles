//: Playground - noun: a place where people can play

import UIKit

var str = "\"Hello, playground"

var text = "{\"items\": [\"pizza\", \"pasta\", \"wine\"],\"pizza\": {\"cost\": 12.60, \"count\": 3}, \"pasta\": {\"cost\": 8.40, \"count\": 1}, \"wine\": {\"cost\": 24.00, \"count\": 4}, \"total\":  45.00 }"

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

let dict = convertToDictionary(text: text)

struct Order {
    var name: String!
    var cost: Double!
    var count: Int!
}
class Bill: CustomStringConvertible {
    struct Keys {
        static let _index = "items"
        static let Cost = "cost"
        static let Count = "count"
    }
    var items: [Order]!
    lazy var stringDesc: String = {
        if self.items != nil{
            let strArr = self.items.map {"\($0.name!): $\($0.cost!), \($0.count!)"}
            return strArr.joined(separator: "; ")
        }
        return "<NULL>"
    }()
    var description: String {
        return stringDesc
    }
    init(dict: [String: Any]) {
        guard let keys = dict[Keys._index] as? [String] else {
            return
        }
        var items = [Order]()
        for key in keys {
            guard let datum = dict[key] as? [String: Double] else {
                return
            }
            guard let cost = datum[Keys.Cost],
                  let count = datum[Keys.Count] else {
                    return
            }
            let order = Order(name: key, cost: cost, count: Int(count))
            items.append(order)
        }
        self.items = items
    }
}

let bill = Bill(dict: dict!)
