//
//  ContentView.swift
//  InternConnect
//


import SwiftUI
import SwiftData


struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        if viewModel.isLoggedIn, let currentUser = viewModel.currentUser {
            MainTabView(viewModel: viewModel, currentUser: currentUser)
        } else {
            LogInView(viewModel: viewModel)
        }
    }
}

// LOGIN VIEW
struct LogInView: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var interns: [Intern]

    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Sign In")
                        .font(.headline)
                        .bold()
                }

                Spacer()

                Text("Welcome to InternConnect!")
                    .font(.title)
                    .bold()

                Text("Tap In. Link Up. Level Up")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("Email*", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password*", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .bold()
                }

                Button("Sign In") {
                    if let user = interns.first(where: {
                        $0.email.lowercased() == email.lowercased()
                    }) {
                        if user.password == password {
                            viewModel.currentUser = user
                            viewModel.isLoggedIn = true
                            loginError = nil
                        } else {
                            loginError = "Incorrect password."
                        }
                    } else {
                        loginError = "No account found with that email."
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)

                NavigationLink("Create Account") {
                    CreateAccountView(viewModel: viewModel)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
        }
    }
}

// CREATE ACCOUNT
struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var interns: [Intern]

    @State private var name = ""
    @State private var company = ""
    @State private var location = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Sign Up")
                        .font(.headline)
                        .bold()
                }

                Spacer()

                Text("Join InternConnect!")
                    .font(.title)
                    .bold()

                TextField("Name*", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Company*", text: $company)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Location*", text: $location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email*", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password*", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Create Account") {
                    let newIntern = Intern( name: name,email: email, password: password, company: company, location: location)

                    modelContext.insert(newIntern)
                    try? modelContext.save()

                    viewModel.currentUser = newIntern
                    viewModel.isLoggedIn = true
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || company.isEmpty || location.isEmpty || email.isEmpty || password.isEmpty)
            }
            .padding()

            Spacer()
        }
    }
}

// MAIN TAB VIEW
struct MainTabView: View {
    @ObservedObject var viewModel: ViewModel
    var currentUser: Intern

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel, currentUser: currentUser)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            EventsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }

            NetworkView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Network")
                }

            ChatsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chats")
                }

            ProfileView(viewModel: viewModel, currentUser: currentUser)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .tint(.blue)
    }
}

// HEADER VIEW
struct DashboardHeader: View {
    var location: String
    var heading: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("InternConnect")
                    .font(.headline)
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Text(heading)
                .font(.title2)
                .bold()
                .foregroundColor(.blue)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// HOME VIEW
struct HomeView: View {
    @ObservedObject var viewModel: ViewModel
    var currentUser: Intern

    @Query private var events: [Event]
    @Query private var interns: [Intern]
    @Query private var groupChats: [GroupChat]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(location: currentUser.location, heading: "Welcome back, \(currentUser.name)!", subtitle: "Your Dashboard")

                VStack(spacing: 16) {
                    NavigationLink {
                        EventsView(viewModel: viewModel)
                    } label: {
                        DashboardCard(title: "My Events", subtitle: "Total events", value: "\(events.count)")
                    }

                    NavigationLink {
                        NetworkView(viewModel: viewModel)
                    } label: {
                        DashboardCard(title: "Connections", subtitle: "Interns", value: "\(interns.count - 1)")
                    }

                    NavigationLink {
                        ChatsView(viewModel: viewModel)
                    } label: {
                        DashboardCard(title: "Group Chats", subtitle: "Active groups", value: "\(groupChats.count)")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }

    struct DashboardCard: View {
        var title: String
        var subtitle: String
        var value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button("View all") {
                        // insert logic
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }

                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 2, y: 2)
        }
    }
}

// EVENTS VIEW
struct EventsView: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date) private var events: [Event]

    @State private var showingCreateSheet: Bool = false
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var location = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(location: "Phoenix, Arizona", heading: "Events", subtitle: "Here's what's happening")

                ScrollView {
                    Button("Create") {
                        showingCreateSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 30)
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .sheet(isPresented: $showingCreateSheet) {
                        VStack(spacing: 20) {
                            Text("Create Event")
                                .font(.title2)
                                .bold()

                            Text("Host a networking event for interns in Phoenix")
                                .font(.subheadline)

                            Text("Event Title")
                                .bold()

                            TextField("e.g. Coffee and Code", text: $title)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Text("Description")
                                .bold()

                            TextField("What's your event about?", text: $description)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            HStack(spacing: 10) {
                                VStack {
                                    Text("Date")
                                        .bold()

                                    DatePicker(
                                        "Date",
                                        selection: $date,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                }
                                .padding(.horizontal)

                                VStack {
                                    Text("Time")
                                        .bold()

                                    DatePicker(
                                        "",
                                        selection: $time,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                }
                                .padding(.horizontal)
                            }

                            Text("Location")
                                .bold()

                            TextField("e.g. Provision Coffee", text: $location)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            HStack {
                                Button("Cancel") {
                                    showingCreateSheet = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.black)
                                .cornerRadius(8)

                                Button("Create Event") {
                                    let newEvent = Event(title: title,description: description, date: date, time: time, location: location)

                                    modelContext.insert(newEvent)
                                    try? modelContext.save()

                                    title = ""
                                    description = ""
                                    date = Date()
                                    time = Date()
                                    location = ""

                                    showingCreateSheet = false
                                }
                                .disabled(title.isEmpty || description.isEmpty || location.isEmpty)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }

                    VStack(spacing: 16) {
                        ForEach(events) { event in
                            EventCard(
                                title: event.title,
                                dateTime: event.date,
                                location: event.location
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }

    struct EventCard: View {
        var title: String
        var dateTime: Date
        var location: String

        @State private var isRSVPed = false

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .bold()
                    Spacer()
                }

                Text(dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    isRSVPed.toggle()
                }) {
                    Text(isRSVPed ? "Cancel RSVP" : "RSVP")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(isRSVPed ? Color.white : Color.blue)
                        .foregroundColor(isRSVPed ? .blue : .white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 2, y: 2)
        }
    }
}

// NETWORK VIEW
struct NetworkView: View {
    @ObservedObject var viewModel: ViewModel

    @State private var searchText: String = ""
    @Query(sort: \Intern.name) private var interns: [Intern]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(location: "Phoenix, Arizona", heading: "Network", subtitle: "Connect with interns")

                ScrollView {
                    TextField("Search", text: $viewModel.internSearchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    let filteredInterns = viewModel.filteredInterns(interns)


                    VStack(spacing: 16) {
                        ForEach(filteredInterns) { intern in
                            InternCard(name: intern.name, company: intern.company)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    struct InternCard: View {
        var name: String
        var company: String

        var body: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    Text(company)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button("Message") {
                    // insert message functionality
                }
                .frame(width: 100, height: 30)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 2, y: 2)
        }
    }
}

// CHATS VIEW
struct ChatsView: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroupChat.name) private var groupChats: [GroupChat]

    @State private var showingCreateSheet: Bool = false
    @State private var searchText: String = ""
    @State private var name = ""
    @State private var description = ""
    
    private var filteredGroups: [GroupChat] {
            viewModel.filteredGroupChats(groupChats)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(location: "Phoenix, Arizona", heading: "Group Chats", subtitle: "Join interest-based communities")

                Button("Create") {
                    showingCreateSheet = true
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .padding(.horizontal, 30)
                .background(Color.cyan)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingCreateSheet) {
                    VStack(spacing: 20) {
                        Text("Create Group Chat")
                            .font(.title2)
                            .bold()

                        Text("Connect with interns based on interests")
                            .font(.subheadline)

                        Text("Group Name")
                            .bold()

                        TextField("e.g. Coffee Chat Crew", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        Text("Description")
                            .bold()

                        TextField("What's your group about?", text: $description)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        HStack {
                            Button("Cancel") {
                                showingCreateSheet = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.black)
                            .cornerRadius(8)

                            Button("Create Group") {
                                let newGroupChat = GroupChat(
                                    name: name,
                                    description: description,
                                    members: []
                                )

                                modelContext.insert(newGroupChat)
                                try? modelContext.save()

                                name = ""
                                description = ""
                                showingCreateSheet = false
                            }
                            .disabled(name.isEmpty || description.isEmpty)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                TextField("Search", text: $viewModel.groupChatSearchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

//                let filteredGroups = viewModel.filteredGroupChats(groupChats)

                List {
                    ForEach(filteredGroups) { group in
                        NavigationLink(destination: GroupChatDetailView(groupName: group.name)) {
                            GroupChatCell(groupName: group.name)
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            let group = filteredGroups[index]
            modelContext.delete(group)
        }
        try? modelContext.save()
    }
    
    struct GroupChatCell: View {
        var groupName: String

        @State private var isJoined: Bool = false

        var body: some View {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 50, height: 50)

                Text(groupName)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Button(action: {
                    isJoined.toggle()
                }) {
                    Text(isJoined ? "Unjoin" : "Join")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isJoined ? Color.white : Color.blue)
                        .foregroundColor(isJoined ? .blue : .white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: isJoined ? 1 : 0)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(0.10),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
    }

    struct GroupChatDetailView: View {
        var groupName: String

        var body: some View {
            Text("Welcome to \(groupName)")
                .font(.title)
                .navigationTitle(groupName)
        }
    }
}

// PROFILE VIEW
struct ProfileView: View {
    @ObservedObject var viewModel: ViewModel
    var currentUser: Intern

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(
                    location: currentUser.location,
                    heading: "Profile",
                    subtitle: "Your info"
                )

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Text(currentUser.name)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Company")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(currentUser.company)
                            .font(.body)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(currentUser.location)
                            .font(.body)
                    }

                    Button("Edit Profile") {
                        // insert edit profile logic
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.top, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 2, y: 2)
                .padding(.horizontal, 20)

                Button("Log Out") {
                    viewModel.currentUser = nil
                    viewModel.isLoggedIn = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.top, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

// PREVIEW
#Preview {
    ContentView()
        .modelContainer(for: [Intern.self, Event.self, GroupChat.self], inMemory: true)
}

