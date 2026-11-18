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
    case yearly = "com.camerafilm.pro.yearly"
    case lifetime = "com.camerafilm.pro.lifetime"
    case monthly = "com.camerafilm.pro.monthly"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yearly: "Yearly Access"
        case .lifetime: "Lifetime Access"
        case .monthly: "Monthly Access"
        }
    }

    var defaultPriceString: String {
        switch self {
        case .yearly: "$19.99 / year"
        case .lifetime: "$49.99 once"
        case .monthly: "$2.99 / month"
        }
    }

    var subtitle: String {
        switch self {
        case .yearly: "Just $1.66/month, billed annually"
        case .lifetime: "Pay once, keep forever"
        case .monthly: "Flexible monthly billing"
        }
    }

    var badge: String? {
        switch self {
        case .yearly: "MOST POPULAR"
        case .lifetime: "BEST VALUE"
        case .monthly: nil
        }
    }
}

/// Manages In-App Purchases, StoreKit 2 transactions, and Pro status / film emulation quotas.
@Observable
final class ProStore: @unchecked Sendable {
    static let shared = ProStore()

    /// Free quota of photos using film simulations per roll.
    static let freeFilmQuotaPerRoll: Int = 3

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
    }

    private init() {
        self.isPro = UserDefaults.standard.bool(forKey: Keys.isPro)
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

    /// Number of photos in the current roll that used film emulsions (i.e. not "Original").
    func filmShotsCountInCurrentRoll() -> Int {
        FilmRollStore.shared.photos.filter { $0.filmName != "Original" }.count
    }

    /// Remaining free shots for the current roll when shooting with film emulsions.
    var remainingFreeFilmShots: Int {
        if isPro { return Int.max }
        let used = filmShotsCountInCurrentRoll()
        return max(0, Self.freeFilmQuotaPerRoll - used)
    }

    /// Determines if a photo can be taken with the chosen film simulation.
    func canShoot(withFilmID filmID: String?) -> Bool {
        // "Original" profile is always 100% free and unlimited
        guard filmID != nil else { return true }
        if isPro { return true }
        return filmShotsCountInCurrentRoll() < Self.freeFilmQuotaPerRoll
    }

    // MARK: - StoreKit 2 Fetching & Purchasing

    @MainActor
    func fetchProducts() async {
        do {
            let productIDs = ProPlanType.allCases.map(\.rawValue)
            let fetched = try await Product.products(for: productIDs)
            self.products = fetched.sorted { p1, p2 in
                // Order: Yearly, Lifetime, Monthly
                if p1.id == ProPlanType.yearly.rawValue { return true }
                if p2.id == ProPlanType.yearly.rawValue { return false }
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
