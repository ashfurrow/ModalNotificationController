//
//  TextViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-06.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel(frame: CGRectInset(self.view.bounds, 10, 10))
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        self.view.addSubview(label)
    }
}
