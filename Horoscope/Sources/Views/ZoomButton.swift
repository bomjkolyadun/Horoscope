//
//  ZoomButton.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

class ZoomButton: UIButton {

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if (event?.type == .Touches) {
            UIView.animateWithDuration(0.1, delay: 0.0, options: .BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { (finished : Bool) -> Void in
                    if (!finished) {
                        self.transform = CGAffineTransformIdentity
                    }
            })
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }

    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if (event?.type == .Touches) {
            UIView.animateWithDuration(0.1, delay: 0.0, options: .BeginFromCurrentState, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (finished : Bool) -> Void in
                    if (!finished) {
                        self.transform = CGAffineTransformIdentity
                    }
            })

        }
    }

}
