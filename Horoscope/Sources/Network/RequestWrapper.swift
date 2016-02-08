//
//  RequestWrapper.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 2/5/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit

private let kHostName = "http://horoscopes.invk.org/"
private let kHoroscopePath = "api/v1/horoscope"

typealias SuccessBlock = (NSURLSessionDataTask, AnyObject?) -> ()
typealias FailtureBlock = (NSURLSessionDataTask?, NSError) -> ()

class RequestWrapper {

    static let sharedInstance = RequestWrapper()
    private let sessionManager = AFHTTPSessionManager(baseURL: NSURL(string: kHostName))

    init() {
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        sessionManager.requestSerializer = requestSerializer
        sessionManager.responseSerializer = AFJSONResponseSerializer()
    }

    func horoscope(sex: Gender, category: HoroCategory, zodiac: HoroSign, type: HoroType, date: String, successBlock: SuccessBlock, failtureBlock: FailtureBlock) -> NSURLSessionDataTask? {

        let params: [String: AnyObject] = ["sex" : sex.rawValue, "category_id" : category.rawValue, "zodiac_id" : zodiac.rawValue, "type" : type.rawValue, "date" : date]
        let task = sessionManager.GET(kHoroscopePath, parameters: params, success: successBlock, failure: failtureBlock)
        return task
    }
}
