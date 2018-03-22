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

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    // MARK: - Variabel Decalartions
    var faultViewIsHidden = true
    var faultsArray: [Fault] = []
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listOrMapButton: UIBarButtonItem!
    @IBOutlet weak var faultListTableView: UITableView!
    @IBOutlet weak var faultsView: UIView!
    @IBOutlet weak var faultsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var faultsViewNavBar: UINavigationBar!
    @IBOutlet weak var backButtonfaultsViewNavBar: UIBarButtonItem!
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.dark)
        setLayoutFaultsView()
        setLayoutListTableView()
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
        let text = faultsArray[indexPath.row].date
        cell.date.text = text
        cell.date.textColor = UIColor.white
        cell.date.highlightedTextColor = UIColor.black
        cell.backgroundColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            //Remove pic and post from firebase
            let ref = Database.database().reference().child("Fault")
            let key = "\(faultsArray[indexPath.row].key)"
            let imageUrl = faultsArray[indexPath.row].imageURL
            let storageRef = Storage.storage().reference(forURL: imageUrl)
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    ref.child(key).removeValue()
                    self.getValueFromFirebase()
                    self.faultListTableView.reloadData()
                }
            }
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
    
    ///////////////////////////////////////////
    
    
    // MARK: - Setup Layout
    
    func setLayoutListTableView() {
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
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Firebase

    func getValueFromFirebase() {
        SVProgressHUD.show()
        faultsArray.removeAll()
        let ref = Database.database().reference().child("Fault")
        ref.observe(.childAdded) { (snapshot) in
            let listFault = Fault(snapshot: snapshot)
            self.faultsArray.append(listFault)
            self.faultListTableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    ///////////////////////////////////////////
}
