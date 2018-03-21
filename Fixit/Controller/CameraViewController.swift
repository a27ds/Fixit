//
//  CameraViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-08.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Firebase
import SVProgressHUD

class CameraViewController: UIViewController, CLLocationManagerDelegate, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Variabel Decalartions
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var gpsInfo: CLLocation?
    var date: Date?
    var showLocationDisablePopUpBool: Bool?
    var loginAlertIsHidden = true
    var infoAlertIsHidden = true
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var loginAlert: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loginAlertConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var infoAlert: UIView!
    @IBOutlet weak var okButtonInfoAlert: UIButton!
    @IBOutlet weak var infoAlertConstraint: NSLayoutConstraint!
    
    ///////////////////////////////////////////
    
   
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutCameraButton()
        setLayoutInfoAlert()
        setLayoutLoginAlert()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userDefaultCheck()
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIBarButtonItem) {
        showOrHideLoginAlert()
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        showOrHideInfoAlert()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        getLocation()
        date = Date()
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func loginAlertButtonPressed(_ sender: UIButton) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        // Login to firebase
        loginButton.isEnabled = false
        cancelButton.isEnabled = false
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: self.loginAlert.center.x - 10, y: self.loginAlert.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: self.loginAlert.center.x + 10, y: self.loginAlert.center.y))
                self.loginAlert.layer.add(animation, forKey: "position")
                SVProgressHUD.dismiss()
            } else {
                self.performSegue(withIdentifier: "showLogin_Segue", sender: self)
                self.showOrHideLoginAlert()
                SVProgressHUD.dismiss()
                
            }
        }
        loginButton.isEnabled = true
        cancelButton.isEnabled = true
    }
    
    @IBAction func cancelAlertButtonPressed(_ sender: UIButton) {
        showOrHideLoginAlert()
    }
    
    @IBAction func okInfoButtonPressed(_ sender: UIButton) {
        showOrHideInfoAlert()
    }
    
    
    ///////////////////////////////////////////
    
    // MARK: - Info Alert
    
    func userDefaultCheck() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTimeUse") == nil {
            print("körs")
            defaults.set(1, forKey: "isFirstTimeUse")
            defaults.synchronize()
            showOrHideInfoAlert()
        }
    }

    func setLayoutInfoAlert() {
        infoAlertConstraint.constant = -436
        infoAlert.layer.cornerRadius = 15
        infoAlert.alpha = 0.8
        okButtonInfoAlert.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
    }
    
    func showOrHideInfoAlert() {
        if infoAlertIsHidden {
            infoAlert.isHidden = false
            infoAlertConstraint.constant = 199
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
            toolbar.isHidden = true
            button.isHidden = true
        } else {
            view.endEditing(true)
            infoAlertConstraint.constant = -436
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
            toolbar.isHidden = false
            button.isHidden = false
        }
        infoAlertIsHidden = !infoAlertIsHidden
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Login alertbox
    
    func setLayoutLoginAlert() {
        loginAlertConstraint.constant = -408
        loginAlert.alpha = 0.85
        loginAlert.layer.cornerRadius = 15
        usernameTextField.backgroundColor = UIColor.black
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        usernameTextField.layer.borderColor = UIColor.lightGray.cgColor
        usernameTextField.layer.borderWidth = 0.5
        usernameTextField.layer.cornerRadius = 7
        passwordTextField.backgroundColor = UIColor.black
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.cornerRadius = 7
        cancelButton.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
        loginButton.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
        loginButton.addBorder(side: .Left, color: UIColor.lightGray.cgColor, thickness: 0.5)
    }
    
    func showOrHideLoginAlert() {
        if loginAlertIsHidden {
            usernameTextField.text = "1@2.com"  // Change to nil in live
            passwordTextField.text = "123456"   // Change to nil in live
            loginAlert.isHidden = false
            loginAlertConstraint.constant = 321
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
            toolbar.isHidden = true
            button.isHidden = true
        } else {
            view.endEditing(true)
            loginAlertConstraint.constant = -408
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
            toolbar.isHidden = false
            button.isHidden = false
        }
        loginAlertIsHidden = !loginAlertIsHidden
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - GPS
    
    let locationManager = CLLocationManager()
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    showLocationDisablePopUpBool = true
                case .authorizedAlways, .authorizedWhenInUse:
                    showLocationDisablePopUpBool = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            gpsInfo = location
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Camera
    
    func setLayoutCameraButton() {
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.5
        button.addCircle()
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
        }
    }
    
    ///////////////////////////////////////////
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto_Segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
            previewVC.gpsInfo = self.gpsInfo
            previewVC.date = self.date
            previewVC.showLocationDisablePopUpBool = self.showLocationDisablePopUpBool
        }
//        else if segue.identifier == "showMap_Segue" {
//            
//        }
    }
    
    ///////////////////////////////////////////
}

