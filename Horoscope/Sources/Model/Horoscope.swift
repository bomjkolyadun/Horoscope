//
//  Horoscope.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/6/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

internal let kModelChangeNotification = "modelChangeNotification"
internal let kModelChangeErrorNotification = "modelChangeErrorNotification"
internal let kModelErrorKey = "errorKey"

class Horoscope {

    var updateTask : NSURLSessionDataTask?
    var gender: Gender
    var category: HoroCategory
    var zodiac: HoroSign
    var type: HoroType
    let date = { () -> (String) in
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(NSDate())
    }
    var text: String?

    init(aGender: Gender, aCategory: HoroCategory, aZodiac: HoroSign, aType: HoroType) {
        gender = aGender
        category = aCategory
        zodiac = aZodiac
        type = aType
    }

    func notifyChange(error: NSError?) {
        if let err = error {
            NSNotificationCenter.defaultCenter().postNotificationName(kModelChangeErrorNotification, object: self, userInfo: [kModelErrorKey : err])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kModelChangeNotification, object: self, userInfo: nil)
        }

    }

    func update() {
        updateTask?.cancel()
        updateTask = RequestWrapper.sharedInstance.horoscope(gender, category: category, zodiac: zodiac, type: type, date: date(), successBlock: { (task : NSURLSessionDataTask, object : AnyObject) -> () in

            self.text = object["text"] as? String
            self.notifyChange(nil)
            }) { (task : NSURLSessionDataTask?, error : NSError) -> () in

                if error.code != NSURLErrorCancelled {
                    self.notifyChange(error)
                }
        }
    }
}
