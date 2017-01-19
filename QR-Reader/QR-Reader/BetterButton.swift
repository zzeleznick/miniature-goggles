//
//  BetterButton.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

class BetterButton: UIButton {
    // MARK: Stores text content for later use
    var content: String = ""
    var baseColor = UIColor(rgb: 0x5584BA)
    var altColor = UIColor(rgb: 0x139FFF)
    
    convenience init(content: String? = "") {
        self.init(frame: .zero)
        self.content = content!
    }
    override init(frame: CGRect) {
        self.content = ""
        super.init(frame: frame)
        self.backgroundColor = baseColor
        self.layer.cornerRadius = 4
    }
    // MARK: Custom Button Behavior for Styling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let color = self.backgroundColor else { return }
        switch color {
        case baseColor:
            self.backgroundColor = self.altColor
        default:
            break
        }
        super.touchesBegan(touches, with: event)
    }
    // MARK: Custom Button Behavior for Styling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let color = self.backgroundColor else { return }
        switch color {
        case altColor:
            self.backgroundColor = baseColor
        default:
            break
        }
        super.touchesEnded(touches, with: event)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
