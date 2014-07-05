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
    @lazy var panRecognizer: UIPanGestureRecognizer = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "userDidPan:")
        return panRecognizer
    }()
    var snapBehaviour: UISnapBehavior?
    var pushBehaviour: UIPushBehavior?
    var attachmentBehaviour: UIAttachmentBehavior?
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
            removeBehavioursForCurrentController()
        }
        
        currentViewController = delegate.viewControllerAtIndex(index)
        
        if let currentViewController = currentViewController {
            // Add to self
            currentViewController.willMoveToParentViewController(self)
            addChildViewController(currentViewController)
            view.addSubview(currentViewController.view)
            currentViewController.didMoveToParentViewController(self)
            addBehavioursToCurrentController()
        }
        
        index++
    }
    
    func removeBehavioursForCurrentController() {
        animator.removeBehavior(snapBehaviour)
        snapBehaviour = nil
        animator.removeBehavior(pushBehaviour)
        pushBehaviour = nil
    }
    
    func addBehavioursToCurrentController() {
        if let currentViewController = currentViewController {
            snapBehaviour = UISnapBehavior(item: currentViewController.view, snapToPoint: self.view.center)
            animator.addBehavior(snapBehaviour)
            
            pushBehaviour = UIPushBehavior(items: [currentViewController.view], mode: .Instantaneous)
            pushBehaviour!.magnitude = 0
            pushBehaviour!.angle = 0
            animator.addBehavior(pushBehaviour)
            
            currentViewController.view.addGestureRecognizer(panRecognizer)
        }
    }
    
    func checkForLastViewController() {
        if index == delegate.numberOfViewControllers() {
            self.presentingViewController?.dismissModalViewControllerAnimated(true)
        }
    }
    
    func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        // Many thanks to https://github.com/u10int/URBMediaFocusViewController
        let location = panRecognizer.locationInView(self.view)
        let boxLocation = panRecognizer.locationInView(self.currentViewController!.view)
        
        if (panRecognizer.state == .Began) {
            animator.removeBehavior(snapBehaviour)
            animator.removeBehavior(pushBehaviour)
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(self.currentViewController!.view.bounds), boxLocation.y - CGRectGetMidY(self.currentViewController!.view.bounds));
            attachmentBehaviour = UIAttachmentBehavior(item: self.currentViewController!.view, offsetFromCenter: centerOffset, attachedToAnchor: location)
            animator.addBehavior(attachmentBehaviour)
        } else if (panRecognizer.state == .Changed) {
            attachmentBehaviour!.anchorPoint = location
        } else if (panRecognizer.state == .Ended) {
            animator.removeBehavior(attachmentBehaviour)
            attachmentBehaviour = nil
            
            let runningOnPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
            // need to scale velocity values to tame down physics on the iPad
            let deviceVelocityScale = runningOnPad ? 0.2 : 1.0
            let deviceAngularScale = runningOnPad ? 0.7 : 1.0
            // factor to increase delay before `dismissAfterPush` is called on iPad to account for more area to cover to disappear
            let deviceDismissDelay = runningOnPad ? 1.8 : 1.0
            let velocity = panRecognizer.velocityInView(view)
            let velocityAdjust = 10.0 * deviceVelocityScale
            
            
            let minimumVelocityRequiredForPush = 50.0
            
            animator.addBehavior(snapBehaviour)
            animator.addBehavior(pushBehaviour)
        }
    }
}
