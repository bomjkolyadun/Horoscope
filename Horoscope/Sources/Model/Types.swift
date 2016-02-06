//
//  Types.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

enum HoroType : String {
    case Today = "today"
    case Tomorrow = "tomorrow"
    case Year = "yearly"
}

enum Gender : Int {
    case Male = 1
    case Female
}


enum HoroCategory : Int {
    case General = 1
    case Carrier
    case Money
    case Love
    case Health
    case Family
    case Teen
}

enum HoroSign : Int {
    case Aries = 1
    case Taurus
    case Gemini
    case Cancer
    case Leo
    case Virgo
    case Libra
    case Scorpio
    case Sagittarius
    case Capricorn
    case Aquarius
    case Pisces
}
