//
//  ViewExtension.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

extension UIView {
    
    func placeUIElement<T: UIView>(_ element: T, frame: CGRect) {
        element.frame = frame
        self.addSubview(element)
    }
    
    func addBorder<T: UIView>(_ myInput: T, height: CGFloat? = 1) {
        let border = CALayer()
        border.backgroundColor = UIColor(rgb: 0xCDCDCD).cgColor
        border.frame = CGRect(x:0, y:myInput.frame.size.height-(1.0 + height!),
                              width: myInput.frame.size.width, height: height!)
        myInput.layer.addSublayer(border)
    }
    
    func addUIElement<T: UIView>(_ element: T, text: String? = nil, frame: CGRect, onSuccess: (AnyObject)->() = {_ in } ){
        switch element {
        case let label as UILabel:
            label.text = text
            label.numberOfLines = 0
        case let field as UITextField:
            field.placeholder = text
        case let field as UITextView:
            field.text = text
        case let button as UIButton:
            button.setTitle(text, for: UIControlState())
        case let image as UIImageView:
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
        case _ as UICollectionView:
            break // pass
        case let container as UIVisualEffectView:
            container.effect =  UIBlurEffect(style: UIBlurEffectStyle.light)
        default:
            break // print("I don't know my type")
        }
        placeUIElement(element, frame: frame)
        onSuccess(element)
    }
}

class CellWrapper: NSObject {
    var cell: AnyObject
    var identifier = ""
    
    init(cell: AnyObject, identifier: String = "cell") {
        self.cell = cell
        self.identifier = identifier
    }
}

// protocol composition
typealias TableMaster = UITableViewDelegate & UITableViewDataSource

extension UITableView {
    convenience init(frame: CGRect,
                     controller: TableMaster, cellWrapper: CellWrapper) {
        self.init(frame: frame)
        self.delegate = controller
        self.dataSource = controller
        let tp = cellWrapper.cell.self
        self.register(tp.classForCoder,
                      forCellReuseIdentifier: cellWrapper.identifier)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.rowHeight = 80
    }
}


extension UIColor{
    convenience init(rgb: UInt, alphaVal: CGFloat? = 1.0) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal!)
        )
    }
}

extension UISwipeGestureRecognizerDirection: CustomStringConvertible {
    public var description: String {
        // print(self.rawValue)
        switch self.rawValue {
        case 1 << 0: return "Right"
        case 1 << 1: return "Left"
        case 1 << 2: return "Up"
        case 1 << 3: return "Down"
        default: return "Unknown"
        }
    }
}
