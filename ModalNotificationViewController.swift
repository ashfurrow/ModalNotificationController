//
//  ModalNotificationViewController.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-05.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

@objc protocol ModalNotificationViewControllerDelegate: NSObjectProtocol {
    func numberOfViewControllers () -> Int
    func viewControllerAtIndex(index: UInt) -> UIViewController
}

class ModalNotificationViewController: UIViewController {
    weak var delegate: ModalNotificationViewControllerDelegate?
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
    var itemBehaviour: UIDynamicItemBehavior?
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
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.blackColor()
    }

    func addNextViewController(animated: Bool = false) {
        if let currentViewController = currentViewController {
            currentViewController.willMoveToParentViewController(nil)
            currentViewController.removeFromParentViewController()
            currentViewController.view.removeFromSuperview()
            currentViewController.didMoveToParentViewController(nil)
            removeBehavioursForCurrentController()
        }
        
        currentViewController = delegate?.viewControllerAtIndex(index)
        
        if let currentViewController = currentViewController {
            // Add to self
            currentViewController.willMoveToParentViewController(self)
            addChildViewController(currentViewController)
            view.addSubview(currentViewController.view)
            currentViewController.didMoveToParentViewController(self)
            addBehavioursToCurrentController()
            
            if (animated) {
                currentViewController.view.alpha = 0.0
                UIView.animateWithDuration(0.3, animations: {
                    currentViewController.view.alpha = 1.0
                })
            }
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
            
            itemBehaviour = UIDynamicItemBehavior(items: [currentViewController.view])
            animator.addBehavior(itemBehaviour)
            
            currentViewController.view.addGestureRecognizer(panRecognizer)
        }
    }
    
    func checkForLastViewController() {
        if index == delegate!.numberOfViewControllers() + 1 {
            self.presentingViewController?.dismissModalViewControllerAnimated(true)
        }
    }
    
    func userDidPan(panRecognizer: UIPanGestureRecognizer) {
        // Many thanks to https://github.com/u10int/URBMediaFocusViewController
        let location = panRecognizer.locationInView(view)
        let boxLocation = panRecognizer.locationInView(currentViewController!.view)
        
        if (panRecognizer.state == .Began) {
            animator.removeBehavior(snapBehaviour)
            animator.removeBehavior(pushBehaviour)
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(currentViewController!.view.bounds), boxLocation.y - CGRectGetMidY(currentViewController!.view.bounds));
            attachmentBehaviour = UIAttachmentBehavior(item: currentViewController!.view, offsetFromCenter: centerOffset, attachedToAnchor: location)
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
            
            let shouldDismiss = abs(velocity.x / velocityAdjust) > minimumVelocityRequiredForPush || abs(velocity.y / velocityAdjust) > minimumVelocityRequiredForPush
            if shouldDismiss {
                let offsetFromCenter = UIOffsetMake(boxLocation.x - CGRectGetMidX(currentViewController!.view.bounds), boxLocation.y - CGRectGetMidY(currentViewController!.view.bounds))
                let radius = sqrtf(powf(Float(offsetFromCenter.horizontal), 2.0) + powf(Float(offsetFromCenter.vertical), 2.0))
                let pushVelocity = sqrtf(powf(Float(velocity.x), 2.0) + powf(Float(velocity.y), 2.0))
                
                // calculate angles needed for angular velocity formula
                let velocityAngle = atan2f(Float(velocity.y), Float(velocity.x))
                var locationAngle = atan2f(Float(offsetFromCenter.vertical), Float(offsetFromCenter.horizontal))
                if (locationAngle > 0) {
                    locationAngle -= Float(M_PI * 2.0)
                }
                
                // angle (θ) is the angle between the push vector (V) and vector component parallel to radius, so it should always be positive
                let angle = fabsf(fabsf(velocityAngle) - fabsf(locationAngle))
                // angular velocity formula: w = (abs(V) * sin(θ)) / abs(r)
                var angularVelocity = Float(fabsf((fabsf(pushVelocity) * sinf(angle)) / fabsf(radius)))
                
                // rotation direction is dependent upon which corner was pushed relative to the center of the view
                // when velocity.y is positive, pushes to the right of center rotate clockwise, left is counterclockwise
                var direction = Float((location.x < view.center.x) ? -1.0 : 1.0);
                // when y component of velocity is negative, reverse direction
                if (velocity.y < 0) { direction *= -1; }
                
                // amount of angular velocity should be relative to how close to the edge of the view the force originated
                // angular velocity is reduced the closer to the center the force is applied
                // for angular velocity: positive = clockwise, negative = counterclockwise
                let xRatioFromCenter = fabsf(Float(offsetFromCenter.horizontal)) / (Float(CGRectGetWidth(currentViewController!.view.frame)) / 2.0)
                let yRatioFromCetner = fabsf(Float(offsetFromCenter.vertical)) / (Float(CGRectGetHeight(currentViewController!.view.frame)) / 2.0)
                
                // apply device scale to angular velocity
                angularVelocity *= Float(deviceAngularScale)
                // adjust angular velocity based on distance from center, force applied farther towards the edges gets more spin
                angularVelocity *= (xRatioFromCenter + yRatioFromCetner) / 2.0
                
                itemBehaviour!.addAngularVelocity(CGFloat(angularVelocity * direction), forItem: currentViewController!.view)
                animator.addBehavior(pushBehaviour)
                pushBehaviour!.pushDirection = CGVectorMake(CGFloat(velocity.x / velocityAdjust), CGFloat(velocity.y / velocityAdjust))
                pushBehaviour!.active = true
                
                let maximumDismissDelay: Float = 0.5
                let delay = CGFloat(maximumDismissDelay - (Float(pushVelocity) / 10000.0))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    self.addNextViewController(animated: true)
                });
                
            } else {
                animator.addBehavior(snapBehaviour)
                animator.addBehavior(pushBehaviour)
            }
        }
    }
}
