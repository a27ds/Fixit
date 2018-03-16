//
//  PreviewViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-09.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variable Declarations
    
    var image: UIImage!
    var gpsInfo: CLLocation!
    var date: Date!
    var showLocationDisablePopUpBool: Bool!
    var commentFieldIsHidden = true
    var faultAlertIsHidden = true
    let commentText = "Write a comment about the fault."

    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var showPhoto: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var charsLeft: UILabel!
    @IBOutlet weak var commentField: UIView!
    @IBOutlet weak var commentFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var faultReportedAlert: UIView!
    @IBOutlet weak var faultReportedAlertConstraint: NSLayoutConstraint!
    @IBOutlet weak var okButtonFaultAlert: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarConstraint: NSLayoutConstraint!
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPhoto.contentMode = .scaleAspectFill
        showPhoto.image = self.image
        textView.delegate = self
        commentFieldConstraint.constant = -408
        faultReportedAlertConstraint.constant = -408
        print(gpsInfo.coordinate)
        print(date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showLocationDisablePopUp()
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBActions

    @IBAction func retakeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useButtonPressed(_ sender: UIBarButtonItem) {
        setLayoutInCommentField()
        toolbar.isHidden = true
        showOrHideCommentField()
    }
    
    @IBAction func commentFieldCancelButtonPressed(_ sender: UIButton) {
        showOrHideCommentField()
        toolbar.isHidden = false
    }
    
    @IBAction func commentFieldDoneButtonPressed(_ sender: UIButton) {
        let newFault = Fault(date: date, lat: gpsInfo.coordinate.latitude, long: gpsInfo.coordinate.longitude, image: image, comment: textView.text)
        firebaseUpload(fault: newFault)
        showOrHideCommentField()
        setLayoutFaultAlert()
        showOrHideFaultAlert()
    }
    
    func firebaseUpload(fault: Fault) {
        let timeStamp = "\(Int(Date.timeIntervalSinceReferenceDate*1000))"
        
        // Upload Picture to Firebase Storage
        let storage = Storage.storage()
        var data = Data()
        data = UIImageJPEGRepresentation(image, 1.0)!
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(timeStamp)")
        _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
            guard let metadata = metadata else{
                print(error!)
                return
            }
            let downloadURL = metadata.downloadURL()
            print(downloadURL!)
        })
        
        // Upload Fault to firebase Database
        let ref = Database.database().reference()
        let post = [
            "date": fault.date,
            "long": fault.long,
            "lat": fault.lat,
            "comment": textView.text,
            "image": timeStamp
            ] as [String : Any]
        ref.child("faults").child(timeStamp).setValue(post) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully!")
            }
        }
    }
    
    @IBAction func okButtonFaultAlertPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - FaultAlert

    func showOrHideFaultAlert() {
        if faultAlertIsHidden {
            faultReportedAlert.isHidden = false
            faultReportedAlertConstraint.constant = 297
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        } else {
            view.endEditing(true)
            faultReportedAlertConstraint.constant = -408
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        faultAlertIsHidden = !faultAlertIsHidden
    }
    
    func setLayoutFaultAlert() {
        faultReportedAlert.alpha = 0.8
        faultReportedAlert.layer.cornerRadius = 15
        faultReportedAlert.backgroundColor = UIColor.black
        faultReportedAlert.tintColor = UIColor.white
        okButtonFaultAlert.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - CommentField
    
    func setLayoutInCommentField() {
        commentField.alpha = 0.8
        commentField.layer.cornerRadius = 15
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 7
        textView.text = commentText
        textView.textColor = UIColor.lightGray
        charsLeft.text = "0/200"
        cancelButton.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
        doneButton.addBorder(side: .Left, color: UIColor.lightGray.cgColor, thickness: 0.5)
        doneButton.addBorder(side: .Top, color: UIColor.lightGray.cgColor, thickness: 0.5)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        charsLeft.text = "\(numberOfChars)/200"
        return numberOfChars < 200;
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = commentText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func showOrHideCommentField() {
        if commentFieldIsHidden {
            commentField.isHidden = false
            commentFieldConstraint.constant = 277
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        } else {
            view.endEditing(true)
            commentFieldConstraint.constant = -408
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        commentFieldIsHidden = !commentFieldIsHidden
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Alerts

    func showLocationDisablePopUp() {
        if showLocationDisablePopUpBool {
            let alert = UIAlertController(title: "Location Access Disable",
                                          message: "In order to report this fault to the city administration, we need your location",
                                          preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            let openSetting = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(openSetting)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    ///////////////////////////////////////////
}

