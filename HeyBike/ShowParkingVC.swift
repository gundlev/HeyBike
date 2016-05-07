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
    
    override func viewDidLoad() {
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
}
