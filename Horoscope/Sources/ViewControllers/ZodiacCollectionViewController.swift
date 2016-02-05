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
        let flowLayout: UICollectionViewFlowLayout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSizeMake(100, 100)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == detailSegue && pickedItem != nil) {
            let destination = segue.destinationViewController as! SignDetailViewController
            destination.horoSign = pickedItem!
            destination.horoType = .General
            destination.horoDay = .Today
        }
    }

    override func cellDidButtonAction(cell: ZodiacCell, sender: UIButton) {
        pickedItem = HoroSign(rawValue: sender.tag)
        self.performSegueWithIdentifier(detailSegue, sender: cell)
    }

//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        // Add inset to the collection view if there are not enough cells to fill the width.
//        let cellSpacing: CGFloat = (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
//        let cellWidth: CGFloat = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
//        let cellCount: Int = collectionView.numberOfItemsInSection(section)
//        var inset: CGFloat = (collectionView.bounds.size.width - (CGFloat(cellCount) * (cellWidth + cellSpacing))) * 0.5
//        inset = max(inset, 0.0)
//        return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0)
//    }


}
