//
//  HoroscopeCollectionViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private let padding : CGFloat = 10.0
private let numberOfItems : CGFloat = 3.0
private let reuseIdentifier = "ZodiacCell"

class HoroscopeCollectionViewController: UICollectionViewController, ZodiacCellDelegate {

    internal var images : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        self.collectionView!.registerClass(ZodiacCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.backgroundColor = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        let layout =  self.collectionViewLayout as! KRLCollectionViewGridLayout
        layout.interitemSpacing = 0.0
        layout.lineSpacing = 0.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutCells(self.view.transform)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ZodiacCell
        let index = indexPath.item
        let image = UIImage.init(named: images[index])
        cell.button.setImage(image, forState: .Normal)
        cell.button.tag = index + 1
        cell.delegate = self
        return cell
    }

    func cellDidButtonAction(cell: ZodiacCell, sender: UIButton) {
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func prefersStatusBarHidden() -> Bool {
        return false;
    }

    func layoutCells(transform : CGAffineTransform) {

        guard let collectionView = self.collectionView
            else { return }
        let size = CGRectApplyAffineTransform(collectionView.frame, transform).size
        let layout =  self.collectionViewLayout as! KRLCollectionViewGridLayout
        let count = self.images.count
        let itemsInRow = layout.numberOfItemsPerLine
        let rows = count / itemsInRow + count % itemsInRow
        layout.aspectRatio = size.width / size.height * CGFloat(rows)/CGFloat(itemsInRow)
    }
}
