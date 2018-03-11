//
//  PreviewViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-09.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    // MARK: - Variable Declarations
    
    var image: UIImage!
    var showLocationDisablePopUpBool: Bool!

    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var showPhoto: UIImageView!
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPhoto.contentMode = .scaleAspectFill
        showPhoto.image = self.image
        
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
    }
    
    ///////////////////////////////////////////
    
    // MARK: - Alerts

    func showLocationDisablePopUp() {
        if showLocationDisablePopUpBool {
        print("test6")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
