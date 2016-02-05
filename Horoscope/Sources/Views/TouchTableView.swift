//
//  TouchTableView.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/4/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

class TouchTableView: UITableView {

    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if let _ = view as? UIButton {
            return false
        } else {
            return self.canCancelContentTouches
        }
    }
}
