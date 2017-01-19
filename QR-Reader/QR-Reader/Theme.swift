//
//  Theme.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/19/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//
import UIKit

class BasicTheme {
    class var fontName: String {
        return "HelveticaNeue"
    }
    class var fontBoldName: String {
        return "HelveticaNeue-Bold"
    }
    class var titleSize: CGFloat {
        return 32.0
    }
    class var subtitleSize: CGFloat {
        return 24.0
    }
}

class Theme: BasicTheme {
    override class var fontName: String {
        return "Seravek"
    }
    override class var fontBoldName: String {
        return "Seravek-Medium"
    }
    class var fontLightName: String {
        return "Seravek-Light"
    }
}
