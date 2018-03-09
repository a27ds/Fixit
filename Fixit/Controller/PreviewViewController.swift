//
//  PreviewViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-09.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var image: UIImage!

    @IBOutlet weak var showPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPhoto.contentMode = .scaleAspectFill
        showPhoto.image = self.image
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
