//
//  ButtonViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-06.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.purpleColor()
        
        var button = UIButton.buttonWithType(.System) as UIButton
        button.setTitle("Press me", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: "buttonWasPressed:", forControlEvents: .TouchUpInside)
        button.center = self.view.center
        button.bounds = CGRectMake(0, 0, 100, 100)
        self.view.addSubview(button)
    }
    
    func buttonWasPressed(button: UIButton) {
        var alert = UIAlertController(title: "You Did It!", message: "You clicked me!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
