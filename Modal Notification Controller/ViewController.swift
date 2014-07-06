//
//  ViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-05.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate, ModalNotificationViewControllerDelegate {
    @IBAction func presentButtonWasPressed(sender: UIButton) {
        let viewController = ModalNotificationViewController(delegate: self)
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .Custom
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return ModalNotificationAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return ModalNotificationAnimator()
    }
    
    func numberOfViewControllers() -> Int  {
        return 3
    }
    
    func viewControllerAtIndex(index: UInt) -> UIViewController {
        switch index {
        case 0:
            return PhotoViewController()
        case 1:
            return TextViewController()
        default:
            return ButtonViewController()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool  {
        return true
    }
}

