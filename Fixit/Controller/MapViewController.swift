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

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    // MARK: - Variabel Decalartions
    
    var faultsArray: [Fault] = []
    var infoImage: UIImage?
    var selectedIndexPath: IndexPath?
    var pinArray: [MKAnnotation] = []
    var wentFromList: Bool = false
    var wentFromMap = false
    var faultViewIsHidden = true
    var faultInfoViewIsHidden = true
    var whichAnnotaionPinIsPressed: AnnotationPin?
    var whichFaultIsSelected : Fault?
    var tap : UITapGestureRecognizer!
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listOrMapButton: UIBarButtonItem!
    @IBOutlet weak var faultListTableView: UITableView!
    @IBOutlet weak var faultsView: UIView!
    @IBOutlet weak var faultsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var faultsViewNavBar: UINavigationBar!
    @IBOutlet weak var mapSegmentedController: UISegmentedControl!
    
    // FaultsInfoViewOutlets
    
    @IBOutlet weak var faultInfoView: UIView!
    @IBOutlet weak var navBarFaultInfoView: UINavigationBar!
    @IBOutlet weak var titleNavBarFaultInfoView: UINavigationItem!
    @IBOutlet weak var commentTextFaultInfoView: UITextView!
    @IBOutlet weak var faultImageFaultInfoView: UIImageView!
    @IBOutlet weak var faultAccuracyInfoView: UILabel!
    
    ///////////////////////////////////////////
    
    // MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutFaultsView()
        setLayoutFaultsInfoView()
        setMap()
        setListTableView()
        getValueFromFirebase()
        tap = UITapGestureRecognizer(target: self, action: #selector (tapped))
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBActions
    
    @IBAction func mapSegmentedControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .mutedStandard
            mapSegmentedController.tintColor = UIColor.black
        default:
            mapView.mapType = .hybrid
            mapSegmentedController.tintColor = UIColor.white
        }
    }
    
    @IBAction func logutButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonNavBarFaultInfoView(_ sender: UIBarButtonItem) {
        hideInfoView()
    }
    
    @IBAction func deleteButtonNavBarFaultInfoView(_ sender: UIBarButtonItem) {
        deleteInfoAndPicFromFirebase(fault: whichFaultIsSelected!)
        whichFaultIsSelected = nil
        hideInfoView()
    }
    
    @IBAction func getDrivingInstructionsButtonFaultInfoView(_ sender: UIButton) {
        if wentFromList {
            wentFromList = false
            let coordinate = CLLocationCoordinate2D(latitude: faultsArray[(selectedIndexPath?.row)!].lat, longitude: faultsArray[(selectedIndexPath?.row)!].long)
            let location = AnnotationPin(title: Fault.getRidOfTimeInDateAsString(faultsArray[(selectedIndexPath?.row)!].date), coordinate: coordinate, fault: faultsArray[(selectedIndexPath?.row)!])
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        } else {
            let location = whichAnnotaionPinIsPressed
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location?.mapItem().openInMaps(launchOptions: launchOptions)
        }
    }
    
    @IBAction func listButtonPressed(_ sender: UIBarButtonItem) {
        changeTitleOnMapOrListButton()
    }
    
    func changeTitleOnMapOrListButton() {
        if faultViewIsHidden {
            listOrMapButton.title = NSLocalizedString("map", comment: "")
            showList()
        } else {
            listOrMapButton.title = NSLocalizedString("list", comment: "")
            hideList()
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Map
    
    func setMap() {
        let initLocation = CLLocation(latitude: 59.3293235, longitude: 18.068580800000063)
        let regionRadius: CLLocationDistance = 100000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initLocation.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.register(FaultView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.tintColor = UIColor.black
        mapView.mapType = .mutedStandard
        mapView.showsPointsOfInterest = false
        mapView.delegate = self
        mapSegmentedController.tintColor = UIColor.black
        
        mapView.showsCompass = false
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.frame.origin = CGPoint(x: 20, y: 52)
        compassButton.compassVisibility = .adaptive
        mapView.addSubview(compassButton)
        
        mapView.showsUserLocation = true
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.7).cgColor
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.tintColor = UIColor.black
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .leading
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -50),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        wentFromMap = true
        whichAnnotaionPinIsPressed = view.annotation as? AnnotationPin
        let fault = view.annotation as! AnnotationPin
        mapView.deselectAnnotation(fault, animated: true)
        SVProgressHUD.show(withStatus: NSLocalizedString("SVWaitingOnServer", comment: ""))
        Alamofire.request(fault.fault.imageURL).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: NSLocalizedString("SVDownloadingImage", comment: ""))
            } .responseImage { response in
                if let image = response.result.value {
                    self.faultImageFaultInfoView.image = image
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SVLoginSuccess", comment: ""))
                }
        }
        titleNavBarFaultInfoView.title = Fault.getRidOfTimeInDateAsString(fault.fault.date)
        commentTextFaultInfoView.text = fault.fault.comment
        faultAccuracyInfoView.text = NSString(format: "%@%.0f%@", NSLocalizedString("accuracy", comment: ""), fault.fault.horizontalAccuracy, " m") as String
        
        whichFaultIsSelected = fault.fault
        showFaultInfoView()
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if !faultsArray.isEmpty {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
            tableView.rowHeight = 44
            if faultsArray.count >= 10 {
                tableView.isScrollEnabled = true
            } else {
                tableView.isScrollEnabled = false
            }
        } else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = NSLocalizedString("NoFaultsAvailable", comment: "")
            noDataLabel.textColor     = UIColor.white
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            tableView.isScrollEnabled = false
        }
        return numOfSections
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
        wentFromList = true
        selectedIndexPath = indexPath
        SVProgressHUD.show(withStatus: NSLocalizedString("SVWaitingOnServer", comment: ""))
        Alamofire.request(faultsArray[indexPath.row].imageURL).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: NSLocalizedString("SVDownloadingImage", comment: ""))
            } .responseImage { response in
                if let image = response.result.value {
                    self.faultImageFaultInfoView.image = image
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("SVLoginSuccess", comment: ""))
                }
        }
        titleNavBarFaultInfoView.title = Fault.getRidOfTimeInDateAsString(faultsArray[indexPath.row].date)
        commentTextFaultInfoView.text = faultsArray[indexPath.row].comment
        faultAccuracyInfoView.text = NSString(format: "%@%.0f%@", NSLocalizedString("accuracy", comment: ""), faultsArray[indexPath.row].horizontalAccuracy , " m") as String
        whichFaultIsSelected = faultsArray[indexPath.row]
        showFaultInfoView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            deleteInfoAndPicFromFirebase(fault: faultsArray[indexPath.row])
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - TapOnMap
    
    func setTapOnMap() {
        mapView.addGestureRecognizer(tap)
    }
    
    func removeTapOnMap() {
        mapView.removeGestureRecognizer(tap)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        if !faultViewIsHidden {
            hideList()
            changeTitleOnMapOrListButton()
        } else {
            hideInfoView()
        }
        removeTapOnMap()
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Show or hide info or list
    
    func showList() {
        if faultViewIsHidden {
            faultsView.isHidden = false
            faultsViewConstraint.constant = 150
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.faultViewIsHidden = false
                self.setTapOnMap()
            })
        }
    }
    
    func hideList() {
        if !faultViewIsHidden && faultInfoViewIsHidden{
            faultsViewConstraint.constant = -627
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.faultsView.isHidden = true
                self.faultViewIsHidden = true
            })
        } else if !faultViewIsHidden && !faultInfoViewIsHidden {
            UIView.animate(withDuration: 0.4, animations: {
                self.faultInfoView.alpha = 0
            }, completion: {_ in
                self.faultInfoView.isHidden = true
                self.faultInfoView.alpha = 1
                self.faultInfoViewIsHidden = true
                self.faultsViewConstraint.constant = -627
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.faultsView.isHidden = true
                    self.faultViewIsHidden = true
                })
            })
        }
    }
    
    func showFaultInfoView() {
        faultInfoViewIsHidden = false
        if wentFromMap && !faultInfoViewIsHidden {
            faultInfoView.isHidden = false
            faultInfoViewIsHidden = false
            listOrMapButton.isEnabled = false
            setTapOnMap()
        } else if wentFromList {
            faultInfoView.isHidden = false
            faultInfoViewIsHidden = false
        }
    }
    
    func hideInfoView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.faultInfoView.alpha = 0
        }, completion: {_ in
            self.faultInfoView.isHidden = true
            self.faultInfoView.alpha = 1
            self.faultInfoViewIsHidden = true
            self.wentFromMap = false
            self.listOrMapButton.isEnabled = true
            self.faultImageFaultInfoView.image = nil
        })
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
        faultsViewNavBar.round(corners: [.topLeft, .topRight], radius: 15)
        faultsView.layer.cornerRadius = 15
        faultsView.backgroundColor = UIColor.black
    }
    
    func setLayoutFaultsInfoView() {
        faultInfoView.isHidden = true
        faultInfoView.layer.cornerRadius = 15
        navBarFaultInfoView.round(corners: [.topLeft, .topRight], radius: 15)
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Firebase
    
    func addPin() {
        mapView.removeAnnotations(mapView.annotations)
        pinArray.removeAll()
        for faults in faultsArray {
            let coordinate = CLLocationCoordinate2D(latitude: faults.lat, longitude: faults.long)
            let date = Fault.convertDateToString(faults.date)
            let pin = AnnotationPin(title: date, coordinate: coordinate, fault: faults)
            pinArray.append(pin)
        }
        mapView.addAnnotations(pinArray)
    }
    
    func getValueFromFirebase() {
        faultsArray.removeAll()
        let ref = Database.database().reference().child("Fault")
        ref.observe(.childAdded) { (snapshot) in
            let listFault = Fault(snapshot: snapshot)
            self.faultsArray.append(listFault)
            self.faultListTableView.reloadData()
            self.addPin()
            self.mapView.showAnnotations(self.pinArray, animated: true)
        }
    }
    
    func deleteInfoAndPicFromFirebase(fault: Fault) {
        SVProgressHUD.show()
        let ref = Database.database().reference().child("Fault")
        let key = "\(fault.key)"
        let imageUrl = fault.imageURL
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        storageRef.delete { error in
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVError", comment: ""))
            } else {
                ref.child(key).removeValue()
                if let i = self.faultsArray.index(where:  {(fault) -> Bool in
                    fault.key == key
                }) {
                    self.faultsArray.remove(at: i)
                }
                self.getValueFromFirebase()
                self.faultListTableView.reloadData()
                self.addPin()
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
    }
    
    ///////////////////////////////////////////
}
