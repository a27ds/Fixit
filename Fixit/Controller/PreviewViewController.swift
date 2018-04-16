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
import SVProgressHUD

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variable Declarations
    
    var image: UIImage!
    var gpsInfo: CLLocation!
    var date: Date!
    var showLocationDisablePopUpBool: Bool!
    var commentFieldIsHidden = true
    let commentText = NSLocalizedString("commentText", comment: "")

    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var showPhoto: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var charsLeft: UILabel!
    @IBOutlet weak var commentField: UIView!
    @IBOutlet weak var commentFieldConstraint: NSLayoutConstraint!
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
        firebaseUpload()
        showOrHideCommentField()
        SVProgressHUD.show(withStatus: NSLocalizedString("SVUploading", comment: ""))
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Firebase

    func firebaseUpload() {
        let ref = Database.database().reference().child("Fault").childByAutoId()
        
        // Upload Fault and Picture to Firebase Storage
        let storage = Storage.storage()
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.4)!
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(ref.key).jpg")
        imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
            guard let metadata = metadata else{
                print(error!)
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVError", comment: ""))
                return
            }
            let firebaseImageURL = metadata.downloadURL()!.absoluteString
            let newFault = Fault(date: self.date, lat: self.gpsInfo.coordinate.latitude, long: self.gpsInfo.coordinate.longitude, imageURL: firebaseImageURL, comment: self.textView.text, key: ref.key, horizontalAccuracy: self.gpsInfo.horizontalAccuracy)
            ref.setValue(newFault.toAnyObject()) {
                (error, reference) in
                if error != nil {
                    print(error!)
                    SVProgressHUD.showError(withStatus: NSLocalizedString("SVError", comment: ""))
                } else {
                    SVProgressHUD.setMaximumDismissTimeInterval(2)
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SVFirebaseSuccess", comment: ""))
                    SVProgressHUD.setMaximumDismissTimeInterval(1)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
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
        textView.keyboardAppearance = .dark
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
            let alert = UIAlertController(title: NSLocalizedString("locationDisablePopUpTitle", comment: ""),
                                          message: NSLocalizedString("locationDisablePopUpMessage", comment: ""),
                                          preferredStyle: .alert)
            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            alert.addAction(cancel)
            let openSetting = UIAlertAction(title: NSLocalizedString("openSettings", comment: ""), style: .default) { (action) in
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

