//
//  HomeViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: BaseViewController {

    lazy var headingLabel: UILabel = {
        return UILabel()
    }()
    lazy var enterButton: BetterButton = {
        return BetterButton()
    }()
    
    var lastOffset: CGPoint!
    var roomIDField: UITextField!
    // var fireBill: Bill!
    var forwardDelegate: refreshDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        registerFBListeners() {[weak self] (res) -> Void in
            print("First registry")
            guard let strongSelf = self else {return}
            strongSelf.FBclosure(res)
        }
        placeElements()
    }
    func FBclosure(_ res: Any?) {
        print("FBclosure")
        guard let bill = res as? Bill else { return }
        myBill = bill
        if self.forwardDelegate != nil {
            self.forwardDelegate.refresh()
        }
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
            registerFBListeners(roomID!) { [weak self] (res) -> Void in
                guard let strongSelf = self else {return}
                strongSelf.FBclosure(res)
            }
        }
        linkAndPresentRoom()
    }
    func linkAndPresentRoom() {
        // myBill = fireBill
        let current = navigationController?.visibleViewController
        if current is ResultViewController {
            print("Already present")
        } else {
            let dest = ResultViewController()
            self.forwardDelegate = dest
            dest.pusherDelegateRef = self
            // show(dest, sender: self)
            present(dest, animated: true) {
                print("Presenting")
            }
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
            linkAndPresentRoom()
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
        let enterButtonFrame = CGRect(x: self.w/2 - 100, y: 250, width: 200, height: 60)
        view.addUIElement(enterButton, text: "Enter ID", frame: enterButtonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
        }
        
    }
}
extension HomeViewController  {
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}

extension HomeViewController: fromModalDelegate, pusherDelegate  {
    func pushFBV(key: String, value: Any) {
        orderRef.child(key).setValue(value)
        // ref.runTransactionBlock ?
    }
    func multiPushFBV(dict: [String: Any]) {
        print("Running multipush: \(dict)")
        orderRef.updateChildValues(dict)
    }
    func fromModal() {
        print("from scanning modal")
    }
}
