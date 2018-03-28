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
    var faultViewIsHidden = true
    var faultInfoViewIsHidden = true
    var faultsArray: [Fault] = []
    var infoImage: UIImage?
    var selectedIndexPath: IndexPath?
    var pinArray: [MKAnnotation] = []
    var wentFromList: Bool = false
    var whichAnnotaionPinIsPressed: AnnotationPin?
    
    let initLocation = CLLocation(latitude: 59.3293235, longitude: 18.068580800000063)
    let regionRadius: CLLocationDistance = 10000
    
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
        setMap()
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
        if wentFromList {
            wentFromList = false
            deleteInfoAndPicFromFirebase(indexPathRow: (selectedIndexPath?.row)!)
        } else {
            // TODO: - Bug cant get right indexpath number            
            deleteInfoAndPicFromFirebase(indexPathRow: (selectedIndexPath?.row)!)
        }
        showOrHideInfoView()
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
    
    ///////////////////////////////////////////
    
    
    // MARK: - Map
    
    func setMap() {
        mapView.register(FaultView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.showsUserLocation = true
        mapView.tintColor = UIColor.black
        mapView.mapType = .hybrid
        mapView.showsPointsOfInterest = false
        mapView.delegate = self
        mapView.showsScale = true
        
        centerMapOnLocation(location: initLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        } else if let cluster = annotation as? MKClusterAnnotation {
//            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster")
//            cluster.memberAnnotations[pinArray]
//
//            return view
//        } else {
//            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "fault")
//
//            return view
//        }
//
////        guard let annotation = annotation as? AnnotationPin else { return nil }
////        let identifier = "marker"
////        var view: MKMarkerAnnotationView
////        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
////            dequeuedView.annotation = annotation
////            view = dequeuedView
////        } else {
////            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
////            view.canShowCallout = true
////            view.glyphText = "Fault"
////            view.markerTintColor = UIColor.black
////            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
////            view.rightCalloutAccessoryView?.tintColor = UIColor.black
////            view.displayPriority = .defaultHigh
////            view.clusteringIdentifier
////        }
//        return view
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        whichAnnotaionPinIsPressed = view.annotation as? AnnotationPin
        let fault = view.annotation as! AnnotationPin
        mapView.deselectAnnotation(fault, animated: true)
        SVProgressHUD.show(withStatus: "Waiting for connection")
        Alamofire.request(fault.fault.imageURL).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Downloading Image")
            } .responseImage { response in
                if let image = response.result.value {
                    self.faultImageFaultInfoView.image = image
                    SVProgressHUD.showSuccess(withStatus: "Great Sucesses!")
                }
        }
        titleNavBarFaultInfoView.title = Fault.getRidOfTimeInDateAsString(fault.fault.date)
        commentTextFaultInfoView.text = fault.fault.comment
        showOrHideInfoView()
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
        wentFromList = true
        selectedIndexPath = indexPath
        SVProgressHUD.show(withStatus: "Waiting for connection")
        Alamofire.request(faultsArray[indexPath.row].imageURL).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Downloading Image")
            } .responseImage { response in
            if let image = response.result.value {
                self.faultImageFaultInfoView.image = image
                SVProgressHUD.showSuccess(withStatus: "Great Success!")
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
            deleteInfoAndPicFromFirebase(indexPathRow: indexPath.row)
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Buttons
    
    func showOrHideList() {
        if faultViewIsHidden {
            faultInfoView.isHidden = true
            faultInfoViewIsHidden = true
            faultsViewConstraint.constant = 150
            UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        } else if faultViewIsHidden && !faultInfoViewIsHidden {
            faultListTableView.isHidden = false
            faultInfoView.isHidden = true
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
            faultInfoView.isHidden = false
        } else {
            faultInfoView.isHidden = true
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
        faultListTableView.round(corners: [.bottomLeft, .bottomRight], radius: 15)
        faultsViewNavBar.round(corners: [.topLeft, .topRight], radius: 15)
        faultsView.layer.cornerRadius = 15
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
    
    func deleteInfoAndPicFromFirebase(indexPathRow: Int) {
        SVProgressHUD.show()
        let ref = Database.database().reference().child("Fault")
        let key = "\(faultsArray[indexPathRow].key)"
        let imageUrl = faultsArray[indexPathRow].imageURL
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        storageRef.delete { error in
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: "Something went wrong..")
            } else {
                ref.child(key).removeValue()
                self.faultsArray.remove(at: indexPathRow)
                self.getValueFromFirebase()
                self.faultListTableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - Helpers //BUG!!!!

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !faultViewIsHidden && !faultInfoViewIsHidden {
            showOrHideInfoView()
            showOrHideList()
        } else if !faultViewIsHidden {
            showOrHideList()
        } else if !faultInfoViewIsHidden {
            showOrHideInfoView()
        }
    }
    ///////////////////////////////////////////
    
    
}
