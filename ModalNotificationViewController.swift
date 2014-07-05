//
//  ModalNotificationViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-05.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

protocol ModalNotificationViewControllerDelegate {
    
}

class ModalNotificationViewController: UIViewController {
    let delegate: ModalNotificationViewControllerDelegate
    
    init(delegate: ModalNotificationViewControllerDelegate) {
        self.delegate = delegate;
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.purpleColor()
    }

}
