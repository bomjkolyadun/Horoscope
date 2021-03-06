//
//  ZodiacCell.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

protocol ZodiacCellDelegate: NSObjectProtocol {
    func cellDidButtonAction(cell: ZodiacCell, sender: UIButton)
}

class ZodiacCell: UICollectionViewCell {

    internal weak var delegate: ZodiacCellDelegate?
    @IBOutlet weak var button: UIButton!

    @IBAction func buttonAction(sender: UIButton) {
        self.delegate?.cellDidButtonAction(self, sender: sender)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let cellButton = ZoomButton(type: .Custom)
        cellButton.adjustsImageWhenHighlighted = false
        cellButton.frame = self.contentView.bounds
        cellButton.imageView?.contentMode = .ScaleAspectFit
        cellButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        cellButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(cellButton)
        button = cellButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        button.stringTag = nil
        button.tag = 0
    }
}
