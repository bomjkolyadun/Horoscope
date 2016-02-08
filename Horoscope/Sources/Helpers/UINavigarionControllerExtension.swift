//
//  UINavigarionControllerExtension.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/6/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

extension UINavigationController {

    public override func childViewControllerForStatusBarStyle() -> UIViewController {
        return self.topViewController!
    }

    public override func childViewControllerForStatusBarHidden() -> UIViewController {
        return self.topViewController!
    }
}
