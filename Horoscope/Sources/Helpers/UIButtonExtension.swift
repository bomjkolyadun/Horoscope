//
//  UIButtonExtension.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

extension UIButton {
    private struct AssociatedKeys {
        static var StringTagKey = "hrs_stringTag"
    }

    var stringTag : String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.StringTagKey) as? String
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.StringTagKey,
                newValue as NSString?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}