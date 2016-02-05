//
//  EmbedSegue.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

class EmbedSegue: UIStoryboardSegue {
    override func perform() {
        let containerViewController = sourceViewController.parentViewController
        sourceViewController.willMoveToParentViewController(containerViewController)
        containerViewController!.addChildViewController(destinationViewController)
        containerViewController!.transitionFromViewController(sourceViewController, toViewController: destinationViewController, duration: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
            }, completion: {(finished: Bool) -> Void in
                self.sourceViewController.removeFromParentViewController()
                containerViewController!.addChildViewController(self.destinationViewController)
        })
    }
}
