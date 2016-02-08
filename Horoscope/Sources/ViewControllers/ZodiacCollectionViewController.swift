//
//  ZodiacCollectionViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ZodiacCell"
private let detailSegue = "detailSegue"

class ZodiacCollectionViewController: HoroscopeCollectionViewController {

    var gender : Gender
    var pickedItem : HoroSign?

    required init?(coder aDecoder: NSCoder) {
        gender = .Male
        super.init(coder: aDecoder)
        images = ["z1", "z2", "z3", "z4", "z5", "z6", "z7", "z8", "z9", "z10", "z11", "z12"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout(self.traitCollection)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.isMovingToParentViewController() || self.isBeingPresented()) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutCells(self.view.transform)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == detailSegue && pickedItem != nil) {
            let destination = segue.destinationViewController as! SignDetailViewController
            let horoscopeObject = Horoscope(aGender: gender, aCategory: HoroCategory.General, aZodiac: pickedItem!, aType: HoroType.Today)
            destination.horoscope = horoscopeObject
        }
    }

    override func cellDidButtonAction(cell: ZodiacCell, sender: UIButton) {
        pickedItem = HoroSign(rawValue: sender.tag)
        self.performSegueWithIdentifier(detailSegue, sender: cell)
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        self.configureLayout(newCollection)
    }

    func configureLayout(newCollection: UITraitCollection) {
        let layout =  self.collectionViewLayout as! KRLCollectionViewGridLayout
        if newCollection.horizontalSizeClass == .Regular {
            layout.numberOfItemsPerLine = 4
        } else if newCollection.horizontalSizeClass == .Compact && newCollection.verticalSizeClass == .Compact {
            layout.numberOfItemsPerLine = 4
        } else {
            layout.numberOfItemsPerLine = 3
        }
    }

}
