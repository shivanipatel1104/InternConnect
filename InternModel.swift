//
//  InternModel.swift
//  InternConnect
//

import Foundation
import SwiftData

@Model
class Intern {
    var name: String
    @Attribute(.unique) var email: String
    var password: String
    var company: String
    var location: String

    init(name: String, email: String, password: String, company: String, location: String) {
        self.name = name
        self.email = email
        self.password = password
        self.company = company
        self.location = location
    }
}

