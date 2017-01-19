//
//  HomeViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth
import FBSDKLoginKit

class HomeViewController: BaseViewController {

    lazy var headingLabel: UILabel = {
        return UILabel()
    }()
    lazy var subHeadingLabel: UILabel = {
        return UILabel()
    }()
    lazy var imageView: UIImageView = {
        return UIImageView()
    }()
    lazy var enterButton: BetterButton = {
        return BetterButton()
    }()
    lazy var loginButton: FBSDKLoginButton = {
        return FBSDKLoginButton()
    }()
    var bkImage: UIImage!
    var lastOffset: CGPoint!
    var roomIDField: UITextField!
    // var fireBill: Bill!
    var forwardDelegate: refreshDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        /*
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
        */
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 40.0,
            kTitleHeight: 40.0,
            kTitleFont: UIFont(name: Theme.fontName, size: 26)!,
            kTextFont: UIFont(name: Theme.fontLightName, size: 18)!,
            kButtonFont: UIFont(name: Theme.fontName, size: 22)!,
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let textfield = alert.addTextField("123456")
        alert.addButton("Go") {
            self.roomIDField = textfield
            print("Text value: \(textfield.text)")
            self.fetchRoom(action: nil)
        }
        alert.showEdit("Enter Bill ID", subTitle: "Please enter the bill id printed on your receipt",  duration: 10)

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
        let root = UIApplication.shared.keyWindow?.rootViewController
        guard let rootVC = root as? RootViewController else {
            print("Root VC improperly configured")
            return
        }
        if let _ = rootVC.currentStackVC as? ResultViewController {
            print("Result VC Already present")
        } else {
            let dest = ResultViewController()
            self.forwardDelegate = dest
            dest.pusherDelegateRef = rootVC
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
        let imageFrame = CGRect(x: 0, y: 0, width: self.w, height: self.h)
        view.addUIElement(imageView, frame: imageFrame) {
            element in
            guard let el = element as? UIImageView else {  return }
            el.image = #imageLiteral(resourceName: "ccapital-bk")
        }
        let frame = CGRect(x: 60, y: 75, width: self.w, height: 75)
        view.addUIElement(headingLabel, text: "CCapital", frame: frame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: Theme.fontBoldName, size: 54)
            label.textColor = UIColor.white
        }
        let subFrame = CGRect(x:60, y: 165, width: self.w, height: 75)
        view.addUIElement(subHeadingLabel, text: "Bill Pay", frame: subFrame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: Theme.fontLightName, size: 44)
            label.textColor = UIColor.white
        }
        let enterButtonFrame = CGRect(x: self.w/2 - 100, y: h-200, width: 200, height: 60)
        view.addUIElement(enterButton, text: "Bill ID", frame: enterButtonFrame) {
            element in
            guard let button = element as? UIButton else {  return }
            button.addTarget(self, action: #selector(enterButtonPressed), for: .touchUpInside)
            button.titleLabel?.font =  UIFont(name: Theme.fontName, size: 30)
        }
        let fbButtonFrame = CGRect(x: self.w/2 - 100, y: enterButtonFrame.minY - 80, width: 200, height: 60)
        view.addUIElement(loginButton, text: "Log", frame: fbButtonFrame) {
            element in
            guard let button = element as? FBSDKLoginButton else {  return }
            button.titleLabel?.font = UIFont(name: Theme.fontName, size: 30)
            button.delegate = UIApplication.shared.delegate as! FBSDKLoginButtonDelegate!
        }

    }
}


