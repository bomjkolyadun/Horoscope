//
//  ZodiacCollectionViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ZodiacCell"
private let padding : CGFloat = 10.0
private let numberOfItems : CGFloat = 3.0

private let detailSegue = "detailSegue"

class ZodiacCollectionViewController: UICollectionViewController, ZodiacCellDelegate {

    var gender : Gender
    var images : [String] = ["z1", "z2", "z3", "z4", "z5", "z6", "z7", "z8", "z9", "z10", "z11", "z12"]
    var pickedItem : Int

    required init?(coder aDecoder: NSCoder) {
        gender = .Male
        pickedItem = -1
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ZodiacCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == detailSegue && pickedItem >= 0) {
            let destination = segue.destinationViewController as! SignDetailViewController
            destination.signIdentifier = pickedItem
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ZodiacCell
        let index = indexPath.item
        let image = UIImage.init(named: images[index])
        cell.button.setImage(image, forState: .Normal)
        cell.button.tag = index
        cell.delegate = self
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize
    {
        return CGSizeMake(floor((self.view.frame.width - padding)/numberOfItems), floor((self.view.frame.width - padding)/numberOfItems))
    }

    func cellDidButtonAction(cell: ZodiacCell, sender: UIButton) {
        pickedItem = sender.tag
        self.performSegueWithIdentifier(detailSegue, sender: cell)
    }

}
