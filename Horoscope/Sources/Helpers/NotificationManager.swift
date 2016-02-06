//
//  NotificationManager.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/6/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

class NotificationManager {

    private let texts = ["Что тебя ждет сегодня? Начни своё утро со свежего гороскопа", "Что тебя ждет сегодня? Узнай из своего свежего гороскопа", "Что тебя ждет сегодня? Подробнее в твоем свежем гороскопе", "Что тебя ждет сегодня? Раскрой секрет дня в свежем гороскопе", "Как пройдет твой день? Начни своё утро со свежего гороскопа", "Как пройдет твой день? Узнай из своего свежего гороскопа", "Как пройдет твой день? Подробнее в твоем свежем гороскопе", "Как пройдет твой день? Раскрой секрет дня в свежем гороскопе", "Чего ждать сегодня? Начни своё утро со свежего гороскопа", "Чего ждать сегодня? Узнай из своего свежего гороскопа", "Чего ждать сегодня? Подробнее в твоем свежем гороскопе", "Чего ждать сегодня? Раскрой секрет дня в свежем гороскопе", "Какой этот день для тебя? Начни своё утро со свежего гороскопа", "Какой этот день для тебя? Узнай из своего свежего гороскопа", "Какой этот день для тебя? Подробнее в твоем свежем гороскопе", "Какой этот день для тебя? Раскрой секрет дня в свежем гороскопе"]

    let calendar = NSCalendar.currentCalendar()
    let date = NSDate()
    var scheduled = false

    static let sharedInstance = NotificationManager()

    func scheduleNotification(date: NSDate, text: String) {
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.fireDate = date
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertBody = text
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    func generateNotifications() {

        if scheduled {
            return
        }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let componentsForReferenceDate: NSDateComponents = calendar.components(([.Day, .Year, .Month, .Hour]), fromDate: date)
        componentsForReferenceDate.hour = 8
        componentsForReferenceDate.minute = 10
        componentsForReferenceDate.day--
        let referenceDate: NSDate = calendar.dateFromComponents(componentsForReferenceDate)!
        let length = UInt32(texts.count)
        for index in 0...63 {
            let text = texts[Int(arc4random_uniform(length))]
            let components = calendar.components(([.Hour, .Minute,]), fromDate: referenceDate)
            components.minute = Int(arc4random_uniform(59))
            components.day = index
            if let randomDate = calendar.dateByAddingComponents(components, toDate: date, options: .MatchNextTime) {
                scheduleNotification(randomDate, text: text)
            }
        }
        scheduled = true
    }
}
