//
//  ContentView.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.users.isEmpty {
                    userList
                } else if let errorMessage = viewModel.errorMessage {
                    errorMessageView(message: errorMessage)
                } else {
                    loadingView
                }
            }
            .navigationTitle("MatchMate")
        }
        .onAppear {
                viewModel.fetchUsers()
        }
    }
    
    private var userList: some View {
        ScrollView {
            ForEach(viewModel.users, id: \.email) { user in
                ProfileCard(user: user)
                    .padding()
            }
        }
    }
    
    private func errorMessageView(message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var loadingView: some View {
        ProgressView("Fetching Users...")
    }
}
