//
//  MapVC.swift
//  HeyBike
//
//  Created by Niklas Gundlev on 07/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class MapVC: UIViewController, MKMapViewDelegate {
    
    let realm = try! Realm()
    var parkings: Results<Parking>!
    var latestPin: MapPin?
    var chosenPin: MapPin?
    
    @IBOutlet weak var NewButton: UIButton!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func showLatest(sender: AnyObject) {
        if latestPin != nil {
            self.mapView.showAnnotations([self.latestPin!], animated: true)
            self.mapView.selectAnnotation(self.latestPin!, animated: true)
        }
    }
    
    override func viewDidLoad() {
        
        let anyParkings = getAllSaved()
        var pinArr = [MapPin]()
        if anyParkings {
            print("There are saved parkings")
            for parking in self.parkings {
                
                // Getting the image
                let image = getImageWithName(parking.parkingId)
                
                let date = NSDate(timeIntervalSince1970: NSTimeInterval(parking.timestamp))
                let timeStamp = NSDateFormatter()
                timeStamp.dateFormat = "d. MMM yyyy"
                let timeCapture = timeStamp.stringFromDate(date)
                let mapPin = MapPin(coordinate: CLLocationCoordinate2D(latitude: parking.lat, longitude: parking.lng), title: timeCapture, subtitle: parking.comment, image: image, timestamp: parking.timestamp)
                self.mapView.addAnnotation(mapPin)
                pinArr.append(mapPin)
            }
            var latestPin = pinArr[0]
            for pin in pinArr {
                if pin > latestPin {
                    latestPin = pin
                }
            }
            self.latestPin = latestPin
            self.zoomToFitMapAnnotations(self.mapView)
        } else {
            print("There are no saved parkings")

        }
        
        latestButton.layer.cornerRadius = 10
    }
    
    func getAllSaved() -> Bool {
        let parkings = realm.objects(Parking)
        self.parkings = parkings
        if parkings.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func getImageWithName(name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(name + ".png")
        return UIImage(contentsOfFile: dataPath)
    }
    
    func zoomToFitMapAnnotations(aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in aMapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = aMapView.regionThatFits(region)
        aMapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 0)
                
                let button = UIButton(type: .DetailDisclosure)
                button.addTarget(self, action: #selector(showParking), forControlEvents: UIControlEvents.TouchUpInside)
//                button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//                button.hidden = true
                view.rightCalloutAccessoryView = button as UIView
                
                if annotation.image != nil  {
                    print("image to the pin")
                    let imgView = UIImageView()
                    let image = annotation.image!
                    if image.size.height > image.size.width {
                        let ratio = image.size.width/image.size.height
                        let newWidth = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: 40)
                    } else {
                        let ratio = image.size.height/image.size.width
                        let newHeight = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: 40, height: newHeight)
                    }
                    
                    imgView.image = annotation.image!
                    view.leftCalloutAccessoryView = imgView
                } else {
                    print("no image to the pin")
                }
               
                let pinImage = UIImage(named: "BikePin")
                view.image = pinImage
                view.centerOffset.y = -((pinImage?.size.height)!/2)

            }
            return view
        }
        return nil

    }
    
    func showParking() {
        performSegueWithIdentifier("showParking", sender: self)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.chosenPin = view.annotation as! MapPin
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showParking" && self.chosenPin != nil {
            let vc = segue.destinationViewController as! ShowParkingVC
            vc.text = self.chosenPin?.subtitle
            vc.titleText = self.chosenPin?.title
            vc.image = self.chosenPin?.image
        }
    }
    
}
