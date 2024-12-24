//
//  NetworkManager.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError: Error {
    case badURL
    case requestFailed
    case invalidResponse
    case decodingError
    case serverError
}

class NetworkManager {

    static let shared = NetworkManager()

    private let baseURL = "https://randomuser.me"

    private let session = URLSession.shared

    private init() {}

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {

        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.badURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch {
                completion(.failure(.requestFailed))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Request error: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(.serverError))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

