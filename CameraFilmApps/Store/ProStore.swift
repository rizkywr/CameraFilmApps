//
//  ProStore.swift
//  CameraFilmApps
//

import Foundation
import Observation
import StoreKit
import SwiftUI

/// Plan options for Film Camera Pro
enum ProPlanType: String, CaseIterable, Identifiable {
    case lifetime = "com.camerafilm.pro.lifetime"
    case monthly = "com.camerafilm.pro.monthly"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lifetime: "Lifetime Purchase"
        case .monthly: "Monthly Subscription"
        }
    }

    var defaultPriceString: String {
        switch self {
        case .lifetime: "Rp 99.000"
        case .monthly: "Rp 19.000 / Bulan"
        }
    }

    var subtitle: String {
        switch self {
        case .lifetime: "Bayar sekali, miliki selamanya"
        case .monthly: "Langganan bulanan fleksibel, batalkan kapan saja"
        }
    }

    var badge: String? {
        switch self {
        case .lifetime: "BEST VALUE"
        case .monthly: nil
        }
    }
}

/// Manages In-App Purchases, StoreKit 2 transactions, and Pro status / film emulation quotas.
@Observable
final class ProStore: @unchecked Sendable {
    static let shared = ProStore()

    /// Free quota of photos across all films before requiring Pro upgrade.
    static let maxFreeShots: Int = 25

    /// True if user owns active Pro entitlement (subscription or lifetime)
    private(set) var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: Keys.isPro)
        }
    }

    private(set) var products: [Product] = []
    private(set) var isPurchasing: Bool = false
    private(set) var isRestoring: Bool = false
    var errorMessage: String? = nil

    private var transactionListenerTask: Task<Void, Never>?
    private enum Keys {
        static let isPro = "com.camerafilm.isPro"
        static let totalCapturedCount = "com.camerafilm.totalCapturedCount"
    }

    /// Total photos captured across all films in app history
    private(set) var totalCapturedCount: Int {
        didSet {
            UserDefaults.standard.set(totalCapturedCount, forKey: Keys.totalCapturedCount)
        }
    }

    private init() {
        self.isPro = UserDefaults.standard.bool(forKey: Keys.isPro)
        self.totalCapturedCount = UserDefaults.standard.integer(forKey: Keys.totalCapturedCount)
        self.transactionListenerTask = listenForTransactions()

        Task {
            await updatePurchasedStatus()
            await fetchProducts()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Quota & Entitlement Helpers

    /// Records a captured shot toward the 25-shot free quota.
    func recordShotTaken() {
        guard !isPro else { return }
        totalCapturedCount += 1
    }

    /// Remaining free shots before requiring Pro upgrade.
    var remainingFreeShots: Int {
        if isPro { return Int.max }
        return max(0, Self.maxFreeShots - totalCapturedCount)
    }

    /// Determines if a photo can be taken across all films.
    var canShoot: Bool {
        if isPro { return true }
        return totalCapturedCount < Self.maxFreeShots
    }

    // MARK: - StoreKit 2 Fetching & Purchasing

    @MainActor
    func fetchProducts() async {
        do {
            let productIDs = ProPlanType.allCases.map(\.rawValue)
            let fetched = try await Product.products(for: productIDs)
            self.products = fetched.sorted { p1, p2 in
                // Order: Lifetime first, then Monthly
                if p1.id == ProPlanType.lifetime.rawValue { return true }
                return false
            }
        } catch {
            print("Failed to fetch StoreKit products: \(error)")
        }
    }

    @MainActor
    func purchase(_ plan: ProPlanType) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        // If StoreKit product is available from App Store
        if let storeProduct = products.first(where: { $0.id == plan.rawValue }) {
            do {
                let result = try await storeProduct.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        await updatePurchasedStatus()
                        let impact = UINotificationFeedbackGenerator()
                        impact.notificationOccurred(.success)
                        return true
                    case .unverified(_, let error):
                        self.errorMessage = error.localizedDescription
                        return false
                    }
                case .userCancelled:
                    return false
                case .pending:
                    return false
                @unknown default:
                    return false
                }
            } catch {
                self.errorMessage = error.localizedDescription
                return false
            }
        } else {
            // Local Sandbox / Test purchase fallback when StoreKit config is offline or in development
            try? await Task.sleep(for: .milliseconds(700))
            self.isPro = true
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.success)
            return true
        }
    }

    @MainActor
    func restorePurchases() async {
        isRestoring = true
        errorMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(isPro ? .success : .warning)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    /// Toggle for developer testing & demoing paywall / free limits
    func toggleProForTesting() {
        self.isPro.toggle()
    }

    // MARK: - Transaction Verification & Entitlements

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedStatus()
                }
            }
        }
    }

    @MainActor
    func updatePurchasedStatus() async {
        var hasActivePro = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProPlanType.allCases.map(\.rawValue).contains(transaction.productID) {
                    if transaction.revocationDate == nil {
                        hasActivePro = true
                    }
                }
            }
        }

        // If verified by StoreKit, mark pro. (Keeps local test pro if already set)
        if hasActivePro {
            self.isPro = true
        }
    }
}
