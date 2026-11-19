//
//  ProPaywallView.swift
//  CameraFilmApps
//

import SwiftUI
import StoreKit

/// Full-screen Pro upgrade paywall displaying authentic analog film features and subscriptions.
struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var proStore
    private var langManager = LanguageManager.shared

    @State private var selectedPlan: ProPlanType = .lifetime

    var body: some View {
        ZStack {
            // Dark analog camera body aesthetic
            Color(red: 0.08, green: 0.08, blue: 0.09)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Bar
                headerBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Quota limit banner (if shots exhausted)
                        if proStore.remainingFreeShots <= 0 {
                            quotaExceededBanner
                        }

                        // Hero Visuals
                        heroSection

                        // Features List
                        featuresList

                        // Plan Selector
                        plansSelectionView

                        // Main CTA Purchase Button
                        actionButton

                        // Terms & Restore Purchases
                        footerView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 36)
                }
            }
        }
        .onChange(of: proStore.isPro) { _, isPro in
            if isPro {
                dismiss()
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(8)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 6)
    }

    // MARK: - Quota Banner

    private var quotaExceededBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 0.98, green: 0.75, blue: 0.25))
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text(langManager.text(.freeLimitBanner(ProStore.maxFreeShots)))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(langManager.text(.unlimitedShooting))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.25, green: 0.16, blue: 0.05).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.95, green: 0.72, blue: 0.35).opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: "crown.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.85, blue: 0.45),
                                Color(red: 0.95, green: 0.65, blue: 0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.5), radius: 8, y: 3)
            }

            Text(langManager.text(.unlockFilmPro))
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(langManager.text(.unlimitedShooting))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Features List

    private var featuresList: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                FilmCanisterIconView(isSelected: true)
                    .scaleEffect(0.95)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(langManager.text(.allAnalogFilms))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(langManager.text(.allAnalogFilmsDesc))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.65))
                }
                Spacer()
            }
            featureRow(
                icon: "rectangle.split.3x1",
                title: langManager.text(.filmstripBorders),
                subtitle: langManager.text(.filmstripBordersDesc)
            )
            featureRow(
                icon: "sparkles",
                title: langManager.text(.maxHdQuality),
                subtitle: langManager.text(.maxHdQualityDesc)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.95, green: 0.72, blue: 0.35))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.65))
            }
            Spacer()
        }
    }

    // MARK: - Plans Selection

    private var plansSelectionView: some View {
        VStack(spacing: 10) {
            ForEach(ProPlanType.allCases) { plan in
                planCard(plan: plan, isSelected: selectedPlan == plan)
            }
        }
    }

    private func planCard(plan: ProPlanType, isSelected: Bool) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            selectedPlan = plan
        } label: {
            HStack(spacing: 14) {
                // Radio indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color(red: 0.95, green: 0.72, blue: 0.35) : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.95, green: 0.72, blue: 0.35))
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(plan.title(using: langManager))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if let badge = plan.badge(using: langManager) {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.95, green: 0.72, blue: 0.35))
                                .clipShape(.capsule)
                        }
                    }

                    Text(plan.subtitle(using: langManager))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.6))
                }

                Spacer()

                // Price (English default: Rp 99.000 / Rp 19.000 / Month or localized App Store price)
                let priceText = proStore.products.first(where: { $0.id == plan.rawValue })?.displayPrice ?? plan.defaultPriceString
                Text(priceText)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? Color(red: 0.95, green: 0.72, blue: 0.35) : .white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color(red: 0.95, green: 0.72, blue: 0.35) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action CTA Button

    private var actionButton: some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    _ = await proStore.purchase(selectedPlan)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.78, blue: 0.40),
                                    Color(red: 0.85, green: 0.58, blue: 0.20)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 52)
                        .shadow(color: Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.4), radius: 10, y: 4)

                    if proStore.isPurchasing {
                        ProgressView()
                            .tint(.black)
                    } else {
                        HStack(spacing: 8) {
                            Text(langManager.text(.upgradeToFilmPro))
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.9))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.black.opacity(0.9))
                        }
                    }
                }
            }
            .disabled(proStore.isPurchasing)

            if let error = proStore.errorMessage {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.red.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await proStore.restorePurchases()
                }
            } label: {
                Text(langManager.text(.restorePurchases))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(Color.white.opacity(0.7))
            .disabled(proStore.isRestoring)

            Text(langManager.text(.subscriptionTerms))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Developer Testing Toggle (Quickly toggle Pro state for live testing)
            Button {
                proStore.toggleProForTesting()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 10))
                    Text(proStore.isPro ? "Debug: Switch to Free (Test Limits)" : "Debug: Activate Pro Instant")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Color.orange.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.06))
                .clipShape(.capsule)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    ProPaywallView()
        .environment(ProStore.shared)
}
