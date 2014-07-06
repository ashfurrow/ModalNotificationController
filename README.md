ModalNotificationController
===========================

This is a demonstration of how to present Slingshot-style notification using Swift. Developed at the [SwiftCrunch](http://swiftcrunch.com) hackathon. 

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

Mostly done. I'll turn it into a CocoaPod once [CocoaPods supports Swift](https://github.com/CocoaPods/CocoaPods/pull/2222). 

![Screenshot](http://cloud.ashfurrow.com/image/2M2V1h3H2g0e/2014-07-06%2012_00_37.gif)

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

Workarounds
----------------

Two radars were filed in the making of this project (made on iOS 8 Beta 2):

- [UIWindow view hierarchy disappears when dismissing view controller with custom presentation](http://openradar.appspot.com/radar?id=5320103646199808)
- [Cannot reference unowned object conforming to protocol](http://openradar.appspot.com/radar?id=5300501415460864)

Credits
----------------

My special thanks to [Nicholas Shipes](https://github.com/u10int) for his work on [URBMediaFocusViewController](https://github.com/u10int/URBMediaFocusViewController), which provided the base for my gesture recognizer code. 

Also thanks to [Seivan Heidari](https://github.com/seivan) for their work on [Scalar Arithmetic](https://github.com/seivan/ScalarArithmetic).

License
----------------

Copyright (c) Ash Furrow, 2014

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
