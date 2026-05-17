//
//  ChatView.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) private var appState
    @Bindable var viewModel: ChatViewModel // TextField bağlaması (binding) için
    @FocusState private var isInputFocused: Bool
    
    init(targetId: String, targetName: String) {
        _viewModel = Bindable(ChatViewModel(targetId: targetId, targetName: targetName))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    if viewModel.isLoading && viewModel.messages.isEmpty {
                        ProgressView().padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                // Gönderen targetId değilse, mesaj benimdir
                                let isCurrentUser = message.sender_id != viewModel.targetId
                                MessageBubble(message: message, isCurrentUser: isCurrentUser)
                                    .id(message.id)
                            }
                        }
                        .padding(Theme.spacing)
                    }
                }
                .background(Theme.background)
                .onTapGesture {
                    isInputFocused = false // Ekrana dokunulunca klavyeyi indir
                }
                // Mesaj listesi değiştiğinde veya ekran ilk açıldığında en alta kaydır
                .onChange(of: viewModel.messages) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
            }
            
            chatInputBar
        }
        .navigationTitle(viewModel.targetName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.messages.isEmpty {
                await viewModel.fetchHistory(token: appState.token)
            }
        }
        // 🚀 KRİTİK NOKTA: WebSocket üzerinden gelen anlık mesajı dinliyoruz
        .onChange(of: WebSocketManager.shared.incomingMessage) { _, incoming in
            if let newMsg = incoming {
                viewModel.handleIncomingWSMessage(newMsg)
            }
        }
    }
    
    private var chatInputBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Mesaj yaz...", text: $viewModel.messageText, axis: .vertical)
                .focused($isInputFocused)
                .lineLimit(1...5) // Metin uzadıkça dinamik büyüme (HIG)
                .padding(12)
                .background(Theme.surface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1)
                )
            
            Button {
                Task { await viewModel.sendMessage(token: appState.token) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Theme.textSecondary : Theme.primary)
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            .padding(.bottom, 6)
        }
        .padding(.horizontal, Theme.spacing)
        .padding(.vertical, 8)
        .background(Theme.background)
        .overlay(Rectangle().frame(height: Theme.borderWidth).foregroundColor(Theme.textSecondary.opacity(0.1)), alignment: .top)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastId = viewModel.messages.last?.id else { return }
        withAnimation {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
}

// KISS Prensibi: Alt Satır Bileşeni (Bubble)
fileprivate struct MessageBubble: View {
    let message: MessageDTO
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 40) }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(Theme.bodyFont)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isCurrentUser ? Theme.primary : Theme.surface)
                    .foregroundColor(isCurrentUser ? .white : Theme.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text(message.created_at)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser { Spacer(minLength: 40) }
        }
    }
}
