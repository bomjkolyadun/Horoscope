//
//  HoroPickerViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/4/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

protocol HoroPickerDelegate {
    func horoPicker(picker: HoroPickerViewController, didPickItem item: HoroType, day: HoroDay)
}

class HoroPickerViewController: UIViewController {

    internal var day : HoroDay {
        didSet {
            self.updateButtons()
        }
    }
    internal var type : HoroType = .General
    
    internal var delegate: HoroPickerDelegate?

    @IBOutlet weak var secondButton: ZoomButton!
    @IBOutlet weak var firstButton: ZoomButton!

    required init?(coder aDecoder: NSCoder) {
        day = .Today
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateButtons()
    }

    func updateButtons() {
        switch day {
        case .Tomorrow :
            firstButton?.setImage(UIImage(named: "today"), forState: .Normal)
            firstButton.tag = HoroDay.Today.rawValue
            secondButton?.setImage(UIImage(named: "year"), forState: .Normal)
            secondButton.tag = HoroDay.Year.rawValue
        case .Today :
            firstButton?.setImage(UIImage(named: "tomorrow"), forState: .Normal)
            firstButton.tag = HoroDay.Tomorrow.rawValue
            secondButton?.setImage(UIImage(named: "year"), forState: .Normal)
            secondButton.tag = HoroDay.Year.rawValue
        default :
            firstButton?.setImage(UIImage(named: "today"), forState: .Normal)
            firstButton.tag = HoroDay.Today.rawValue
            secondButton?.setImage(UIImage(named: "tomorrow"), forState: .Normal)
            secondButton.tag = HoroDay.Tomorrow.rawValue
        }
    }

    @IBAction func typeAction(sender: AnyObject) {
        if let senderView = sender as? UIView {
            let tag = senderView.tag
            let newType = HoroType(rawValue: tag)!
            self.delegate?.horoPicker(self, didPickItem: newType, day: day)
        }
    }

    @IBAction func dateAction(sender: AnyObject) {
        if let senderView = sender as? UIView {
            let tag = senderView.tag
            let newDay = HoroDay(rawValue: tag)!
            self.delegate?.horoPicker(self, didPickItem: type, day: newDay)
        }
    }

}
