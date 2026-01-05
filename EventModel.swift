//
//  EventModel.swift
//  InternConnect
//


import Foundation
import SwiftData

@Model
class Event {
    var title: String
    var desc: String
    var date: Date
    var time: Date
    var location: String

    init(title: String, description: String, date: Date, time: Date, location: String) {
        self.title = title
        self.desc = description
        self.date = date
        self.time = time
        self.location = location
    }
}
