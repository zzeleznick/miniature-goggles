//
//  ResultViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

class ResultViewController: BaseViewController {

    lazy var headingLabel: UILabel = {
        return UILabel()
    }()
    lazy var goButton: BetterButton = {
        return BetterButton()
    }()
    
    var tableView: UITableView!
    let cellWrapper = CellWrapper(cell: RecordCell.self)
    typealias cellType = RecordCell
    let baseRowHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Results"
        view.backgroundColor = UIColor.white
        placeElements()
    }
    func papaParse() {
        print("parse time")
        let dict = convertToDictionary(text: resultText)
        print("Raw Dict: \(dict)")
        if dict != nil {
            myBill = Bill(dict!)
            print("Bill: \(myBill)")
            if tableView != nil {
                tableView.alpha = 1
                tableView.reloadData()
            }
        }
    }
    
    func placeElements() {
        let frame = CGRect(x: 0, y: 75, width: self.w, height: 300)
        let text = resultText
        view.addUIElement(headingLabel, text: text, frame: frame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: "Helvetica-Bold", size: 16)
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping
        } /*
        let buttonFrame = CGRect(x: self.w/2 - 100, y: 3*h/4, width: 200, height: 75)
        view.addUIElement(goButton, text: "Parse", frame: buttonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        } */
        bindTable()
        papaParse()
    }
    func bindTable() {
        tableView = UITableView(frame: CGRect(x: 0, y: 60, width: w, height: h-60),
                                controller: self, cellWrapper: cellWrapper)
        tableView.rowHeight = baseRowHeight
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.alpha = 0
        view.addSubview(tableView)
    }
    
}

extension ResultViewController: TableMaster {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // let section = (indexPath as NSIndexPath).section
        let idx = (indexPath as NSIndexPath).item
        let del = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            print("Remove this row: \(idx)")
            tableView.reloadData()
        }
        del.backgroundColor = UIColor.red
        return [del]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let val = myBill?.items.count {
                print("Item count: \(val)")
                return val
            } else {
                return 0
            }
        default:
            return 0
        }
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellWrapper.identifier, for: indexPath) as! cellType
        
        cell.selectionStyle = .none
        // let section = (indexPath as NSIndexPath).section
        let idx = (indexPath as NSIndexPath).item
        guard let arr = myBill?.items else {
            return cell
        }
        print("Array: \(arr)")
        let order = arr[idx]
        let name = order.name!
        cell.titleLabel.text = "\(name)"
        let cost = order.cost!
        let count = order.count!
        cell.subtitleLabel.text = "$\(cost)    \(count)"
        
        return cell
    }
    
}

