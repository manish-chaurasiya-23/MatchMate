//
//  APIError.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case serverError
    case decodingError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed:
            return "The network request failed."
        case .serverError:
            return "Server returned an error."
        case .decodingError:
            return "Failed to decode the response data."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
