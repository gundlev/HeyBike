//
//  ShowParkingVC.swift
//  HeyBike
//
//  Created by Niklas Gundlev on 07/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class ShowParkingVC: UIViewController {
    
    var image: UIImage?
    var text: String?
    var titleText: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var titleDate: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteParking(sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("YES") {
            self.performSegueWithIdentifier("exitAfterDelete", sender: self)
        }
        alertView.addButton("NO") {}
        alertView.showWarning("Are you sure??", subTitle: "\nBy saying yes, this parking will be permanently deleted") // Warning

    }
    
    override func viewDidLoad() {
        deleteButton.layer.cornerRadius = 10
        self.imageView.image = image!
        self.textField.text = text!
        self.titleDate.text = titleText
        self.textField.textColor = UIColor.whiteColor()
        self.textField.textAlignment = .Center
        self.textField.font = UIFont.systemFontOfSize(17.0)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        performSegueWithIdentifier("exitTabbed", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitAfterDelete" {
            let vc = segue.destinationViewController as! MapVC
            vc.deleteCurrentParking()
        }
    }
}
