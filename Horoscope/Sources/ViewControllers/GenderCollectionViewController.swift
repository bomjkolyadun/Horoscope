//
//  GenderViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private var kZodiacSegueIdentifier = "zodiacSegue"

class GenderCollectionViewController: HoroscopeCollectionViewController {
    var pickedItem : Gender?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        images = ["male", "female"]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kZodiacSegueIdentifier {
            let destination = segue.destinationViewController as! ZodiacCollectionViewController
            destination.gender = pickedItem!
        }
    }

    override func cellDidButtonAction(cell: ZodiacCell, sender: UIButton) {
        pickedItem = Gender(rawValue: sender.tag)
        self.performSegueWithIdentifier(kZodiacSegueIdentifier, sender: cell)
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        self.configureLayout(newCollection)
    }

    func configureLayout(newCollection: UITraitCollection) {
        let layout =  self.collectionViewLayout as! KRLCollectionViewGridLayout
        if newCollection.horizontalSizeClass == .Regular {
            layout.numberOfItemsPerLine = 2
        } else if newCollection.horizontalSizeClass == .Compact && newCollection.verticalSizeClass == .Compact {
            layout.numberOfItemsPerLine = 2
        } else {
            layout.numberOfItemsPerLine = 1
        }
    }
}
