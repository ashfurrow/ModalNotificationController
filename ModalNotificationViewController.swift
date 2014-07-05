//
//  ModalNotificationViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-05.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

protocol ModalNotificationViewControllerDelegate {
    func numberOfViewControllers () -> Int
    func viewControllerAtIndex(index: UInt) -> UIViewController
}

class ModalNotificationViewController: UIViewController {
    let delegate: ModalNotificationViewControllerDelegate
    @lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
        return animator
    }()
    var currentViewController: UIViewController?
    var index: UInt {
        didSet {
            checkForLastViewController()
        }
    }
    
    init(delegate: ModalNotificationViewControllerDelegate) {
        assert(delegate.numberOfViewControllers() > 0, "Number of view controllers must be at least one")
        self.delegate = delegate;
        index = 0
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        addNextViewController()
    }

    func addNextViewController() {
        if let currentViewController = currentViewController {
            currentViewController.willMoveToParentViewController(nil)
            currentViewController.removeFromParentViewController()
            currentViewController.view.removeFromSuperview()
            currentViewController.didMoveToParentViewController(nil)
        }
        
        currentViewController = delegate.viewControllerAtIndex(index)
        
        if let currentViewController = currentViewController {
            // Add to self
            currentViewController.willMoveToParentViewController(self)
            addChildViewController(currentViewController)
            view.addSubview(currentViewController.view)
            currentViewController.didMoveToParentViewController(self)
        }
        
        index++
    }
    
    func checkForLastViewController() {
        if index == delegate.numberOfViewControllers() {
            self.presentingViewController?.dismissModalViewControllerAnimated(true)
        }
    }
}
