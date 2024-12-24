# MatchMate App

This is an iOS app that simulates a Matrimonial App by displaying match cards (match
cards should be developed in SwiftUI) similar to Shaadi.com's card format. The app should
use the provided API to fetch user data and display it in SwiftUI List. Users can accept or
decline matches, and the app should store and display their decisions persistently, even in
offline mode.

## Installation

1. **Clone the Repository**:

```bash
git clone https://github.com/manish-chaurasiya-23/MatchMate
```
## Features
- **Accept/Decline Feature**: Allows users to accept or decline profiles, updating the status of each profile accordingly.
- **Network Monitoring**: Detects when the device is online or offline using a network monitor.
- **API Integration**: Fetches user data from a RESTful API when connected to the internet.
- **Core Data Integration**: Stores users locally in Core Data for offline access.
- **Error Handling**: Displays error messages when something goes wrong during the API request or Core Data operations.
- **Seamless Synchronization**: Merges data fetched from the API with existing data stored in Core Data, maintaining consistency.

## Project File Structure

```bash
MatchMateApp/
├── MatchMateApp.xcodeproj/        # Xcode project file
├── MatchMateApp.xcworkspace/      # Xcode workspace file                              
├── Sources/
│   ├── Models/
│   │   ├── User.swift                   # User model
│   │   ├── CoreDataModels/
│   │   │   └── Person+CoreDataClass.swift
│   │   │   └── Person+CoreDataProperties.swift
│   ├── ViewModels/
│   │   └── UserViewModel.swift          # Observable ViewModel for managing user data
│   ├── NetworkManager/
│   │   ├── NetworkManager.swift         # API interaction logic
│   │   ├── NetworkMonitor.swift         # Network status monitoring
│   └── Persistence/
│       └── PersistenceController.swift  # Core Data setup and management
├── Views/
│   ├── ContentView.swift               # SwiftUI view for displaying the list of users
│   ├── ProfileCard.swift               # SwiftUI view for each user cell
│   
├── Resources/
│   ├── Assets.xcassets/                 # Image and asset catalog
│   └── LaunchScreen.storyboard          # App launch screen storyboard
├── Tests/
│   ├── MatchMateAppAppTests/          # Unit tests
│   └── MatchMateAppAppUITests/        # UI tests
├── README.md                            # Project documentation

```

## Libraries and Frameworks Used

- **Combine**: Used for reactive programming, to observe network connectivity and handle asynchronous events.
- **Core Data**: Used to persist user data locally.
Foundation**: Standard library for networking and other fundamental operations.
- **SwiftUI**: Used for building the app’s UI.
- **SDWebImageSwiftUI**: A SwiftUI-compatible image caching library used to load and cache images efficiently.
- **NetworkManager**: Custom class used to make network requests and handle API responses.
- **PersistenceController**: Custom class for managing the Core Data stack.

### Prerequisites

1. **Xcode**: Make sure you have the latest version of Xcode installed.
2. **Swift Version**: This project is compatible with Swift 5.0 and later.

### Description
The MatchMate app is a user-centric application designed to fetch, display, and manage user profiles seamlessly, both online and offline. It combines modern networking, reactive programming, and local data persistence to ensure a smooth user experience. The app fetches user data from a RESTful API when connected to the internet, and it seamlessly synchronizes and stores this data in Core Data for offline access.

Key features include the ability to accept or decline user profiles, dynamic updates of user statuses, efficient image caching, and robust error handling for uninterrupted functionality. The app leverages SwiftUI for an elegant and intuitive user interface, ensuring users can browse profiles effortlessly and interact with them dynamically.

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.
