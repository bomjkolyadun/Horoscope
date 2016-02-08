//
//  SignDetailViewController.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private let kTextCellIdentifier = "TextCell"
private let kEmbedSegue = "embedSegue"
private let kSignDetailViewControllerId = "SignDetailViewController"
private let kTypeTitles : [HoroCategory: String] = [.Carrier : "Карьерный", .Money : "Денежный", .Love : "Любовный", .Health : "Здоровье", .Family : "Семейный", .Teen : "Тинейджер"]
private let kDayTitles : [HoroType: String] = [.Today : "сегодня", .Tomorrow : "завтра", .Year : "год "]
private let kSignTitles: [HoroSign: String] = [.Aries : "Овен", .Taurus : "Телец", .Gemini : "Близнецы", .Cancer : "Рак", .Leo : "Лев", .Virgo : "Дева", .Libra : "Весы", .Scorpio : "Скорпион", .Sagittarius : "Стрелец", .Capricorn : "Козерог", .Aquarius : "Водолей", .Pisces : "Рыбы"]

class SignDetailViewController: UITableViewController, PickerDelegate {

    var horoPickerController : PickerColelctionViewController?
    var horoscope : Horoscope? {
        willSet {
            guard let object = horoscope
                else {return}
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kModelChangeNotification, object: object)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: kModelChangeErrorNotification, object: object)
        }

        didSet {
            guard let object = horoscope
                else {return}
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateData:", name:kModelChangeNotification, object: object)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateError:", name:kModelChangeErrorNotification, object: object)
            refresh(self)
        }
    }

    func updateData(note: NSNotification) {
        self.tableView.beginUpdates()
        let firstRow = NSIndexPath(forRow: 0, inSection: 0);
        self.tableView.reloadRowsAtIndexPaths([firstRow], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
        refreshControl?.endRefreshing()
    }

    func updateError(note: NSNotification) {
        if let _ = horoscope?.text {

        } else {
            guard let error = note.userInfo?[kModelErrorKey] as? NSError
                else {return}
            let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (alertAction: UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        refreshControl?.endRefreshing()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.tableView.addSubview(refreshControl)
    }

    func refresh(sender: AnyObject) {
        refreshControl?.beginRefreshing()
        horoscope?.update()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let object = horoscope
            else {return}
        self.horoPickerController?.type = object.type
        self.horoPickerController?.category = object.category
        if (object.category == .General) {
            self.title = kSignTitles[object.zodiac]! + " на " + kDayTitles[object.type]!
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRectZero);
            self.title = kTypeTitles[object.category]! + " на " + kDayTitles[object.type]!
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.isMovingFromParentViewController()){
            guard let object = horoscope
                else {return}
            if (object.category != .General) {
                AdManager.sharedInstance.showAdMaybe(self.navigationController)
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(kTextCellIdentifier, forIndexPath: indexPath)
        if self.traitCollection.userInterfaceIdiom == .Pad {
            cell.layoutMargins = UIEdgeInsetsMake(30.0, 100.0, 30.0, 100.0)
            cell.textLabel?.font = UIFont.systemFontOfSize(24.0)
        }
        if let text = horoscope?.text {
            cell.textLabel?.text = text
        } else {
            cell.textLabel?.text = nil
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedSegue {
            if let pickerController = segue.destinationViewController as? PickerColelctionViewController {
                pickerController.delegate = self
                horoPickerController = pickerController
            }
        }
    }

    func picker(picker: PickerColelctionViewController, didPickCategory item: HoroCategory, type day: HoroType) {
        guard let horoscopeObject = horoscope
            else {return}

        if let detailController = self.storyboard?.instantiateViewControllerWithIdentifier(kSignDetailViewControllerId) as? SignDetailViewController {

            let horoscopeObject = Horoscope(aGender: horoscopeObject.gender, aCategory: item, aZodiac: horoscopeObject.zodiac, aType: day)
            detailController.horoscope = horoscopeObject
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func prefersStatusBarHidden() -> Bool {
        return false;
    }
    
}
