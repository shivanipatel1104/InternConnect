//
//  ViewModel.swift
//  InternConnect
//


import Foundation
internal import Combine

class ViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: Intern?
    
    @Published var internSearchText: String = ""
    @Published var groupChatSearchText: String = ""
    
    
    func filteredInterns(_ interns: [Intern]) -> [Intern] {
        interns.filter { intern in
            internSearchText.isEmpty || intern.name.localizedCaseInsensitiveContains(internSearchText) || intern.company.localizedCaseInsensitiveContains(internSearchText)
        }
    }
    
    func filteredGroupChats(_ groups: [GroupChat]) -> [GroupChat] {
        groups.filter { group in
            groupChatSearchText.isEmpty ||
            group.name.localizedCaseInsensitiveContains(groupChatSearchText) ||
            group.desc.localizedCaseInsensitiveContains(groupChatSearchText)
        }
    }

}
