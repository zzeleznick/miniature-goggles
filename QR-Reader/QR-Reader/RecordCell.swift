//
//  RecordCell.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let w = UIScreen.main.bounds.size.width
        contentView.addUIElement(titleLabel, frame: CGRect(x: 25, y: 12, width: w-25, height: 20))  {element in
            guard let label = element as? UILabel else { return }
            let font = UIFont(name: "Helvetica-Bold", size: 16)
            label.font = font
        }
        contentView.addUIElement(subtitleLabel, frame: CGRect(x: 25, y: 40, width: w-25, height: 20))  {element in
            guard let label = element as? UILabel else { return }
            let font = UIFont(name: "HelveticaNeue", size: 16)
            label.font = font
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
