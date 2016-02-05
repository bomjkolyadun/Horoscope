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
private let kTypeTitles : [HoroType: String] = [.Carrier : "Карьерный", .Money : "Денежный", .Love : "Любовный", .Health : "Здоровье", .Family : "Семейный", .Teen : "Тинейджер"]
private let kDayTitles : [HoroDay: String] = [.Today : "сегодня", .Tomorrow : "завтра", .Year : "год "]
private let kSignTitles: [HoroSign: String] = [.Aries : "Овен", .Taurus : "Телец", .Gemini : "Близнецы", .Cancer : "Рак", .Leo : "Лев", .Virgo : "Дева", .Libra : "Весы", .Scorpio : "Скорпион", .Sagittarius : "Стрелец", .Capricorn : "Козерог", .Aquarius : "Водолей", .Pisces : "Рыбы"]

class SignDetailViewController: UITableViewController, HoroPickerDelegate {

    var horoSign : HoroSign = .Aries
    var horoType : HoroType = .General
    var horoDay : HoroDay = .Today
    var gender : Gender = .Male
    var horoPickerController : HoroPickerViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.horoPickerController?.day = horoDay
        self.horoPickerController?.type = horoType
        if (horoType == .General) {
            self.title = kSignTitles[horoSign]! + " на " + kDayTitles[horoDay]!
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRectZero);
            self.title = kTypeTitles[horoType]! + " на " + kDayTitles[horoDay]!
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
        cell.textLabel?.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedSegue {
            if let pickerController = segue.destinationViewController as? HoroPickerViewController {
                pickerController.delegate = self
                horoPickerController = pickerController
            }
        }
    }

    func horoPicker(picker: HoroPickerViewController, didPickItem item: HoroType, day : HoroDay) {
        if let detailController = self.storyboard?.instantiateViewControllerWithIdentifier(kSignDetailViewControllerId) as? SignDetailViewController {
            detailController.horoType = item
            detailController.horoDay = day
            detailController.horoSign = horoSign
            detailController.gender = gender
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
}
