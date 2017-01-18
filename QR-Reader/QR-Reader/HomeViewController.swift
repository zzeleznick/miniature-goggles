//
//  HomeViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: BaseViewController, fromModalDelegate, pusherDelegate {
    
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
    
    typealias voidCompletion = (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        registerFBListeners() {
            print("First registry")
        }
        placeElements()
    }
    
    func registerFBListeners(_ idx: String = "0", completion: voidCompletion = nil) {
        print("Register FB for room \(idx)")
        // MARK - MAKE RF DATABASE
        if orderRef != nil && _refHandle != nil {
            orderRef!.removeObserver(withHandle: _refHandle)
        }
        orderRef = ref.child(idx)
        _refHandle = orderRef.observe(.value, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            print("Refhandle activated")
            guard let obj = snapshot.value as? [String:Any] else {
                print("Received malformed data \(snapshot)")
                return
            }
            guard let bill = Bill(obj) else {
                print("Received malformed data \(obj)")
                return
            }
            print(obj, bill, bill.items.count)
            strongSelf.fireBill = bill
            if strongSelf.forwardDelegate != nil {
                myBill = bill
                strongSelf.forwardDelegate.refresh()
            }
            if completion != nil {
                completion!()
            }
        })
    }
    deinit {
        orderRef?.removeObserver(withHandle: _refHandle)
    }
    func pushFBV(key: String, value: Any) {
        self.orderRef.child(key).setValue(value)
        // ref.runTransactionBlock ?
    }
    func multiPushFBV(dict: [String: Any]) {
        print("Running multipush: \(dict)")
        self.orderRef.updateChildValues(dict)
    }
    func fromModal() {
        print("from scanning modal")
        let dict = convertToDictionary(text: resultText)
        print("Raw Dict: \(dict)")
        if dict != nil {
            myBill = Bill(dict!)
            myRoomID = myBill.roomID
            if myRoomID != nil {
                registerFBListeners(myRoomID!) {
                    print("Listening from scan")
                }
            }
            print("Bill: \(myBill)")
        } else {
            myBill = nil
        }
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
    func roomNotFound() {
        let ac = UIAlertController(title: "Bill not found", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Done", style: .default,
                                   handler: nil))
        present(ac, animated: true)
    }
    func optimisticFetch(roomID: String! = nil, completion: voidCompletion = nil) {
        print("Opt fetch with ID: \(roomID)")
        if roomID != nil {
            registerFBListeners(roomID!) {
                self.linkAndPresentRoom()
            }
            return
        }
        linkAndPresentRoom()
    }
    func linkAndPresentRoom() {
        myBill = fireBill
        let current = navigationController?.visibleViewController
        if current is ResultViewController {
            print("Already present")
        } else {
            let dest = ResultViewController()
            self.forwardDelegate = dest
            dest.pusherDelegateRef = self
            show(dest, sender: self)
        }
    }
    func fetchRoom(action: UIAlertAction!) {
        print("Room ID: \(roomIDField.text)")
        resultText = dummyText
        guard let text = roomIDField.text else {
            roomNotFound()
            return
        }
        myRoomID = text
        if text.isEmpty {
            myRoomID = "Dummy"
            fromModal()
        }
        else if text.characters.count < 6 {
            myRoomID = "0"
            linkAndPresentRoom()
        }
        else {
            optimisticFetch(roomID: text) {
                print("In completion after opt fetch")
            }
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
