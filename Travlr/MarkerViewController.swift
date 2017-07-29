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
    
  //  var images = ["plus",]
    var assets = [UIImage]()
    var imageNames = [String]()
    var location: CLLocationCoordinate2D!
    var marker: GMSMarker!
    //var people: [NSManagedObject] = []
    var dataPath: URL!
    
    var markers: Array<GMSMarker> = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.descriptionTextView.delegate = self
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarkerViewController.tap)))
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dataPath = documentsDirectory.appendingPathComponent("MyFolder")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            print("hi")
            
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
        
        if(marker.title != nil){
            titleTextField.text = marker.title
        }
        if(marker.snippet != nil && marker.snippet != " "){
            dateTextField.text = marker.snippet
        }
        
        //check if marker info exists in firebase. If it does, load up photos and stuff
        print("testing: ")
        if let uid = Auth.auth().currentUser?.uid {
            let locationID = (String(format:"%f", location.latitude) + "," + String(format:"%f", location.longitude)).replacingOccurrences(of: ".", with: "d")
            Database.database().reference().child(uid).child("markers").child(locationID).observeSingleEvent(of: .value, with: { (snapshot) in
            //    let value = snapshot.value as? NSDictionary
                if(self.marker.userData != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"] != nil){                    let names = (self.marker.userData as! Dictionary<String, Array<String>>)["imageNames"]
                    print(names!)
                    for imageName in names!{
                        print(imageName)
                        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        let imageURL = docDir.appendingPathComponent(imageName)
                        
                        let newImage = UIImage(contentsOfFile: imageURL.path)!
                        self.assets.append(newImage)
                        self.collectionView.reloadData()

                    }
                }
                else{
                    print("No images stored in this child")
                    //print(self.marker.userData!)
                    //print(self.marker.description)
                }
                
                if(self.marker.userData != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["description"] != nil && (self.marker.userData as! Dictionary<String, Array<String>>)["description"]?[0] != nil){//value?["description"] as? String != nil){
                    print("we in")
                    self.descriptionTextView.text = (self.marker.userData as! Dictionary<String, Array<String>>)["description"]?[0]
                    //self.descriptionTextView.text = value?["description"] as! String
                    if(self.descriptionTextView.text != "Description"){
                        self.descriptionTextView.textColor = UIColor.black
                    }
                    print("we out")
                }
                else{
                    print("No description stored in this child")
                }
//                if(marker.title != nil){//value?["title"] as? String != nil){
//                    print(value?["title"] as! String)
//                }
//                else{
//                    print("No title stored in this child")
//                }
//                if(value?["date"] as? String != nil){
//                    print(value?["date"] as! String)
//                }
//                else{
//                    print("No date stored in this child")
//                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            
            
            
//            Database.database().reference().child(uid).child("markers").observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                
//                let keys = value?.allKeys
//                print("keys: ")
//                if(keys != nil){
//                    for key in keys!{
//                        print(key)
//                    }
//                }
//               
//                
//                
//            }) { (error) in
//                print(error.localizedDescription)
//            }
            
            
            
            
            
            
            
        }

    }

    //display tab bar if going back to map
    override func viewWillDisappear(_ animated: Bool) {
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
                        //self.assets.append(asset)
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
    
    //number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of images displayed. Plus 1 because of plus image
        
        print(self.assets.count + 1)
        return self.assets.count + 1
    }
    
    //Loads cells in collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCellController
        if(indexPath.row == (collectionView.numberOfItems(inSection: 0)-1)){
            cell.cellImageView.image = UIImage(named: "plus")
            
            //let imageData = UIImagePNGRepresentation(image)!
            
        }
        else{
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            cell.cellImageView.image = assets[indexPath.row]
   
            //assets[indexPath.row].fetch
//            assets[indexPath.row].fetchFullScreenImage(false, completeBlock: { image, info in
//                cell.cellImageView.image = image
//
//                
//            })
            
        }
            return cell
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
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
//    func uploadImages(){
////        nextViewController.markers.append(marker)
//
//        let randomName = randomStringWithLenth(length: 10)
//        let uploadRef = Storage.storage().reference().child("images/\(randomName).jpg")
//
//        var images = [UIImage]()
//        for asset in assets{
//            asset.fetchFullScreenImage(true, completeBlock: { (image, info) in
//                images.append(image!)
//            })
//        }
//        
//        for image in images {
////            let imageData = UIImageJPEGRepresentation(image, 1.0)!
////            uploadRef.putData(imageData, metadata: nil) { (metadata, error) in
////                if(error == nil){
////                    print("Success")
////                }
////                else{
////                    print("error")
////                }
////            }
//        }
//
//        
//    }
    
    
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
