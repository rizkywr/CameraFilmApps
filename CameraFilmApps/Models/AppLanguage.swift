//
//  AppLanguage.swift
//  CameraFilmApps
//

import Foundation
import SwiftUI

/// Supported languages for CameraFilmApps in App Store and in-app settings
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    case indonesian = "id"
    case korean = "ko"
    case portuguese = "pt"
    case spanish = "es"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .indonesian: return "Bahasa Indonesia"
        case .korean: return "한국어"
        case .portuguese: return "Português"
        case .spanish: return "Español"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .french: return "🇫🇷"
        case .indonesian: return "🇮🇩"
        case .korean: return "🇰🇷"
        case .portuguese: return "🇧🇷"
        case .spanish: return "🇪🇸"
        }
    }
}

/// Central Localization Manager allowing in-app language switching with English default
@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private enum Keys {
        static let selectedLanguage = "com.camerafilm.selectedLanguage"
    }

    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Keys.selectedLanguage)
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Keys.selectedLanguage),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Default is strictly English
            self.currentLanguage = .english
        }
    }

    /// Retrieve localized string for a given translation key
    func text(_ key: LocalizationKey) -> String {
        return key.translation(for: currentLanguage)
    }
}

/// Strongly typed localization keys across the app
enum LocalizationKey {
    // Tabs & Navigation
    case tabSkin
    case tabFrame
    case tabFilm
    case tabLight
    case tabColor
    case tabEffects
    case tabSettings

    // Studio Calibration
    case studioCalibration
    case reset
    case done
    case close
    case select
    case save
    case saveAll
    case delete
    case deleteAll
    case selectedCount(Int)

    // Language Settings
    case language
    case appLanguage
    case selectLanguageDescription

    // Paywall & Monetization
    case unlockFilmPro
    case unlimitedShooting
    case allAnalogFilms
    case allAnalogFilmsDesc
    case filmstripBorders
    case filmstripBordersDesc
    case maxHdQuality
    case maxHdQualityDesc
    case lifetimePurchase
    case lifetimeSubtitle
    case monthlySubscription
    case monthlySubtitle
    case bestValue
    case upgradeToFilmPro
    case restorePurchases
    case subscriptionTerms
    case freeLimitBanner(Int)
    case shotsRemaining(Int)

    // Film Roll Review
    case filmRollReview
    case rollFrames(Int)
    case noFramesCaptured
    case noFramesDesc
    case savedToGallery(Int)
    case saveFailed
    case saved
    case expLimit(Int)

    func translation(for lang: AppLanguage) -> String {
        switch lang {
        case .english:
            return englishText
        case .french:
            return frenchText
        case .indonesian:
            return indonesianText
        case .korean:
            return koreanText
        case .portuguese:
            return portugueseText
        case .spanish:
            return spanishText
        }
    }

    private var englishText: String {
        switch self {
        case .tabSkin: return "Skin"
        case .tabFrame: return "Frame"
        case .tabFilm: return "Film"
        case .tabLight: return "Light"
        case .tabColor: return "Color"
        case .tabEffects: return "Effects"
        case .tabSettings: return "Settings"
        case .studioCalibration: return "Studio Calibration"
        case .reset: return "Reset"
        case .done: return "Done"
        case .close: return "Close"
        case .select: return "Select"
        case .save: return "Save"
        case .saveAll: return "Save All"
        case .delete: return "Delete"
        case .deleteAll: return "Delete All"
        case .selectedCount(let count): return "\(count) Selected"
        case .language: return "Language"
        case .appLanguage: return "App Language"
        case .selectLanguageDescription: return "Select your preferred application language."
        case .unlockFilmPro: return "Unlock Film Camera Pro"
        case .unlimitedShooting: return "Unlimited analog frames & authentic film simulations."
        case .allAnalogFilms: return "All Analog Film Rolls"
        case .allAnalogFilmsDesc: return "Access 200+ legendary 35mm, medium format & color slide stocks."
        case .filmstripBorders: return "35mm Negative Filmstrip Frames"
        case .filmstripBordersDesc: return "Authentic sprocket perforations and exposure edge codes."
        case .maxHdQuality: return "Maximum HD & RAW Quality"
        case .maxHdQualityDesc: return "Save full sensor resolution with preserved analog grain detail."
        case .lifetimePurchase: return "Lifetime Purchase"
        case .lifetimeSubtitle: return "Pay once, own forever"
        case .monthlySubscription: return "Monthly Subscription"
        case .monthlySubtitle: return "Flexible monthly billing, cancel anytime"
        case .bestValue: return "BEST VALUE"
        case .upgradeToFilmPro: return "Upgrade To Film Pro"
        case .restorePurchases: return "Restore Purchases"
        case .subscriptionTerms: return "Auto-renewable subscriptions can be cancelled anytime in App Store account settings."
        case .freeLimitBanner(let count): return "Free Limit Reached (\(count) Shots)"
        case .shotsRemaining(let count): return "\(count) Shots Left"
        case .filmRollReview: return "Film Roll Review"
        case .rollFrames(let count): return "Roll #01 • \(count) Frames"
        case .noFramesCaptured: return "No Frames Captured"
        case .noFramesDesc: return "Photos taken with the camera will appear here on your film roll."
        case .savedToGallery(let count): return "\(count) Photo\(count > 1 ? "s" : "") Saved To Gallery"
        case .saveFailed: return "Save Failed"
        case .saved: return "Saved"
        case .expLimit(let count): return "\(count) EXP"
        }
    }

    private var frenchText: String {
        switch self {
        case .tabSkin: return "Boîtier"
        case .tabFrame: return "Cadre"
        case .tabFilm: return "Pellicule"
        case .tabLight: return "Lumière"
        case .tabColor: return "Couleur"
        case .tabEffects: return "Effets"
        case .tabSettings: return "Réglages"
        case .studioCalibration: return "Étalonnage Studio"
        case .reset: return "Réinitialiser"
        case .done: return "Terminé"
        case .close: return "Fermer"
        case .select: return "Sélectionner"
        case .save: return "Enregistrer"
        case .saveAll: return "Tout Enregistrer"
        case .delete: return "Supprimer"
        case .deleteAll: return "Tout Supprimer"
        case .selectedCount(let count): return "\(count) Sélectionné(s)"
        case .language: return "Langue"
        case .appLanguage: return "Langue de l'application"
        case .selectLanguageDescription: return "Choisissez votre langue d'affichage préférée."
        case .unlockFilmPro: return "Débloquer Film Camera Pro"
        case .unlimitedShooting: return "Prises illimitées et émulations de pellicules argentiques authentiques."
        case .allAnalogFilms: return "Toutes les Pellicules Argentiques"
        case .allAnalogFilmsDesc: return "Accès à plus de 200 pellicules 35mm et moyen format légendaires."
        case .filmstripBorders: return "Bordures Négatives 35mm"
        case .filmstripBordersDesc: return "Perforations authentiques et marquages de marge d'émulsion."
        case .maxHdQuality: return "Qualité Maximale HD et RAW"
        case .maxHdQualityDesc: return "Résolution native du capteur avec grain argentique préservé."
        case .lifetimePurchase: return "Achat Définitif"
        case .lifetimeSubtitle: return "Payez une fois, conservez pour toujours"
        case .monthlySubscription: return "Abonnement Mensuel"
        case .monthlySubtitle: return "Facturation mensuelle flexible, résiliable à tout moment"
        case .bestValue: return "MEILLEURE OFFRE"
        case .upgradeToFilmPro: return "Passer à Film Pro"
        case .restorePurchases: return "Restaurer les Achats"
        case .subscriptionTerms: return "Les abonnements renouvelables automatiquement peuvent être résiliés à tout moment dans les réglages de l'App Store."
        case .freeLimitBanner(let count): return "Limite Gratuite Atteinte (\(count) Prises)"
        case .shotsRemaining(let count): return "\(count) Prises Restantes"
        case .filmRollReview: return "Pellicule en Cours"
        case .rollFrames(let count): return "Rouleau #01 • \(count) Prises"
        case .noFramesCaptured: return "Aucune Photo Capturée"
        case .noFramesDesc: return "Les photos prises avec l'appareil apparaîtront ici sur votre rouleau."
        case .savedToGallery(let count): return "\(count) Photo\(count > 1 ? "s" : "") Enregistrée(s)"
        case .saveFailed: return "Échec de l'enregistrement"
        case .saved: return "Enregistré"
        case .expLimit(let count): return "\(count) EXP"
        }
    }

    private var indonesianText: String {
        switch self {
        case .tabSkin: return "Bodi"
        case .tabFrame: return "Bingkai"
        case .tabFilm: return "Film"
        case .tabLight: return "Cahaya"
        case .tabColor: return "Warna"
        case .tabEffects: return "Efek"
        case .tabSettings: return "Pengaturan"
        case .studioCalibration: return "Kalibrasi Studio"
        case .reset: return "Atur Ulang"
        case .done: return "Selesai"
        case .close: return "Tutup"
        case .select: return "Pilih"
        case .save: return "Simpan"
        case .saveAll: return "Simpan Semua"
        case .delete: return "Hapus"
        case .deleteAll: return "Hapus Semua"
        case .selectedCount(let count): return "\(count) Terpilih"
        case .language: return "Bahasa"
        case .appLanguage: return "Bahasa Aplikasi"
        case .selectLanguageDescription: return "Pilih bahasa tampilan aplikasi yang Anda inginkan."
        case .unlockFilmPro: return "Buka Film Camera Pro"
        case .unlimitedShooting: return "Foto analog tanpa batas & simulasi film autentik."
        case .allAnalogFilms: return "Semua Roll Film Analog"
        case .allAnalogFilmsDesc: return "Akses 200+ film 35mm, medium format & slide legendaris."
        case .filmstripBorders: return "Frame Negatif Klise 35mm"
        case .filmstripBordersDesc: return "Perforasi lubang sprocket asli dan kode tepi film."
        case .maxHdQuality: return "Kualitas Maksimal HD & RAW"
        case .maxHdQualityDesc: return "Simpan resolusi penuh sensor dengan detail butiran grain analog."
        case .lifetimePurchase: return "Beli Sekali Seumur Hidup"
        case .lifetimeSubtitle: return "Bayar sekali, miliki selamanya"
        case .monthlySubscription: return "Langganan Bulanan"
        case .monthlySubtitle: return "Langganan bulanan fleksibel, batalkan kapan saja"
        case .bestValue: return "PILIHAN TERBAIK"
        case .upgradeToFilmPro: return "Tingkatkan Ke Film Pro"
        case .restorePurchases: return "Pulihkan Pembelian"
        case .subscriptionTerms: return "Langganan yang diperpanjang otomatis dapat dibatalkan kapan saja di pengaturan akun App Store."
        case .freeLimitBanner(let count): return "Batas Kuota Tercapai (\(count) Foto)"
        case .shotsRemaining(let count): return "Sisa \(count) Foto"
        case .filmRollReview: return "Review Roll Film"
        case .rollFrames(let count): return "Roll #01 • \(count) Foto"
        case .noFramesCaptured: return "Belum Ada Foto"
        case .noFramesDesc: return "Foto yang diambil dengan kamera akan tersimpan di roll klise ini."
        case .savedToGallery(let count): return "\(count) Foto Tersimpan Ke Galeri"
        case .saveFailed: return "Gagal Menyimpan"
        case .saved: return "Tersimpan"
        case .expLimit(let count): return "\(count) EXP"
        }
    }

    private var koreanText: String {
        switch self {
        case .tabSkin: return "스킨"
        case .tabFrame: return "프레임"
        case .tabFilm: return "필름"
        case .tabLight: return "조명"
        case .tabColor: return "색상"
        case .tabEffects: return "효과"
        case .tabSettings: return "설정"
        case .studioCalibration: return "스튜디오 캘리브레이션"
        case .reset: return "재설정"
        case .done: return "완료"
        case .close: return "닫기"
        case .select: return "선택"
        case .save: return "저장"
        case .saveAll: return "모두 저장"
        case .delete: return "삭제"
        case .deleteAll: return "모두 삭제"
        case .selectedCount(let count): return "\(count)개 선택됨"
        case .language: return "언어"
        case .appLanguage: return "앱 언어"
        case .selectLanguageDescription: return "원하시는 앱 언어를 선택하세요."
        case .unlockFilmPro: return "Film Camera Pro 잠금 해제"
        case .unlimitedShooting: return "무제한 아날로그 촬영 및 오리지널 필름 시뮬레이션."
        case .allAnalogFilms: return "모든 아날로그 필름 롤"
        case .allAnalogFilmsDesc: return "200가지 이상의 전설적인 35mm 및 중형 포맷 필름 제공."
        case .filmstripBorders: return "35mm 네거티브 필름스트립 프레임"
        case .filmstripBordersDesc: return "실제 스프로킷 천공 및 필름 마진 코드 재현."
        case .maxHdQuality: return "최고의 HD 및 RAW 품질"
        case .maxHdQualityDesc: return "아날로그 필름 그레인을 보존한 풀 센서 해상도 저장."
        case .lifetimePurchase: return "평생 소장 구매"
        case .lifetimeSubtitle: return "한 번 결제로 평생 소장"
        case .monthlySubscription: return "월간 구독"
        case .monthlySubtitle: return "유연한 월간 구독, 언제든 취소 가능"
        case .bestValue: return "최고의 혜택"
        case .upgradeToFilmPro: return "Film Pro로 업그레이드"
        case .restorePurchases: return "구매 항목 복원"
        case .subscriptionTerms: return "자동 갱신 구독은 App Store 계정 설정에서 언제든지 취소할 수 있습니다."
        case .freeLimitBanner(let count): return "무료 촬영 한도 도달 (\(count)장)"
        case .shotsRemaining(let count): return "\(count)장 남음"
        case .filmRollReview: return "필름 롤 리뷰"
        case .rollFrames(let count): return "롤 #01 • \(count)컷"
        case .noFramesCaptured: return "촬영된 사진 없음"
        case .noFramesDesc: return "카메라로 촬영한 사진이 필름 롤에 나타납니다."
        case .savedToGallery(let count): return "\(count)장의 사진 앨범에 저장됨"
        case .saveFailed: return "저장 실패"
        case .saved: return "저장됨"
        case .expLimit(let count): return "\(count) EXP"
        }
    }

    private var portugueseText: String {
        switch self {
        case .tabSkin: return "Corpo"
        case .tabFrame: return "Quadro"
        case .tabFilm: return "Filme"
        case .tabLight: return "Luz"
        case .tabColor: return "Cor"
        case .tabEffects: return "Efeitos"
        case .tabSettings: return "Ajustes"
        case .studioCalibration: return "Calibração de Estúdio"
        case .reset: return "Redefinir"
        case .done: return "Concluído"
        case .close: return "Fechar"
        case .select: return "Selecionar"
        case .save: return "Salvar"
        case .saveAll: return "Salvar Tudo"
        case .delete: return "Excluir"
        case .deleteAll: return "Excluir Tudo"
        case .selectedCount(let count): return "\(count) Selecionado(s)"
        case .language: return "Idioma"
        case .appLanguage: return "Idioma do Aplicativo"
        case .selectLanguageDescription: return "Selecione o idioma de sua preferência."
        case .unlockFilmPro: return "Desbloquear Film Camera Pro"
        case .unlimitedShooting: return "Fotos analógicas ilimitadas e simulações autênticas de filme."
        case .allAnalogFilms: return "Todos os Rolos de Filme Analógico"
        case .allAnalogFilmsDesc: return "Acesso a mais de 200 filmes lendários de 35mm e médio formato."
        case .filmstripBorders: return "Bordas de Negativo 35mm"
        case .filmstripBordersDesc: return "Perfurações autênticas e códigos de borda de exposição."
        case .maxHdQuality: return "Qualidade Máxima em HD e RAW"
        case .maxHdQualityDesc: return "Resolução total do sensor com granulação analógica preservada."
        case .lifetimePurchase: return "Compra Vitalícia"
        case .lifetimeSubtitle: return "Pague uma vez, tenha para sempre"
        case .monthlySubscription: return "Assinatura Mensal"
        case .monthlySubtitle: return "Assinatura mensal flexível, cancele a qualquer momento"
        case .bestValue: return "MELHOR VALOR"
        case .upgradeToFilmPro: return "Atualizar Para Film Pro"
        case .restorePurchases: return "Restaurar Compras"
        case .subscriptionTerms: return "Assinaturas com renovação automática podem ser canceladas a qualquer momento nos ajustes da App Store."
        case .freeLimitBanner(let count): return "Limite Gratuito Atingido (\(count) Fotos)"
        case .shotsRemaining(let count): return "\(count) Fotos Restantes"
        case .filmRollReview: return "Revisão do Rolo de Filme"
        case .rollFrames(let count): return "Rolo #01 • \(count) Fotos"
        case .noFramesCaptured: return "Nenhuma Foto Capturada"
        case .noFramesDesc: return "As fotos tiradas com a câmera aparecerão aqui no rolo de filme."
        case .savedToGallery(let count): return "\(count) Foto\(count > 1 ? "s" : "") Salva(s) na Galeria"
        case .saveFailed: return "Falha ao Salvar"
        case .saved: return "Salvo"
        case .expLimit(let count): return "\(count) EXP"
        }
    }

    private var spanishText: String {
        switch self {
        case .tabSkin: return "Cuerpo"
        case .tabFrame: return "Marco"
        case .tabFilm: return "Película"
        case .tabLight: return "Luz"
        case .tabColor: return "Color"
        case .tabEffects: return "Efectos"
        case .tabSettings: return "Ajustes"
        case .studioCalibration: return "Calibración de Estudio"
        case .reset: return "Restablecer"
        case .done: return "Listo"
        case .close: return "Cerrar"
        case .select: return "Seleccionar"
        case .save: return "Guardar"
        case .saveAll: return "Guardar Todo"
        case .delete: return "Eliminar"
        case .deleteAll: return "Eliminar Todo"
        case .selectedCount(let count): return "\(count) Seleccionado(s)"
        case .language: return "Idioma"
        case .appLanguage: return "Idioma de la Aplicación"
        case .selectLanguageDescription: return "Seleccione su idioma preferido para la aplicación."
        case .unlockFilmPro: return "Desbloquear Film Camera Pro"
        case .unlimitedShooting: return "Disparos analógicos ilimitados y auténticas simulaciones de película."
        case .allAnalogFilms: return "Todos los Rollos de Película Analógica"
        case .allAnalogFilmsDesc: return "Acceso a más de 200 películas legendarias de 35mm y formato medio."
        case .filmstripBorders: return "Bordes de Negativo 35mm"
        case .filmstripBordersDesc: return "Perforaciones auténticas y códigos de exposición en el borde."
        case .maxHdQuality: return "Máxima Calidad HD y RAW"
        case .maxHdQualityDesc: return "Resolución completa del sensor con grano analógico preservado."
        case .lifetimePurchase: return "Compra Definitiva"
        case .lifetimeSubtitle: return "Paga una vez, disfrútalo para siempre"
        case .monthlySubscription: return "Suscripción Mensual"
        case .monthlySubtitle: return "Facturación mensual flexible, cancela cuando quieras"
        case .bestValue: return "MEJOR VALOR"
        case .upgradeToFilmPro: return "Actualizar a Film Pro"
        case .restorePurchases: return "Restaurar Compras"
        case .subscriptionTerms: return "Las suscripciones con renovación automática se pueden cancelar en cualquier momento en los ajustes de App Store."
        case .freeLimitBanner(let count): return "Límite Gratuito Alcanzado (\(count) Fotos)"
        case .shotsRemaining(let count): return "\(count) Fotos Restantes"
        case .filmRollReview: return "Revisión del Rollo de Película"
        case .rollFrames(let count): return "Rollo #01 • \(count) Fotos"
        case .noFramesCaptured: return "No Hay Fotos Capturadas"
        case .noFramesDesc: return "Las fotos tomadas con la cámara aparecerán aquí en el carrete de película."
        case .savedToGallery(let count): return "\(count) Foto\(count > 1 ? "s" : "") Guardada(s)"
        case .saveFailed: return "Error al Guardar"
        case .saved: return "Guardado"
        case .expLimit(let count): return "\(count) EXP"
        }
    }
}
