//
//  ProfileCardView.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI

enum MatchStatus: String, Codable {
    case accepted = "Accepted"
    case declined = "Declined"
    case pending = "Pending"
}

struct ProfileCard: View {
    let user: User
    @Environment(\.managedObjectContext) private var viewContext
    @State private var actionTaken: MatchStatus.RawValue
    
    init(user: User) {
        self.user = user
        _actionTaken = State(initialValue: user.status ?? "Pending")  // Initialize user's status
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Profile Image
            WebImage(url: URL(string: user.picture.medium)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )

            // User Info
            VStack(spacing: 10) {
                Text("\(user.name.title) \(user.name.first) \(user.name.last)")
                    .font(.headline)
                
                Text("\(user.location.city), \(user.location.state), \(user.location.country)")
                    .font(.subheadline)
            }
            .padding(.horizontal, 30)
            .multilineTextAlignment(.center)
            
            // Like and Dislike Buttons
            if actionTaken == MatchStatus.pending.rawValue {
                HStack {
                    Button(action: {
                        actionTaken = MatchStatus.accepted.rawValue
                        updateUserStatus(user: user, status: MatchStatus.accepted.rawValue)
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 50))
                                .overlay {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        actionTaken = MatchStatus.declined.rawValue
                        updateUserStatus(user: user, status: MatchStatus.declined.rawValue)
                    }) {
                        VStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 50))
                                .overlay {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 2)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
            } else {
                VStack {
                    Text(actionTaken)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                }
                .background(actionTaken == MatchStatus.accepted.rawValue ? .green : .red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func updateUserStatus(user: User, status: String) {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
        // Fetch Person object based on the email
        fetchRequest.predicate = NSPredicate(format: "email == %@", user.email)
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            if let existingUser = users.first {
                // If user exists, update the status
                existingUser.status = status
            } else {
                // If user does not exist, create a new Person object
                let newUser = Person(context: viewContext)
                newUser.status = status
            }
            
            try viewContext.save()
        } catch {
            print("Error updating user status: \(error.localizedDescription)")
        }
    }
}
