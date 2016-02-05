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
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .All
        let flowLayout: UICollectionViewFlowLayout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSizeMake(240, 160)
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

//    override func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize
//    {
//        return CGSizeMake(240, 160)
//    }

//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//
//        let cellCount: Int = collectionView.numberOfItemsInSection(section)
//        let cellSpacing: CGFloat = (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
//        let cellWidth: CGFloat = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
//        let viewWidth: CGFloat = self.view.frame.size.width
//        let viewHeight: CGFloat = self.view.frame.size.height
//        let totalCellWidth: CGFloat = cellWidth * CGFloat(cellCount)
//        let totalSpacingWidth: CGFloat = cellSpacing * CGFloat(cellCount - 1)
//        let leftInset: CGFloat = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset: CGFloat = leftInset
//        let topInset: CGFloat = (viewHeight - (totalCellWidth + totalSpacingWidth)) / 2
//        let bottomInset: CGFloat = topInset
//        return UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
//    }

}
