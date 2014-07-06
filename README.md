ModalNotificationController
===========================

This is a demonstration of how to present Slingshot-style notification using Swift. Developed at the [SwiftCrunch](http://swiftcrunch.com) hackathon. A work-in-progress. 

The Goal
----------------

My goal is to recreate the [Facebook Slingshot](https://itunes.apple.com/ca/app/slingshot/id878681557?mt=8) notification UI. This is different from other designs in that it presents an arbitrary number of things that can be dismissed by "flicking" them offscreen. Here's what it looks like:

![Facebook Slingshot](http://cloud.ashfurrow.com/image/2p2u2f1E2w3K/goal.gif)

OK, cool. So how do we do this?

Approach
----------------

This project depends on the custom UIViewController transition API introduced in iOS 7 (this means it doesn't really work for landscape orientation :cry:). What's key is that I want to display *arbitrary content* in my notifications – not just images. 

After presenting the `ModalNotificationViewController`, that controller will query its delegate about the number of view controllers to be presented. Then, it will ask for each view controller in sequence. Once the view controllers have been exhausted, it will dismiss itself. 

Current Status
----------------

This is still a work-in-progress. Here's what we've got so far.

![Screenshot](http://f.cl.ly/items/13341h0v0V242Z1a1s0i/2014-07-05%2021_06_32.gif)

How to Use
----------------

You need two files to use this library: `ModalNotificationAnimator.swift` and `ModalNotificationViewController.swift`. You also need [Scalar Arithmetic](https://github.com/seivan/ScalarArithmetic), at least for now until Apple fixes Swift. 

To use the library, you want to present the modal notification view controller, but it's not that simple. 

```swift
let viewController = ModalNotificationViewController(delegate: self)
viewController.transitioningDelegate = self;
viewController.modalPresentationStyle = .Custom;
presentViewController(viewController, animated: true, completion: nil)
```

Here we're using a custom view controller transition. You'll need to conform to the `UIViewControllerTransitioningDelegate` protocol and implement these two methods:

```swift
func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
    return ModalNotificationAnimator(presenting: true)
}

func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
    return ModalNotificationAnimator()
}
```

You'll also need to provide a delegate to the modal view controller. In this example, it's `self`, so you need to conform to the `ModalNotificationViewControllerDelegate` protocol. That means you'll need to implement these two methods:

```swift
func numberOfViewControllers() -> Int  {
    return /* however many view controllers to present */
}

func viewControllerAtIndex(index: UInt) -> UIViewController {
    /* vend a view controller to present */
}
```

Just be careful that the view controller you vend back doesn't have a conflicting gesture recognizer, or else you'll never be able to dismiss it!