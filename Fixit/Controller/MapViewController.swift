//
//  MapViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-16.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SVProgressHUD
import Alamofire
import AlamofireImage

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    // MARK: - Variabel Decalartions
    var faultViewIsHidden = true
    var faultInfoViewIsHidden = true
    var faultsArray: [Fault] = []
    var infoImage: UIImage?
    var selectedIndexPath: IndexPath?
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listOrMapButton: UIBarButtonItem!
    @IBOutlet weak var faultListTableView: UITableView!
    @IBOutlet weak var faultsView: UIView!
    @IBOutlet weak var faultsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var faultsViewNavBar: UINavigationBar!
    @IBOutlet weak var backButtonfaultsViewNavBar: UIBarButtonItem!
    
    // FaultsInfoViewOutlets

    @IBOutlet weak var faultInfoView: UIView!
    @IBOutlet weak var navBarFaultInfoView: UINavigationBar!
    @IBOutlet weak var titleNavBarFaultInfoView: UINavigationItem!
    @IBOutlet weak var commentTextFaultInfoView: UITextView!
    @IBOutlet weak var faultImageFaultInfoView: UIImageView!
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutFaultsView()
        setLayoutFaultsInfoView()
        setListTableView()
        getValueFromFirebase()

    }

    ///////////////////////////////////////////
    
    
    // MARK: - IBActions

    @IBAction func logutButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listButtonPressed(_ sender: UIBarButtonItem) {
        if faultViewIsHidden {
            listOrMapButton.title = "Map"
            showOrHideList()
        } else {
            listOrMapButton.title = "List"
            showOrHideList()
        }
    }

    @IBAction func backButtonNavBarFaultInfoView(_ sender: UIBarButtonItem) {
        faultImageFaultInfoView.image = nil
        showOrHideInfoView()
    }
    
    @IBAction func deleteButtonNavBarFaultInfoView(_ sender: UIBarButtonItem) {
        deleteInfoAndPicFromFirebase(indexPath: selectedIndexPath!)
        showOrHideInfoView()
    }
    
    @IBAction func getDrivingInstructionsButtonFaultInfoView(_ sender: UIButton) {
        
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = faultListTableView.dequeueReusableCell(withIdentifier: "customFaultCell", for: indexPath) as! CustomFaultCell
        cell.date.text = Fault.convertDateToString(faultsArray[indexPath.row].date)
        cell.date.textColor = UIColor.white
        cell.date.highlightedTextColor = UIColor.black
        cell.backgroundColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        SVProgressHUD.show(withStatus: "Waiting for connection")
        Alamofire.request(faultsArray[indexPath.row].imageURL).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Downloading Image")
            } .responseImage { response in
//            debugPrint(response)
//
//            print(response.request)
//            print(response.response)
//            debugPrint(response.result)
            
            if let image = response.result.value {
                self.faultImageFaultInfoView.image = image
                SVProgressHUD.showSuccess(withStatus: "Great Sucesses!")
            }
        }
        titleNavBarFaultInfoView.title = Fault.getRidOfTimeInDateAsString(faultsArray[indexPath.row].date)
        commentTextFaultInfoView.text = faultsArray[indexPath.row].comment
        showOrHideInfoView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            deleteInfoAndPicFromFirebase(indexPath: indexPath)
            
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Buttons
    
    func showOrHideList() {
        if faultViewIsHidden {
            faultListTableView.isHidden = false
            faultsViewConstraint.constant = 150
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        } else {
            faultsViewConstraint.constant = -627
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        faultViewIsHidden = !faultViewIsHidden
    }
    
    func showOrHideInfoView() {
        if faultInfoViewIsHidden {
            faultsView.isHidden = true
            faultInfoView.isHidden = false
        } else {
            faultInfoView.isHidden = true
            faultsView.isHidden = false
        }
        faultInfoViewIsHidden = !faultInfoViewIsHidden
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Setup Layout
    
    func setListTableView() {
        faultListTableView.dataSource = self
        faultListTableView.delegate = self
        faultListTableView.register(UINib(nibName: "FaultCell", bundle: nil), forCellReuseIdentifier: "customFaultCell")
        faultListTableView.backgroundColor = UIColor.black
        faultListTableView.alpha = 0.90
        faultListTableView.tableFooterView = UIView()
        
    }
    
    func setLayoutFaultsView() {
        faultsViewConstraint.constant = -627
        faultsViewNavBar.addBorder(side: .Bottom, color: UIColor.lightGray.cgColor, thickness: 0.4)
        faultInfoView.isHidden = true
        faultListTableView.round(corners: [.bottomLeft, .bottomRight], radius: 15)
        faultsViewNavBar.round(corners: [.topLeft, .topRight], radius: 15)
        faultsView.layer.cornerRadius = 15
    }
    
    func setLayoutFaultsInfoView() {
        faultInfoView.layer.cornerRadius = 15
        navBarFaultInfoView.round(corners: [.topLeft, .topRight], radius: 15)
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Firebase

    func getValueFromFirebase() {
        faultsArray.removeAll()
        let ref = Database.database().reference().child("Fault")
        ref.observe(.childAdded) { (snapshot) in
            let listFault = Fault(snapshot: snapshot)
            self.faultsArray.append(listFault)
            self.faultListTableView.reloadData()
        }
    }
    
    func deleteInfoAndPicFromFirebase(indexPath: IndexPath) {
        SVProgressHUD.show()
        let ref = Database.database().reference().child("Fault")
        let key = "\(faultsArray[indexPath.row].key)"
        let imageUrl = faultsArray[indexPath.row].imageURL
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        storageRef.delete { error in
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: "Something went wrong..")
            } else {
                ref.child(key).removeValue()
                self.getValueFromFirebase()
                self.faultListTableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    ///////////////////////////////////////////
    
    
}
