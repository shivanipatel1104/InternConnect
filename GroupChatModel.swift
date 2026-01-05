//
//  GroupChatModel.swift
//  InternConnect
//


import Foundation
import SwiftData

@Model
final class GroupChat {
    var name: String
    var desc: String
    var members: [String]

    init(name: String, description: String, members: [String]) {
        self.name = name
        self.desc = description
        self.members = members
    }
}

