//
//  NewPlaceVC.swift
//  HeyBike
//
//  Created by Niklas Gundlev on 07/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import MapKit

class NewPlaceVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var currentImage: UIImage?
    let realm = try! Realm()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var newPin: MapPin?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    @IBOutlet weak var VESUbView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func setImage(sender: AnyObject) {
        self.chooseImage()
    }
    
    @IBAction func save(sender: AnyObject) {
        
        if currentImage != nil {
            let parking = Parking()
            let location = appDelegate.getLocation()
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let id = NSUUID().UUIDString
            try! realm.write() {
                parking.fill((location?.coordinate.latitude)!, lng: (location?.coordinate.longitude)!, comment: self.textView.text, timeStamp: timestamp, parkingId: id)
                realm.add(parking)
            }
            saveImageToDocs(self.currentImage!, parkingId: id)
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(parking.timestamp))
            let timeStamp = NSDateFormatter()
            timeStamp.dateFormat = "d. MMM yyyy"
            let timeCapture = timeStamp.stringFromDate(date)
            self.newPin = MapPin(coordinate: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!), title: timeCapture, subtitle: self.textView.text, image: self.currentImage, timestamp: timestamp, parkingId: id)
            self.currentImage = nil
            performSegueWithIdentifier("exitAfterDone", sender: self)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("OK") {}
            alertView.showWarning("Missing Image", subTitle: "\nPlease add an image of where you parked your bike. You will be happy you did.") // Warning
        }
    }
    
    override func viewDidLoad() {
        self.saveButton.layer.cornerRadius = 10
        textView.layer.cornerRadius = 10
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.addButton.enabled = false
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight: CGFloat = keyboardSize.height
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.VESUbView.frame = CGRectMake(0, (self.VESUbView.frame.origin.y - (keyboardHeight * 0.75)), self.visualEffectsView.bounds.width, self.visualEffectsView.bounds.height)
            }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.addButton.enabled = true
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight: CGFloat = keyboardSize.height
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.VESUbView.frame = CGRectMake(0, (self.VESUbView.frame.origin.y + (keyboardHeight * 0.75)), self.visualEffectsView.bounds.width, self.visualEffectsView.bounds.height)
            }, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.textView.isFirstResponder() {
            view.endEditing(true)

        } else {
            performSegueWithIdentifier("exitTabbed", sender: self)
        }
    }
    
    func chooseImage() {
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Library")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Library is available")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .Camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        self.currentImage = image
        self.addButton.titleLabel?.text = ""
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageToDocs(image: UIImage, parkingId: String) -> String? {
        
        let imageData = UIImagePNGRepresentation(image)
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentsDirectory: AnyObject = paths[0]
        let fileName = parkingId + ".png"
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        let success = imageData!.writeToFile(dataPath, atomically: false)
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitAfterDone" {
            if self.newPin != nil {
                let vc = segue.destinationViewController as! MapVC
                vc.mapView.addAnnotation(self.newPin!)
                vc.latestPin = newPin
                vc.pins.append(newPin!)
                vc.zoomToFitMapAnnotations(vc.mapView)
            }
        }
    }

}
