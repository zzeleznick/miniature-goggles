//
//  ResultViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

class ResultViewController: BaseViewController, refreshDelegate {
    lazy var topbar: UIView = {
        return UIView()
    }()
    lazy var backButton: UIButton = {
        return UIButton()
    }()
    lazy var payButton: UIButton = {
        return UIButton()
    }()
    lazy var bottomBar: UIView = {
        return UIView()
    }()
    lazy var messageLabel: UILabel = {
        return UILabel()
    }()
    var sentFromQR = false
    
    var pusherDelegateRef: pusherDelegate!
    
    var tableView: UITableView!
    let cellWrapper = CellWrapper(cell: RecordCell.self)
    typealias cellType = RecordCell
    let baseRowHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.title = "Bill"
        view.backgroundColor = UIColor.white
        placeElements()
    }
    func handlePayment(alertView: UIAlertAction!) {
        OperationQueue.main.addOperation { () -> Void in
            guard self.pusherDelegateRef != nil, myBill != nil else {return}
            var dict = [String: Any]()
            for item in myBill.items {
                if item.intent > 0 {
                    dict["\(item.name)/paid"] = item.intent + item.paid
                }
            }
            print("Finished building dict: \(dict)")
            self.pusherDelegateRef.multiPushFBV(dict: dict)
        }
    }
    func handleCancel(alertView: UIAlertAction!){
        print("Cancelled")
    }
    func dismissCurrentView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func payUp(_ sender: Any) {
        print("Pay up called")
        guard myBill != nil else { return }
        let text = "$\(myBill.myBalance.dollars)"
        let ac = UIAlertController(title: "Confirm Payment Amount", message: text, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go", style: .default,
                                   handler: handlePayment))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                   handler:handleCancel))
        present(ac, animated: true)
    }
    func refresh() {
        print("Refreshing")
        guard tableView != nil else {
            print("Table view not initialized yet")
            return
        }
        tableView.reloadData()
        guard myBill != nil else { return }
        messageLabel.text = "Total: $\(myBill.total.dollars) | Paid:  $\(myBill.balance.dollars)"
    }
    func showTable() {
        tableView.alpha = 1
        tableView.reloadData()
        bottomBar.alpha = 1
        messageLabel.text = "Total: $\(myBill.total.dollars) | Paid:  $\(myBill.balance.dollars)"
        messageLabel.alpha = 1
        view.bringSubview(toFront: bottomBar)
    }
    func papaParse() {
        print("parse time")
        if sentFromQR {
            print("Sent from qr")
        }
        if (tableView != nil && myBill != nil) {
            showTable()
        }
    }
    
    func placeElements() {
        let bottomFrame = CGRect(x: 0, y: self.h-50, width: self.w, height: 50)
        view.addUIElement(bottomBar, frame: bottomFrame) {
            element in
            guard let container = element as? UIView else {  return }
            container.backgroundColor = UIColor.black
            container.alpha = 0
        }
        let frame = CGRect(x: 0, y: 5, width: self.w, height: 40)
        bottomBar.addUIElement(messageLabel, text: "Total: $0", frame: frame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: "Helvetica-Bold", size: 16)
            label.textColor = UIColor.gray
            label.textAlignment = .center
            label.alpha = 0
        }
        let topFrame = CGRect(x: 0, y: 0, width: self.w, height: 60)
        view.addUIElement(topbar, frame: topFrame) {
            element in
            guard let container = element as? UIView else {  return }
            container.backgroundColor = UIColor.darkGray
        }
        let buttonFrame = CGRect(x: 4, y: 20, width: 100, height: 30)
        topbar.addUIElement(backButton, text: "Cancel", frame: buttonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(dismissCurrentView), for: .touchUpInside)
            button.setTitleColor(.white, for: .normal)
        }
        let payButtonFrame = CGRect(x: self.w-100, y: 20, width: 100, height: 30)
        topbar.addUIElement(payButton, text: "Pay", frame: payButtonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(payUp), for: .touchUpInside)
            button.setTitleColor(.white, for: .normal)
        }
        bindTable()
        papaParse()
    }
    func bindTable() {
        tableView = UITableView(frame: CGRect(x: 0, y: 60, width: w, height: h-100),
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var result : String {
            if myRoomID != nil {
                return "Bill \(myRoomID!)"
            }
            return "Example Bill"
        }
        return result
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if myBill != nil {
                let val = myBill!.items.count
                print("Rows <-> Item count: \(val)")
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
    
    func stepperValueChanged(sender: UIStepper) {
        print("stepper changed: \(sender.value)")
        guard myBill?.items != nil else {
            return
        }
       myBill?.items[sender.tag].intent = Int(sender.value)
       refresh()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellWrapper.identifier, for: indexPath) as! cellType
        
        cell.selectionStyle = .none
        // let section = (indexPath as NSIndexPath).section
        let idx = (indexPath as NSIndexPath).item
        guard let arr = myBill?.items else {
            return cell
        }
        if idx == 0 {
            print("Rows: \(arr)")
        }
        let order = arr[idx]
        let name = order.name
        let cost = order.cost
        let count = order.count
        let paid = order.paid
        let unpaid = order.count - order.paid
        let intent = order.intent
        let unitCost: Double = {
            if count >= 0 {
                return cost / Double(count)
            }
            return 0
        }()
        let pctPaid: String = {
            if cost > 0 {
                return ((unitCost * Double(paid)) / cost).pct
            }
            return "100%"
        }()
        cell.titleLabel.text = "\(name) ($\(unitCost.dollars) x \(count))"
        cell.subtitleLabel.text = "\(pctPaid) paid"
        
        cell.stepper.tag = idx
        cell.stepper.value = Double(intent)
        cell.stepperLabel.text = "Pay for \(intent)"
        cell.stepper.wraps = false
        cell.stepper.autorepeat = true
        cell.stepper.maximumValue = Double(unpaid)
        
        cell.stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)

        return cell
    }
    
}

