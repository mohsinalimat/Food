//
//  LandingPage.swift
//  FoodAndBeverage
//
//  Created by Mehul Solanki on 03/05/18.
//  Copyright © 2018 MeHuLa. All rights reserved.
//

import UIKit
import AVFoundation

import FirebaseAuth
import FirebaseUI

class LandingPage: SuperViewController {

    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    /*
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]*/
    
    private let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                                      AVMetadataObjectTypeCode39Code,
                                      AVMetadataObjectTypeCode39Mod43Code,
                                      AVMetadataObjectTypeCode93Code,
                                      AVMetadataObjectTypeCode128Code,
                                      AVMetadataObjectTypeEAN8Code,
                                      AVMetadataObjectTypeEAN13Code,
                                      AVMetadataObjectTypeAztecCode,
                                      AVMetadataObjectTypePDF417Code,
                                      AVMetadataObjectTypeITF14Code,
                                      AVMetadataObjectTypeDataMatrixCode,
                                      AVMetadataObjectTypeInterleaved2of5Code,
                                      AVMetadataObjectTypeQRCode]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //Navigation Title
        self.navigationItem.title = "Scan Code"
        
        
        
        //Temp
        //Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(navigate(_:)), userInfo: nil, repeats: false)
        
        //If it is Simulator
        if UIDevice.isSimulator == true {
            //Temp
            let barTemp = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(LandingPage.navigateSkip))
            barTemp.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = barTemp
        }
        
        //Initialise Camera
        self.initialiseCamera()
        
        /*
        //Check is phone number is already stored, if not get it
        if let phone = UserDefaults.standard.value(forKey: "phoneNumber") {
            //Print Phone Number
            print("Phone Number : \(phone)")
            
            
        }else {
            //Not Available, get it
            let auth = FUIAuth.defaultAuthUI()
            auth?.delegate = self
            let phoneAuth = FUIPhoneAuth(authUI: auth!)
            auth?.providers = [phoneAuth]
            phoneAuth.signIn(withPresenting: self, phoneNumber: "")
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
        
        //Hide Back Button
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationItem.hidesBackButton = true
        
        //When user returns back to this screens, Camera should be running again
        if AppUtils.APPDELEGATE().strQRCodeValue == "" {
            //Do Nothing
        }else {
            self.captureSession.startRunning()
        }
    }
    
    func navigateSkip() -> Void {
        //QRCode Default Value
        //AppUtils.APPDELEGATE().strQRCodeValue = "KkPuRiWFfn"
        AppUtils.APPDELEGATE().strQRCodeValue = "1|4|1|1|1|2"
        
        //Navigate To Venue Details
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.VENUE_DETAIL) as! VenueDetail
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }
    
    func navigate() -> Void {
        //Navigate To Venue Details
        let viewCTR = Constants.StoryBoardFile.MAIN_STORYBOARD.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.VENUE_DETAIL) as! VenueDetail
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Initialise Camera
    func initialiseCamera() -> Void {
        //Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back)
        
        guard let captureDevice = deviceDiscoverySession?.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        }catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
}


//MARK: - QRCode Delegates
extension LandingPage: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No QR code is detected"
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //messageLabel.text = metadataObj.stringValue
                print("QRCode : \(metadataObj.stringValue)")
                
                self.captureSession.stopRunning()
                
                //Navigate to Next Screen
                //QRCode Default Value
                if let strQRCode = metadataObj.stringValue {
                    AppUtils.APPDELEGATE().strQRCodeValue = strQRCode
                    
                    self.navigate()
                }
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No QR code is detected"
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //messageLabel.text = metadataObj.stringValue
                print("QRCode : \(metadataObj.stringValue)")
            }
        }
    }
}


//MARK: - Firebase Delegates
extension LandingPage: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error == nil {
            //Success
            //print("Result : \(authDataResult?.additionalUserInfo?.providerID)") //Phone
            //print("Result : \(authDataResult?.additionalUserInfo?.isNewUser)") //False
            //print("Result : \(authDataResult?.user.phoneNumber)")
            //print("Result : \(authDataResult?.user.uid)")
            //print("Result : \(authDataResult?.user.providerID)") //Firebase
            
            //Get Mobile Number
            if let phoneNumber = authDataResult?.user.phoneNumber {
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                UserDefaults.standard.synchronize()
                
                //Register Customer
                self.registerCustomer(phoneNumber)
            }
            
        }else {
            //Fail
            print("Error : \(error?.localizedDescription)")
        }
        
        //Initialise Camera
        self.initialiseCamera()
    }
}


//MARK: - Web Services
extension LandingPage {
    //MARK: - Register Customer
    func registerCustomer(_ mobileNumber: String) -> Void {
        UserModel.registerUser(mobileNumber: mobileNumber, showLoader: true) { (isSuccess, response, error) in
            if isSuccess == true {
                //Get Data
                if let guid = response?.data as? String {
                    print("GUID : \(guid)")
                    
                    //Temp GUID stored
                    UserDefaults.standard.set("8f1eff0a-1b4b-48d4-a624-6426a56e6005", forKey: "guid")
                    UserDefaults.standard.synchronize()
                    
                    //Store GUID
                    AppUtils.APPDELEGATE().guid = "8f1eff0a-1b4b-48d4-a624-6426a56e6005"
                }
            }else {
            }
        }
    }
}
