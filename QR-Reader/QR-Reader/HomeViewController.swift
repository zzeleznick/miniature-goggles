//
//  HomeViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        placeElements()
    }
    func fromModal() {
        print("from modal")
        let dest = ResultViewController()
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
        if true {
            let dest = ResultViewController()
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
        let buttonFrame = CGRect(x: self.w/2 - 100, y: 2*h/3, width: 200, height: 60)
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
