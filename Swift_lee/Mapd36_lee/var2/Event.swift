//
//  Event.swift
//  Mapd36_lee
//
//  Created by student on 2022/2/27.
//

import Foundation

struct getDate{
    static var date = "date"
    static var dayCount = "dayCount"
}

struct getEvent{
    static var title = "title"
    static var note = "note"
    static let collection = "myEvent"
    static var date = "date"
    static var startdate = "startDate"
    static var enddate = "endDate"
}

class Event{
    var title: String?
    var note: String?
    var date: String?
    var startdate: String?
    var enddate: String?
}
