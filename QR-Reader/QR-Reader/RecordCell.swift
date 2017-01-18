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
    
    let stepperContainer = UIView()
    let stepper = UIStepper()
    let stepperLabel = UILabel()
    
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
        contentView.addUIElement(stepperContainer,
                                 frame: CGRect(x: w-120, y: 10, width: 120, height: 60))
        {element in
            guard let _ = element as? UIView else { return }
            // container.backgroundColor = .red
        }
        stepperContainer.addUIElement(stepper,
                            frame: CGRect(x: 12, y: 30, width: 100, height: 30))
            {element in
                guard let _ = element as? UIStepper else { return }
        }
        stepperContainer.addUIElement(stepperLabel, text: "0",
                                  frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        {element in
            guard let label = element as? UILabel else { return }
            label.textColor = .blue
            label.textAlignment = .center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
