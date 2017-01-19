//
//  ScanViewController.swift
//  QR-Reader
//
//  Created by Zach Zeleznick on 1/17/17.
//  Copyright © 2017 zzeleznick. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {
    lazy var bottomBar: UIView = {
        return UIView()
    }()
    lazy var messageLabel: UILabel = {
        return UILabel()
    }()
    var processing = false
    var resultShowing = false
    
    var modalDelegate: fromModalDelegate!
    var forwardDelegate: refreshDelegate!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeQRCode]
    
    func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Scanner will Appear")
        print(self.view.bounds, self.view.bounds.minY)
        processing = false
        resultShowing = false
    }
    func FBclosure(_ res: Any?) {
        print("Scanner FBclosure")
        self.removeAllOverlays()
        guard let bill = res as? Bill else { return }
        guard bill.items.count > 0 else {
            print("No items found for bill with id \(myRoomID)")
            processing = false
            return
        }
        myBill = bill
        if self.forwardDelegate != nil {
            print("Calling forward delegate")
            self.forwardDelegate.refresh()
        } else {
            print("Refresh delegate is nil")
        }
        if !resultShowing {
            self.linkAndPresentRoom()
        }
    }
    func scannerDidFindText(_ text: String) {
        print("Scanner found text \(text)")
        let dest = ResultViewController()
        dest.sentFromQR = true
        resultText = text
        let dict = convertToDictionary(text: resultText)
        print("Raw Dict: \(dict)")
        if dict != nil {
            myBill = Bill(dict!)
            print("Bill: \(myBill)")
            present(dest, animated: true, completion: nil)
        }
        else if text.characters.count != 6 {
            print("Not valid UID")
        }
        else {
            myRoomID = text
            if !processing {
                let displayText = "Please wait..."
                self.showWaitOverlayWithText(displayText)
                registerFBListeners(text, completion: { [weak self] (res) -> Void in
                    guard let strongSelf = self else {return}
                    strongSelf.FBclosure(res)
                }) {
                    [weak self] () -> Void in
                    guard let strongSelf = self else {return}
                    print("In failure completion")
                    strongSelf.removeAllOverlays()
                }
            }
            processing = true
        }
    }
    func getTopVC() -> UIViewController? {
        let root = UIApplication.shared.keyWindow?.rootViewController
        guard let rootVC = root as? RootViewController else {
            print("Root VC improperly configured")
            return nil
        }
        return rootVC.currentStackVC
    }
    func linkAndPresentRoom() {
        print("Going to link and present from scanner")
        let root = UIApplication.shared.keyWindow?.rootViewController
        guard let rootVC = root as? RootViewController else {
            print("Root VC improperly configured")
            return
        }
        let dest = ResultViewController()
        self.forwardDelegate = dest
        dest.pusherDelegateRef = rootVC
        present(dest, animated: true) {
            self.resultShowing = true
            print("Presenting")
        }
    }
    func placeElements() {
        let bottomFrame = CGRect(x: 0, y: self.h-50, width: self.w, height: 50)
        view.addUIElement(bottomBar, frame: bottomFrame) {
            element in
            guard let container = element as? UIView else {  return }
            container.backgroundColor = UIColor.black
            container.alpha = 0.9
        }
        print(bottomBar.frame)
        let frame = CGRect(x: 0, y: 5, width: self.w, height: 40)
        bottomBar.addUIElement(messageLabel, text: "No QR Code Found", frame: frame) {
            element in
            guard let label = element as? UILabel else {  return }
            label.font = UIFont(name: "Helvetica-Bold", size: 16)
            label.textColor = UIColor.gray
            label.textAlignment = .center
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add UI Elements
        placeElements()
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            // view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: bottomBar)
            
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/barcode is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let text = metadataObj.stringValue!
                messageLabel.text = text
                scannerDidFindText(text)
            }
        }
    }
    
}

