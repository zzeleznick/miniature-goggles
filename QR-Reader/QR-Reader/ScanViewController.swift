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
    var modalDelegate: fromModalDelegate!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeQRCode]
    
    func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func scannerDidFindText(_ text: String) {
        print("Scanner found text \(text)")
        resultText = text
        let dict = convertToDictionary(text: resultText)
        print("Raw Dict: \(dict)")
        if dict != nil {
            myBill = Bill(dict!)
            myRoomID = myBill.roomID
            if myRoomID != nil {
                registerFBListeners(myRoomID!) { (_) -> Void in
                    print("Listening from scan")
                }
            }
            print("Bill: \(myBill)")
        } else {
            myBill = nil
        }
        let dest = ResultViewController()
        dest.sentFromQR = true
        present(dest, animated: true, completion: nil)
    }
    func placeElements() {
        let bottomFrame = CGRect(x: 0, y: self.h-90, width: self.w, height: 50)
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

