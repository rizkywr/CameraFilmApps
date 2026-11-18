//
//  MyApp.swift
//  CameraFilmApps
//

import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // Enforce strict portrait orientation regardless of device rotation
        return .portrait
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var camera = CameraModel()
    @State private var library = FilmLibrary()
    @State private var rollStore = FilmRollStore.shared
    @State private var proStore = ProStore.shared

    var body: some Scene {
        WindowGroup {
            CameraScreen()
                .environment(camera)
                .environment(library)
                .environment(rollStore)
                .environment(proStore)
        }
    }
}
