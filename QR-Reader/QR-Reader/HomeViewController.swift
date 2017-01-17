//
//  HomeViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: BaseViewController, fromModalDelegate {
    
    lazy var headingLabel: UILabel = {
        return UILabel()
    }()
    lazy var goButton: BetterButton = {
        return BetterButton()
    }()
    lazy var enterButton: BetterButton = {
        return BetterButton()
    }()
    
    var roomIDField: UITextField!
    var fireBill: Bill!
    var forwardDelegate: refreshDelegate!
    
    var ref = FIRDatabase.database().reference() // var ref: FIRDatabaseReference!
    var orderRef: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        registerFBListeners()
        placeElements()
    }
    
    func registerFBListeners() {
        print("Register FB")
        // MARK - MAKE RF DATABASE
        orderRef = ref.child("0")
        _refHandle = orderRef.observe(.value, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            // print(snapshot)
            guard let obj = snapshot.value as? [String:Any] else {
                print("Received malformed data \(snapshot)")
                return
            }
            guard let bill = Bill(obj) else {
                print("Received malformed data \(obj)")
                return
            }
            print(bill)
            strongSelf.fireBill = bill
            if strongSelf.forwardDelegate != nil {
                myBill = bill
                strongSelf.forwardDelegate.refresh()
            }
        })
    }
    deinit {
        orderRef?.removeObserver(withHandle: _refHandle)
    }
    func fromModal() {
        print("from modal")
        let dest = ResultViewController()
        dest.sentFromQR = true
        show(dest, sender: self)
    }
    func goButtonPressed(_ sender: Any) {
        print("go time")
        let dest = ScanViewController()
        dest.modalDelegate = self
        present(dest, animated: true, completion: nil)
    }
    func enterButtonPressed(_ sender: Any) {
        print("enter time")
        let ac = UIAlertController(title: "Enter Bill ID", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "123456"
            self.roomIDField = textfield
        })
        ac.addAction(UIAlertAction(title: "Go", style: .default,
                                   handler: fetchRoom))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                   handler:handleCancel))
        present(ac, animated: true)
    }
    func handleCancel(alertView: UIAlertAction!){
        print("Cancelled")
    }
    func fetchRoom(action: UIAlertAction!) {
        print("Room ID: \(roomIDField.text)")
        // let dict = convertToDictionary(text: dummyText)
        // print("Raw Dict: \(dict)")
        resultText = dummyText
        if roomIDField.text!.isEmpty {
            fromModal()
        }
        else if (roomIDField.text != nil) {
            myBill = fireBill
            let dest = ResultViewController()
            self.forwardDelegate = dest
            show(dest, sender: self)
        }
        else {
            let ac = UIAlertController(title: "Bill not found", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Done", style: .default,
                                       handler: nil))
            present(ac, animated: true)
        }
    }
    func placeElements() {
        let frame = CGRect(x: 0, y: 75, width: self.w, height: 75)
        view.addUIElement(headingLabel, text: "QR Reader", frame: frame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: "Helvetica-Bold", size: 32)
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
        }
        let buttonFrame = CGRect(x: self.w/2 - 100, y: 1*h/2, width: 200, height: 60)
        view.addUIElement(goButton, text: "Scan", frame: buttonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        }
        let enterButtonFrame = CGRect(x: self.w/2 - 100, y: buttonFrame.maxY + 50, width: 200, height: 60)
        view.addUIElement(enterButton, text: "Enter ID", frame: enterButtonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
        }
        
    }

    
}
