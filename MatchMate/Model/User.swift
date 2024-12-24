//
//  User.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import Foundation

struct ApiResponse: Codable {
    let results: [User]
}

struct User: Codable {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let phone: String
    let picture: Picture
    var status: String?
    var dob: Dob?
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Dob: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let medium: String
}

