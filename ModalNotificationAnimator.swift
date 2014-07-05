//
//  ModalNotificationAnimator.swift
//  Modal Notification Controller
//
//  Created by Ash Furrow on 2014-07-05.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class ModalNotificationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool
    
    init(presenting: Bool = false) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning!) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning!) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        if (presenting) {
            fromViewController.view.userInteractionEnabled = false
            
            containerView.backgroundColor = UIColor.blackColor()
            
            toViewController.view.alpha = 0.0
            toViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            
            containerView.addSubview(fromViewController.view)
            containerView.addSubview(toViewController.view)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                toViewController.view.transform = CGAffineTransformIdentity
                toViewController.view.alpha = 1.0
                fromViewController.view.alpha = 0.5
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        } else {
            toViewController.view.userInteractionEnabled = true
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(fromViewController.view)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                toViewController.view.alpha = 1.0
                fromViewController.view.alpha = 0.0
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
