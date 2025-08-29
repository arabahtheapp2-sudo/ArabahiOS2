//
//  NotificationCellModel.swift
//  ARABAH
//
//  Created by cqlm2 on 23/06/25.
//

import Foundation

struct NotificationCellModel {
    let title: String
    let description: String
    let time: String
    let imageURL: String
    let productID: String

    init(body: GetNotificationModalBody, baseURL: String, isArabic: Bool) {
        self.title = (body.message ?? "").replacingOccurrences(of: PlaceHolderTitleRegex.productNewPriceUpdate, with: "")
        self.description = isArabic ? (body.description_Arabic ?? "") : (body.description ?? "")
        self.imageURL = baseURL + (body.image ?? "")
        self.productID = body.productID ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let dateString = body.createdAt, let date = dateFormatter.date(from: dateString) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = isArabic ? Locale(identifier: "ar") : Locale(identifier: "en")
            dateFormatter.dateFormat = "hh:mm a"
            self.time = dateFormatter.string(from: date)
        } else {
            self.time = ""
        }
    }
}
