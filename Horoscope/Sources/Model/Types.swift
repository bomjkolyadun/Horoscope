//
//  Types.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/25/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import Foundation

enum HoroDay : Int {
    case Today = 1
    case Tomorrow
    case Year
}

enum Gender : Int {
    case Male = 0
    case Female
}


enum HoroType : Int {
    case General = 0
    case Carrier
    case Money
    case Love
    case Health
    case Family
    case Teen
}

enum HoroSign : Int {
    case Aries = 0
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
