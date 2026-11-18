//
//  ProPaywallView.swift
//  CameraFilmApps
//

import SwiftUI
import StoreKit

/// Full-screen vintage analog themed Paywall for Film Camera PRO.
struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var proStore = ProStore.shared
    @State private var selectedPlan: ProPlanType = .lifetime

    var body: some View {
        ZStack {
            // Retro Darkroom textured background
            Color(red: 0.08, green: 0.08, blue: 0.09)
                .ignoresSafeArea()

            // Subtle warm analog golden glow from top
            RadialGradient(
                colors: [
                    Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.18),
                    Color.clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header & Close Button
                    headerSection

                    // Quota notification if user hit 3-shot limit
                    if proStore.totalCapturedCount >= ProStore.maxFreeShots {
                        quotaReachedBanner
                    }

                    // Feature highlights list
                    featuresList

                    // Plan selection cards
                    plansSelectionView

                    // Main Action CTA Button
                    actionButton

                    // Footer links
                    footerView
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 36)
            }
        }
        .onChange(of: proStore.isPro) { _, isPro in
            if isPro {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
            }

            // Golden PRO Badge
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.95, green: 0.72, blue: 0.35),
                                Color(red: 0.70, green: 0.45, blue: 0.15)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 36
                        )
                    )
                    .frame(width: 68, height: 68)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5)
                    )
                    .shadow(color: Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.5), radius: 16)

                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.black.opacity(0.85))
            }

            Text("Film Camera Pro")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color(white: 0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .tracking(1.5)

            Text("Capture authentic analog memories with unlimited film stocks and master-level controls.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Quota Banner

    private var quotaReachedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "film.stack")
                .font(.system(size: 22))
                .foregroundStyle(Color(red: 0.95, green: 0.72, blue: 0.35))

            VStack(alignment: .leading, spacing: 2) {
                Text("Free Limit Reached (25/25)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Kamu sudah menggunakan 25 kali jepret gratis. Upgrade ke Pro untuk menikmati foto analog tanpa batas!")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(red: 0.95, green: 0.72, blue: 0.35).opacity(0.5), lineWidth: 1)
                )
        )
    }

    // MARK: - Features List

    private var featuresList: some View {
        VStack(spacing: 12) {
            featureRow(
                icon: "infinity",
                title: "Unlimited Film Captures",
                subtitle: "Nikmati jepretan tanpa batas selamanya tanpa batasan 25 foto."
            )
            featureRow(
                icon: "film",
                title: "All 200+ Authentic Film Stocks",
                subtitle: "Full library of Kodak Portra, Tri-X, Velvia, Ektachrome & more."
            )
            featureRow(
                icon: "slider.horizontal.3",
                title: "Full Analog Adjustments",
                subtitle: "Fine-tune halation bloom, grain size, warmth, and contrast."
            )
            featureRow(
                icon: "sparkles",
                title: "Maximum HD & RAW Quality",
                subtitle: "Save full sensor resolution with preserved analog grain detail."
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
                        Text(plan.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.95, green: 0.72, blue: 0.35))
                                .clipShape(.capsule)
                        }
                    }

                    Text(plan.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.6))
                }

                Spacer()

                // Price
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
                            Text("Upgrade To Film Pro")
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
                Text("Restore Purchases")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(Color.white.opacity(0.7))
            .disabled(proStore.isRestoring)

            Text("Auto-renewable subscriptions can be cancelled anytime in App Store account settings.")
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
}
