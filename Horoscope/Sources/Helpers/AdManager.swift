//
//  AdManager.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/6/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

class AdManager {
    static let sharedInstance = AdManager()
    var probability = 0.7
    func seed() -> Double {
        return drand48()
    }

    init() {
        let time = Int(NSDate().timeIntervalSince1970)
        srand48(time)
    }

    func showAdMaybe(viewController: UIViewController!) {
        if seed() < probability {
            let result = Appodeal.showAd(AppodealShowStyle.RewardedVideo, rootViewController: viewController)
            if !result {
                Appodeal.showAd(AppodealShowStyle.Interstitial, rootViewController: viewController)
            }
        }
    }
}
