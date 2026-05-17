//
//  WebSocketManager.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class WebSocketManager {
    static let shared = WebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    // UI veya ViewModel'ların dinleyeceği reaktif alanlar
    var incomingMessage: MessageDTO?
    var incomingNotification: NotificationDTO?
    var isConnected: Bool = false
    
    private init() {}
    
    func connect(token: String) {
        guard !isConnected else { return }
        
        // http -> ws dönüşümü
        let wsBaseURL = NetworkManager.baseURL.replacingOccurrences(of: "http", with: "ws")
        guard let url = URL(string: "\(wsBaseURL)/ws?token=\(token)") else { return }
        
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        
        receiveLoop()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    private func receiveLoop() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                if self.isConnected {
                    self.receiveLoop() // Recursive dinleme
                }
            case .failure(let error):
                print("WebSocket Connection Error: \(error.localizedDescription)")
                Task { @MainActor in self.isConnected = false }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        Task { @MainActor in
            switch message {
            case .string(let text):
                if let data = text.data(using: .utf8) { self.decodeAndPublish(data) }
            case .data(let data):
                self.decodeAndPublish(data)
            @unknown default:
                break
            }
        }
    }
    
    private func decodeAndPublish(_ data: Data) {
        do {
            let event = try JSONDecoder().decode(WSEvent.self, from: data)
            switch event.payload {
            case .message(let msg):
                self.incomingMessage = msg
            case .notification(let notif):
                self.incomingNotification = notif
            case .unknown:
                break // Desteklenmeyen tip yutulur
            }
        } catch {
            print("WS Decoding Error: \(error.localizedDescription)")
        }
    }
}
