//
//  VerticallyCenteredLayout.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

class VerticallyCenteredLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?  {
        let array: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect)!
        if let att = array.last {
            let lastY: CGFloat = att.frame.origin.y + att.frame.size.height
            //let lastX: CGFloat = att.frame.origin.x + att.frame.size.width
            let diffY: CGFloat = self.collectionView!.frame.size.height - lastY
            //let diffX: CGFloat = self.collectionView!.frame.size.width - lastX
            let oldInsets = self.collectionView!.contentInset
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake((diffY > 0 ? diffY / 2.0 : oldInsets.top), /*(diffX > 0 ? diffX / 2.0 : oldInsets.left)*/ 0.0, oldInsets.bottom, oldInsets.right)
            self.collectionView!.contentInset = contentInsets
        }
        return array
    }

}
