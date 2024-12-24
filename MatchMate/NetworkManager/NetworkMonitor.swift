//
//  NetworkMonitor.swift
//  MatchMate
//
//  Created by Manish Kumar on 24/12/24.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published var isConnected: Bool = true

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.checkInternetConnection()
            } else {
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }

    private func checkInternetConnection() {
        guard let url = URL(string: "https://www.google.com") else {
            DispatchQueue.main.async {
                self.isConnected = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                self.isConnected = (response as? HTTPURLResponse)?.statusCode == 200 && error == nil
            }
        }.resume()
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
