//
//  PhotoViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-06.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: UIImage(named: "swan.jpg"))
        imageView.frame = self.view.bounds
        imageView.contentMode = .ScaleAspectFill
        self.view.addSubview(imageView)
    }
}
