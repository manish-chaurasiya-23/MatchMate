//
//  UserViewModel.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import Foundation
import CoreData
import Combine

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    private let networkMonitor: NetworkMonitor
    private let apiManager: NetworkManager
    private let viewContext: NSManagedObjectContext
    
    init(networkMonitor: NetworkMonitor = NetworkMonitor(),
         apiManager: NetworkManager = .shared,
         viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.networkMonitor = networkMonitor
        self.apiManager = apiManager
        self.viewContext = viewContext
        observeNetworkChanges()
    }
    
    private func observeNetworkChanges() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if !isConnected {
                    self.fetchLocalUsers()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchUsers() {
        if !networkMonitor.isConnected {
            print("No internet connection, fetching local users.")
            fetchLocalUsers()
            return
        }
        print("Internet connected, fetching users from API.")
        apiManager.request(
            endpoint: "/api/?results=10",
            method: .GET,
            responseType: ApiResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let apiUsersWithPendingStatus = response.results.map { user -> User in
                        var mutableUser = user
                        mutableUser.status = MatchStatus.pending.rawValue
                        return mutableUser
                    }
                    self?.processUsers(apiUsers: apiUsersWithPendingStatus)
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func processUsers(apiUsers: [User]) {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
        do {
            let coreDataUsers = try viewContext.fetch(fetchRequest)
            let coreDataUsersDict: [String: Person] = Dictionary(
                uniqueKeysWithValues: coreDataUsers.compactMap { user in
                    guard let email = user.email else { return nil }
                    return (email, user)
                }
            )
            
            let mergedUsers = apiUsers.map { apiUser -> User in
                var modifiedUser = apiUser
                if let coreDataUser = coreDataUsersDict[apiUser.email] {
                    modifiedUser.status = coreDataUser.status ?? MatchStatus.pending.rawValue
                }
                return modifiedUser
            }
            
            self.users = mergedUsers
            
            for apiUser in apiUsers {
                if let coreDataUser = coreDataUsersDict[apiUser.email] {
                    coreDataUser.status = apiUser.status
                    coreDataUser.gender = apiUser.gender
                    coreDataUser.nameTitle = apiUser.name.title
                    coreDataUser.nameFirst = apiUser.name.first
                    coreDataUser.nameLast = apiUser.name.last
                    coreDataUser.city = apiUser.location.city
                    coreDataUser.state = apiUser.location.state
                    coreDataUser.country = apiUser.location.country
                    coreDataUser.email = apiUser.email
                    coreDataUser.phone = apiUser.phone
                    coreDataUser.profileImage = apiUser.picture.medium
                    coreDataUser.streetNumber = Int32(apiUser.location.street.number)
                    coreDataUser.streetName = apiUser.location.street.name
                } else {
                    let newUser = Person(context: viewContext)
                    newUser.status = apiUser.status
                    newUser.gender = apiUser.gender
                    newUser.nameTitle = apiUser.name.title
                    newUser.nameFirst = apiUser.name.first
                    newUser.nameLast = apiUser.name.last
                    newUser.city = apiUser.location.city
                    newUser.state = apiUser.location.state
                    newUser.country = apiUser.location.country
                    newUser.email = apiUser.email
                    newUser.phone = apiUser.phone
                    newUser.profileImage = apiUser.picture.medium
                    newUser.streetNumber = Int32(apiUser.location.street.number)
                    newUser.streetName = apiUser.location.street.name
                }
            }
            
            try viewContext.save()
            
        } catch {
            print("Failed to fetch or save users in Core Data: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch or save data in Core Data."
        }
    }
    
    func fetchLocalUsers() {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            self.users = users.map { person in
                User(gender: person.gender ?? "",
                     name: Name(title: person.nameTitle ?? "", first: person.nameFirst ?? "", last: person.nameLast ?? ""),
                     location: Location(street: Street(number: Int(person.streetNumber), name: person.streetName ?? ""),
                                        city: person.city ?? "", state: person.state ?? "", country: person.country ?? ""),
                     email: person.email ?? "",
                     phone: person.phone ?? "",
                     picture: Picture(medium: person.profileImage ?? ""),
                     status: person.status ?? "")
            }
        } catch {
            self.errorMessage = "Failed to fetch local users: \(error.localizedDescription)"
        }
    }
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            self.errorMessage = apiError.localizedDescription
        } else {
            self.errorMessage = "An unexpected error occurred."
        }
    }
}
