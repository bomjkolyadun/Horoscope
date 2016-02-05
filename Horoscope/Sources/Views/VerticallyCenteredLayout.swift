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
            let diff: CGFloat = self.collectionView!.frame.size.height - lastY
            if diff > 0 {
                let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(diff / 2, 0.0, 0.0, 0.0)
                self.collectionView!.contentInset = contentInsets
            }
        }
        return array
    }

}
