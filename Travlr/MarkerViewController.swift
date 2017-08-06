//
//  MarkerViewController.swift
//  Travlr
//
//  Created by Ryan Ching on 6/2/17.
//  Copyright © 2017 Ryan Ching. All rights reserved.
//

import UIKit
import Photos
import DKImagePickerController
import AVKit
import Agrume
import CoreData
import GoogleMaps
import Firebase
import FirebaseDatabase
import FirebaseStorage


class MarkerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var assets = [UIImage]()
    var imageNames = [String]()
    var cells = [UICollectionViewCell]()
    var location: CLLocationCoordinate2D!
    var marker: GMSMarker!
    var dataPath: URL!
    
    var markers: Array<GMSMarker> = []
    var backButton: UIButton!
    var deleteButton: UIButton!
    var markerWasSaved = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.descriptionTextView.delegate = self
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarkerViewController.tap)))
        
        //add back button
        self.backButton = UIButton(frame: CGRect(x: 5, y: 55, width: 50, height: 50))
        let backButtonLabel = UILabel(frame: CGRect(x: 18, y: 0, width:50, height:50))
        backButtonLabel.text = "Back"
        backButtonLabel.textColor = UIColor.white
        backButtonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        backButton.addSubview(backButtonLabel)
        backButton.addTarget(self, action: #selector(popToMap), for: .touchUpInside)
        view.addSubview(backButton)
        
        //add delete button
        self.deleteButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-60, y: 55, width: 50, height: 90))
        let deleteButtonLabel = UILabel(frame: CGRect(x: 18, y: 0, width:50, height:50))
        deleteButtonLabel.text = "Delete \nMarker"
        deleteButtonLabel.numberOfLines = 0
        deleteButtonLabel.textColor = UIColor.white
        deleteButtonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 8.0)
        deleteButton.addSubview(deleteButtonLabel)
        deleteButton.addTarget(self, action: #selector(deleteMarker), for: .touchUpInside)
        view.addSubview(deleteButton)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dataPath = documentsDirectory.appendingPathComponent("MyFolder")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MarkerViewController.dismissKeyboard))
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector (MarkerViewController.dismissKeyboard))
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (MarkerViewController.dismissKeyboard))
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)  // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        view.addGestureRecognizer(swipe)
        descriptionTextView.textColor = UIColor.gray
        
        
        if(marker.title != nil && marker.title != " "){
            titleTextField.text = marker.title
        }
        if(marker.snippet != nil && marker.snippet != " "){
            dateTextField.text = marker.snippet
        }
        
        //check if marker info exists in firebase. If it does, load up photos and stuff
        print("testing: ")

        if(self.marker.userData != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"] != nil){                    let names = (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"]
            print(names!)
            for imageName in names!{
                print("ryan")
                print(imageName)
                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let imageURL = docDir.appendingPathComponent(imageName)
                if(FileManager.default.fileExists(atPath: imageURL.path)){
                    let newImage = UIImage(contentsOfFile: imageURL.path)!
                    self.assets.append(newImage)
                    self.collectionView.reloadData()
                }
            }
        }
        else{
            print("No images stored in this child")
        }
     
        if(self.marker.userData != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["description"] != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["description"]?[0] != nil){
            self.descriptionTextView.text = (self.marker.userData as! Dictionary<String, Array<String>>)["description"]?[0]
            if(self.descriptionTextView.text != "Description"){
                self.descriptionTextView.textColor = UIColor.black
            }
        }
        else{
            print("No description stored in this child")
        }

    }

    //display tab bar if going back to map
    override func viewWillDisappear(_ animated: Bool) {
        if(self.markerWasSaved == false){
            self.marker.map = nil
        }
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //hide the tab bar for more screen space
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //dismiss agrume full screen image
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    //When collection view cell is tapped, check if its the plus. if so, add photos. If its a photo, display using agrume
    //If its a video, call play video function
    func tap(sender: UITapGestureRecognizer){
        
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let cell = self.collectionView?.cellForItem(at: indexPath)
            
            print(cell!)
            print (indexPath)
            if(indexPath.row == (collectionView.numberOfItems(inSection: 0)-1)){
                print("PLUS TAPPED")
            
                let pickerController = DKImagePickerController()
                pickerController.didSelectAssets = { (assets: [DKAsset]) in
                    print("didSelectAssets")
              
                    for asset in assets{
                        asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
                            self.assets.append(image!)
                        })
                    }
                    self.collectionView!.reloadData()
                }
                self.present(pickerController, animated: true) {}
                return
            }
            //let asset = self.assets[indexPath.row]
            //if asset is a video then play the video, else display images fullscreen
            if((indexPath.row == (collectionView.numberOfItems(inSection: 0)-1))==false){ //if not plus image
//                if asset.isVideo{
//                    asset.fetchAVAssetWithCompleteBlock { (avAsset, info) in
//                        DispatchQueue.main.async(execute: { () in
//                            self.playVideo(avAsset!)
//                        })
//                    }
//                }
//                else{
//                    var images = [UIImage]()
//                    for asset in assets{
//                        asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
//                            images.append(image!)
//                        })
//                    }
                    let agrume = Agrume(images: self.assets, startIndex: indexPath.row, backgroundBlurStyle: .light)
                    agrume.didScroll = { [unowned self] index in
                        self.collectionView?.scrollToItem(at: IndexPath(row: index, section: 0),
                                                          at: [],
                                                          animated: false)
                    }
                    agrume.showFrom(self)
                //}
            }
        } else {
            print("collection view was tapped")
            dismissKeyboard()
        }
    }
    
    //number of items in the collection view number of images displayed. Plus 1 because of plus image
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.assets.count + 1)
        return self.assets.count + 1
    }
    
    
    //Loads cells in collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCellController
        if(indexPath.row == (collectionView.numberOfItems(inSection: 0)-1)){
            cell.cellImageView.image = UIImage(named: "plus")
            //cell.cellImageView.frame.size.height = 70
            //cell.cellImageView.frame.size.width = 70
            
        }
        else{
            cell.cellImageView.image = assets[indexPath.row]
        }
        
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(MarkerViewController.longPressCell))
        cell.addGestureRecognizer(lpg)
        
        self.cells.append(cell)
        
        return cell
        
    }
    

    
    func longPressCell(){
        print("longpresscell")
        let numCells = self.collectionView.numberOfItems(inSection: 0)
        for index in 0...(numCells-1){
            print(index)
            
            let cell = self.collectionView.cellForItem(at: [0,index])
            let deleteButton = UIButton(frame: CGRect(x: 5, y: 5, width: 50, height: 90))
            let deleteButtonLabel = UILabel(frame: CGRect(x: 0, y: 0, width:50, height:50))
            deleteButtonLabel.text = "Delete Pic"
            deleteButtonLabel.numberOfLines = 0
            deleteButtonLabel.textColor = UIColor.white
            deleteButtonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 8.0)
            deleteButton.addSubview(deleteButtonLabel)
            deleteButton.addTarget(self, action: #selector(deleteMarker), for: .touchUpInside)
            cell?.addSubview(deleteButton)
        }
        
        
    }
    
    func deleteImage(){
        print("delete image tapped")
    }
    
    //long press on a photo.. do something with this later
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SELECTED")
        print(indexPath.row)
        
    }
    
    //play video when tapped using av framework
    func playVideo(_ asset: AVAsset) {
        let avPlayerItem = AVPlayerItem(asset: asset)
        
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        let player = AVPlayerViewController()
        player.player = avPlayer
        
        avPlayer.play()
        
        self.present(player, animated: true, completion: nil)
    }
    
    //On save, update map's marker array with photos, title, date, description
  //  @available(iOS 10.0, *)
    @IBAction func save(_ sender: Any) {
        print("save button hit")
        self.markerWasSaved = true
        let nextViewController = self.navigationController?.viewControllers[0] as! ViewController
        let count = nextViewController.markers.count - 1
        if((self.titleTextField.text?.isEmpty)! || (self.dateTextField.text?.isEmpty)! || (self.descriptionTextView.text?.isEmpty)!){
            print("stuff was empty")
            if(self.titleTextField.text?.isEmpty)!{
                titleTextField.text = " "
            }
            if(self.dateTextField.text?.isEmpty)!{
                dateTextField.text = " "
            }
        }
        
        marker.title = titleTextField.text
        marker.snippet = dateTextField.text
        
        
        //var imagess = [UIImage]()
//        for asset in assets{
//            asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
//                imagess.append(image!)
//            })
//        }
        
        for image in self.assets {
            let imageName = UUID().uuidString + ".png"
            let imageData = UIImagePNGRepresentation(image)!
            let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageURL = docDir.appendingPathComponent(imageName)
            try! imageData.write(to: imageURL)
            imageNames.append(imageName)
            //let newImage = UIImage(contentsOfFile: imageURL.path)!
        }
        
        print("Saving to fb...")
        if let uid = Auth.auth().currentUser?.uid {
            let postObject: Dictionary<String, Any> = [
                "uid" : uid,
                "longitude" : location.longitude,
                "latitude" : location.latitude,
                "imageNames" : imageNames,
                "title" : titleTextField.text!,
                "date" : dateTextField.text!,
                "description" : descriptionTextView.text!
                ]
            
            let locationID = (String(format:"%f", location.latitude) + "," + String(format:"%f", location.longitude)).replacingOccurrences(of: ".", with: "d")
            Database.database().reference().child(uid).child("markers").child(locationID).setValue(postObject)
            var data: Dictionary<String, Array<String>> = [:]
            data["imageNames"] = imageNames
            let desc: [String] = [descriptionTextView.text]
            data["description"] = desc
            self.marker.userData = data

//            var markerPostObject: Dictionary<String, String> = [:]
//            for m in self.markers{
//                if(m.isEqual(marker)){
//                    markerPostObject[locationID] = self.titleTextField.text! + "," + self.dateTextField.text!
//                    print("samw marjer")
//                }
//                else{
//                    let lid = (String(format:"%f", m.position.latitude) + "," + String(format:"%f", m.position.longitude)).replacingOccurrences(of: ".", with: "d")
//                    markerPostObject[lid] = m.title! + "," + m.snippet!
//                    print("dif marker")
//                }
//            }
//            Database.database().reference().child(uid).child("markers").child(locationID).setValue(markerPostObject)

            
        }
        
       

        
        //uploadImages()
//        nextViewController.markers.append(marker)
//        
//        let randomName = randomStringWithLenth(length: 10)
//        let uploadRef = Storage.storage().reference().child("images/\(randomName)")
//        uploadRef.putData(marker, metadata: nil) { (metadata, error) in
//            if(error == nil){
//                print("Success")
//            }
//            else{
//                print("error")
//            }
//        }
        
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        
//        // 1
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        
//        // 2
//        let entity =
//            NSEntityDescription.entity(forEntityName: "PersistentMarker",
//                                       in: managedContext)!
//        
//        let person = NSManagedObject(entity: entity,
//                                     insertInto: managedContext)
//        
//        let name = marker
//        
//        
//        // 3
//        person.setValue(name, forKeyPath: "userData")
//        
//        // 4
//        do {
//            try managedContext.save()
//            people.append(person)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
        

        marker.map = nextViewController.mapView
        popToMap()
        //self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func popToMap(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func deleteMarker(){
        print("deleting")
        if let uid = Auth.auth().currentUser?.uid {
            let locationID = (String(format:"%f", location.latitude) + "," + String(format:"%f", location.longitude)).replacingOccurrences(of: ".", with: "d")
            Database.database().reference().child(uid).child("markers").child(locationID).removeValue()
            self.marker.map = nil
            
            //delete image data from locally stored file
            if(self.marker.userData != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"] != nil){                    let names = (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"]
                print(names!)
                for imageName in names!{
                    
                    print(imageName)
                    let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    var imageURL = docDir.appendingPathComponent(imageName)
                    imageURL.deletePathExtension()
                }
            }

            
            popToMap()
        }
    }
    
    func randomStringWithLenth(length: Int) -> String {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let randomString: NSMutableString = NSMutableString(capacity: length)
        
        for _ in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
    
    
    //give description box placeholder properties
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    //give description box placeholder properties
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.gray
        }
    }
    
    //dismiss keyboard function
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
        view.endEditing(true)
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
