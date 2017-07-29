////
////  Marker.swift
////  Travlr
////
////  Created by Ryan Ching on 6/6/17.
////  Copyright © 2017 Ryan Ching. All rights reserved.
////
//
import Foundation
import DKImagePickerController
import CoreData

class Marker: NSManagedObject {
    
    @NSManaged var title: String
    @NSManaged var date: String
    @NSManaged var descriptionText: String
    @NSManaged var images: Array<Any>
    
    override init(entity: NSEntityDescription,
                  insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
        
    }
    
    
//    init(title: String, date: String, description: String, images: [Any]) {
//        self.title = title
//        self.date = date
//        self.descriptionText = description
//        self.images = images
//    }
//    
}




//
//  MarkerViewController.swift
//  Travlr
//
//  Created by Ryan Ching on 6/2/17.
//  Copyright © 2017 Ryan Ching. All rights reserved.
//
//
//import UIKit
//import Photos
//import DKImagePickerController
//import AVKit
//import Agrume
//import CoreData
//import GoogleMaps
//
//class MarkerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
//    
//    @IBOutlet weak var descriptionTextView: UITextView!
//    @IBOutlet weak var dateTextField: UITextField!
//    @IBOutlet weak var titleTextField: UITextField!
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    var images = ["plus",]
//    
//    var assets = [DKAsset]()
//    
//    var location: CLLocationCoordinate2D!
//    var marker: GMSMarker!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
//        self.descriptionTextView.delegate = self
//        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MarkerViewController.tap)))
//        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MarkerViewController.dismissKeyboard))
//        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector (MarkerViewController.dismissKeyboard))
//        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (MarkerViewController.dismissKeyboard))
//        view.addGestureRecognizer(pan)
//        view.addGestureRecognizer(tap)  // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
//        view.addGestureRecognizer(swipe)
//        descriptionTextView.textColor = UIColor.gray
//        
//        //If marker isn't nill, then it's an existing marker so set up the data
//        if !(marker == nil) {
//            //let m = marker.userData as! Marker
//            assets = (marker.userData as! Dictionary<String, Any>)["images"] as! [DKAsset]
//            self.titleTextField.text = marker.title
//            self.descriptionTextView.text = (marker.userData as! Dictionary<String, Any>)["description"] as! String
//            if self.descriptionTextView.text != "Description" {
//                self.descriptionTextView.textColor = UIColor.black
//            }
//            self.dateTextField.text = marker.snippet
//        }
//    }
//    
//    //display tab bar if going back to map
//    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
//    }
//    
//    //hide the tab bar for more screen space
//    override func viewWillAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = true
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    //dismiss agrume full screen image
//    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
//        self.navigationController?.isNavigationBarHidden = false
//        self.tabBarController?.tabBar.isHidden = false
//        sender.view?.removeFromSuperview()
//    }
//    
//    //When collection view cell is tapped, check if its the plus. if so, add photos. If its a photo, display using agrume
//    //If its a video, call play video function
//    func tap(sender: UITapGestureRecognizer){
//        
//        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
//            let cell = self.collectionView?.cellForItem(at: indexPath)
//            print(cell!)
//            print (indexPath)
//            if(indexPath.row == (collectionView.numberOfItems(inSection: 0)-1)){
//                print("PLUS TAPPED")
//                let pickerController = DKImagePickerController()
//                pickerController.didSelectAssets = { (assets: [DKAsset]) in
//                    print("didSelectAssets")
//                    for asset in assets{
//                        self.assets.append(asset)
//                    }
//                    self.collectionView!.reloadData()
//                }
//                self.present(pickerController, animated: true) {}
//                return
//            }
//            
//            let asset = self.assets[indexPath.row]
//            //if asset is a video then play the video, else display images fullscreen
//            if((indexPath.row == (collectionView.numberOfItems(inSection: 0)-1))==false){
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
//                    let agrume = Agrume(images: images, startIndex: indexPath.row, backgroundBlurStyle: .light)
//                    agrume.didScroll = { [unowned self] index in
//                        self.collectionView?.scrollToItem(at: IndexPath(row: index, section: 0),
//                                                          at: [],
//                                                          animated: false)
//                    }
//                    agrume.showFrom(self)
//                }
//            }
//        } else {
//            print("collection view was tapped")
//            dismissKeyboard()
//        }
//    }
//    
//    //number of items in the collection view
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //number of images displayed. Plus 1 because of plus image
//        return assets.count + 1
//    }
//    
//    //Loads cells in collection view
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ImageCollectionViewCellController
//        if(indexPath.row == (collectionView.numberOfItems(inSection: 0)-1)){
//            cell.cellImageView.image = UIImage(named: "plus")
//        }
//        else{
//            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//            assets[indexPath.row].fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { image, info in
//                cell.cellImageView.image = image
//                
//            })
//            //assets[indexPath.row].fetch
//            //            assets[indexPath.row].fetchFullScreenImage(false, completeBlock: { image, info in
//            //                cell.cellImageView.image = image
//            //
//            //
//            //            })
//            
//        }
//        return cell
//    }
//    
//    //long press on a photo.. do something with this later
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("SELECTED")
//        print(indexPath.row)
//        
//    }
//    
//    //play video when tapped using av framework
//    func playVideo(_ asset: AVAsset) {
//        let avPlayerItem = AVPlayerItem(asset: asset)
//        
//        let avPlayer = AVPlayer(playerItem: avPlayerItem)
//        let player = AVPlayerViewController()
//        player.player = avPlayer
//        
//        avPlayer.play()
//        
//        self.present(player, animated: true, completion: nil)
//    }
//    
//    //On save, update map's marker array with photos, title, date, description
//    @available(iOS 10.0, *)
//    @IBAction func save(_ sender: Any) {
//        print("save button hit")
//        let nextViewController = self.navigationController?.viewControllers[0] as! ViewController
//        let count = nextViewController.markers.count - 1
//        if((self.titleTextField.text?.isEmpty)! || (self.dateTextField.text?.isEmpty)! || (self.descriptionTextView.text?.isEmpty)!){
//            print("stuff was empty")
//            if(self.titleTextField.text?.isEmpty)!{
//                titleTextField.text = " "
//            }
//            if(self.dateTextField.text?.isEmpty)!{
//                dateTextField.text = " "
//            }
//        }
//        
//        //  let m = Marker(title: self.titleTextField.text!, date: self.dateTextField.text!, description: self.descriptionTextView.text!, images: assets)
//        // let coder = NSCoder()
//        //        let m = Marker(coder: coder)
//        //        m?.title = self.titleTextField.text!
//        //        m?.date = self.dateTextField.text!
//        //        m?.descriptionText = self.descriptionTextView.text!
//        //        m?.images = self.assets
//        //
//        var dict = Dictionary<String, Any>()
//        dict["images"] = assets
//        dict["title"] = self.titleTextField.text
//        dict["description"] = descriptionTextView.text
//        dict["date"] = self.dateTextField.text
//        nextViewController.markers[count].title = self.titleTextField.text
//        nextViewController.markers[count].snippet = self.dateTextField.text
//        //        nextViewController.markers[count].userData = m
//        nextViewController.markers[count].userData = dict
//        
//        //let x = (nextViewController.markers[count].userData as! Dictionary<String, Any>)["images"]
//        
//        
//        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let entity = NSEntityDescription.entity(forEntityName: "PersistentMarker",
//                                                in: managedContext)!
//        
//        let persistentMarker = NSManagedObject(entity: entity,
//                                               insertInto: managedContext)
//        
//        // 3
//        persistentMarker.setValue(dict, forKeyPath: "userData")
//        
//        // 4
//        do {
//            try managedContext.save()
//            nextViewController.persistentMarkers.append(persistentMarker)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//        
//        self.navigationController?.popToRootViewController(animated: true)
//        
//    }
//    
//    //give description box placeholder properties
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.gray {
//            textView.text = nil
//            textView.textColor = UIColor.black
//        }
//    }
//    //give description box placeholder properties
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Description"
//            textView.textColor = UIColor.gray
//        }
//    }
//    
//    //dismiss keyboard function
//    func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
//        view.endEditing(true)
//    }
//    
//    
//    
//    
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    
//}
