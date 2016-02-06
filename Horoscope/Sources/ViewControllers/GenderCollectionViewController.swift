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

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout: UICollectionViewFlowLayout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSizeMake(230, 160)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isBeingPresented() || isMovingToParentViewController()) {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (isBeingDismissed() || isMovingFromParentViewController()) {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
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

}
