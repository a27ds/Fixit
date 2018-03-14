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

class CameraViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Variabel Decalartions
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var showLocationDisablePopUpBool: Bool?
    var loginAlertIsHidden = true
    
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
    
    ///////////////////////////////////////////
    
   
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutCameraButton()
        setLayoutLoginAlert()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIBarButtonItem) {
        showOrHideLoginAlert()
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showInfo_Segue", sender: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        getLocation()
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func loginAlertButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func cancelAlertButtonPressed(_ sender: UIButton) {
        showOrHideLoginAlert()
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
            usernameTextField.text = nil
            passwordTextField.text = nil
            loginAlert.isHidden = false
            loginAlertConstraint.constant = 408
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
        locationManager.requestAlwaysAuthorization()
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
            // TODO: - Get gps info to a var
            print(location.coordinate)
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Camera
    
    func setLayoutCameraButton() {
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.5
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto_Segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
            previewVC.showLocationDisablePopUpBool = self.showLocationDisablePopUpBool
        } else if segue.identifier == "showInfo_Segue" {
            
        }
    }
    
    ///////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            print(imageData)
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
        }
    }
}

