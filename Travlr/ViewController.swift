//
//  ViewController.swift
//  Travlr
//
//  Created by Ryan Ching on 5/19/17.
//  Copyright © 2017 Ryan Ching. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import DKImagePickerController
import Firebase
import FirebaseDatabase

let kMapStyle = "[" +
    "  {" +
    "    \"featureType\": \"road\"," +
    "    \"stylers\": [" +
    "      {" +
    "        \"visibility\": \"off\"" +
    "      }" +
    "    ]" +
    "  }" +
"]"

class ViewController: UIViewController, GMSMapViewDelegate {

  //  @IBOutlet weak var mapView: GMSMapView!
    var button: UIButton!
    var longPressEnabled: Bool = false
    
    var mapView: GMSMapView!
    //let mapView: GMSMapView!
    
    var markers: Array<GMSMarker> = []
    var persistentMarkers: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 38.9072, longitude: -77.0369, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        view = mapView
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child(uid).child("markers").observeSingleEvent(of: .value, with: { (snapshot) in
             //   let value = snapshot.value as? NSDictionary
                for child in snapshot.children{
                    print(child)
                    print((child as! DataSnapshot).key)
                    let coords = (child as! DataSnapshot).key.replacingOccurrences(of: "d", with: ".").components(separatedBy: ",")
                    let lat = coords[0]
                    let lon = coords[1]
                    print((child as! DataSnapshot).childSnapshot(forPath: "title").value!)
                    print((child as! DataSnapshot).childSnapshot(forPath: "date").value!)
                    print((child as! DataSnapshot).childSnapshot(forPath: "description").value!)
                    var data: Dictionary<String, Array<String>> = [:]
                    var names: [String] = []
                    if((child as! DataSnapshot).childSnapshot(forPath: "imageNames").childrenCount > 0){
                        for c in (child as! DataSnapshot).childSnapshot(forPath: "imageNames").children.allObjects {
                            let name = (c as! DataSnapshot).value as! String
                            print(name)
                            //(data["imageNames"])?.append(name)
                            //data["imageNames"]?.append(name)
                            names.append(name)
                        }
                    }
                    let desc: [String] = [(child as! DataSnapshot).childSnapshot(forPath: "description").value! as! String]
                    data["imageNames"] = names
                    data["description"] = desc
                    let m = GMSMarker()
                    m.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                    m.title = (child as! DataSnapshot).childSnapshot(forPath: "title").value! as? String
                    m.snippet = (child as! DataSnapshot).childSnapshot(forPath: "date").value! as? String
                    print(data.description)
                    m.userData = data
                    self.markers.append(m)
                    m.map = self.mapView
                    
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369)
//        marker.title = "Washington D.C."
//        marker.snippet = "USA"
//        marker.map = mapView        
        
        button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-60, y: 10, width: 50, height: 50))
        let buttonLabel = UILabel(frame: CGRect(x: 18, y: 0, width:50, height:50))
        buttonLabel.text = "+"
        buttonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25.0)
        button.addSubview(buttonLabel)
        button.addTarget(self, action: #selector(addMarker), for: .touchUpInside)
        
        mapView.addSubview(button)
        self.navigationController?.navigationBar.isHidden = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MarkerView") as! MarkerViewController
        nextViewController.marker = marker
        print(marker.description)
        nextViewController.markers = self.markers
        nextViewController.location = marker.position
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        if(longPressEnabled == true){
            let marker = GMSMarker(position: coordinate)
            //marker.title = "Hello World"
            marker.map = mapView
       //     marker.userData = [DKAsset]()
            marker.snippet = " "
            markers.append(marker)
                            
            longPressEnabled = false
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MarkerView") as! MarkerViewController
                nextViewController.location = coordinate
                nextViewController.markers = self.markers
                nextViewController.marker = marker
                print(coordinate)
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            
        //}
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            //must use height b/c based on screen height when it was portrait
            button.frame = CGRect(x: UIScreen.main.bounds.height-60, y: 10, width: 50, height: 50)
        } else {
            //must use height b/c based on screen height when it was landscape
            button.frame = CGRect(x: UIScreen.main.bounds.height-60, y: 10, width: 50, height: 50)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMarker() {
        let alert = UIAlertController(title: "Instructions:", message: "Press and hold on a location to place a marker.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        longPressEnabled = true
        print(markers)
    }
  
    

}

