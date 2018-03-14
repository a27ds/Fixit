//
//  PreviewViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-09.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variable Declarations
    
    var image: UIImage!
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
//        view.endEditing(true)
        showOrHideCommentField()
        toolbar.isHidden = false
    }
    
    @IBAction func commentFieldDoneButtonPressed(_ sender: UIButton) {
//        view.endEditing(true)
        // TODO: - Upload stuff to firebase
        showOrHideCommentField()
        setLayoutFaultAlert()
        showOrHideFaultAlert()
    }
    
    @IBAction func okButtonFaultAlertPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - FaultAlert

    func showOrHideFaultAlert() {
        if faultAlertIsHidden {
            faultReportedAlert.isHidden = false
            faultReportedAlertConstraint.constant = 408
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
        charsLeft.text = "0/120"
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
        print(numberOfChars)
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
            commentFieldConstraint.constant = 408
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

