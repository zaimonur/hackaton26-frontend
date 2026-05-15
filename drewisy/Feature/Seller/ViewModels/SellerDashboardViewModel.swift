//
//  SellerDashboardViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import Foundation
import Observation

@Observable
final class SellerDashboardViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var period: String = "monthly"
    var dashboardData: SalesDashboardResponse? = nil
    
    // AI İş Analisti State'leri
    var aiSummary: String? = nil
    var isFetchingAI: Bool = false
    
    @MainActor
    func loadData(token: String?) async {
        guard let token = token else { return }
        isLoading = true
        errorMessage = nil
        let url = "\(NetworkManager.baseURL)/api/v1/seller/dashboard/sales?period=\(period)"
        do {
            let response: SalesDashboardResponse = try await NetworkManager.shared.request(
                url: url,
                method: "GET",
                body: String?.none,
                token: token
            )
            self.dashboardData = response
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Sunucuya bağlanırken bir hata oluştu."
        }
        isLoading = false
    }
    
    // AI Summary Fetch Metodu
    @MainActor
    func fetchAISummary(token: String?) async {
        guard let token = token else { return }
        isFetchingAI = true
        aiSummary = nil // Yeni istekte eskiyi temizle
        
        let url = "\(NetworkManager.baseURL)/api/v1/seller/dashboard/ai-summary"
        
        do {
            let response: AIDashboardSummaryResponse = try await NetworkManager.shared.request(
                url: url,
                method: "GET",
                body: String?.none,
                token: token
            )
            self.aiSummary = response.summary
        } catch {
            print("AI Summary Error: \(error.localizedDescription)")
            self.aiSummary = "İş analizi şu an oluşturulamadı. Lütfen daha sonra tekrar deneyin."
        }
        isFetchingAI = false
    }
}
