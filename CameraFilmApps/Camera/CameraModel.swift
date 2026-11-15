//
//  CameraModel.swift
//  Film Camera
//

import AVFoundation
import CoreMotion
import Observation
import UIKit

/// UI-facing camera state. Bridges SwiftUI to `CameraService` and `FilmRenderer`.
@Observable
final class CameraModel {
    enum Status: Equatable {
        case idle
        case running
        case unauthorized
        case failed(String)
    }

    enum FlashMode: String, CaseIterable, Identifiable {
        case off = "OFF"
        case auto = "AUTO"
        case on = "ON"
        
        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .off: "bolt.slash.fill"
            case .auto: "bolt.badge.automatic.fill"
            case .on: "bolt.fill"
            }
        }

        var title: String { rawValue }

        var avMode: AVCaptureDevice.FlashMode {
            switch self {
            case .off: .off
            case .auto: .auto
            case .on: .on
            }
        }
    }

    private(set) var status: Status = .idle
    private(set) var position: AVCaptureDevice.Position = .back
    private(set) var deviceInfo: CameraDeviceInfo?
    /// Current device zoom factor.
    private(set) var zoomFactor: CGFloat = 1
    private(set) var lastPhoto: UIImage?
    private(set) var isCapturing = false
    private(set) var isFlipping = false
    /// Incremented on every shutter press; drives haptics and the shutter flash.
    private(set) var shutterCount = 0
    var captureError: String?

    var flashMode: FlashMode = .off
    var showsGrid = false
    var showsLevel: Bool = false {
        didSet {
            if showsLevel {
                startMotionUpdates()
            } else {
                stopMotionUpdates()
            }
        }
    }
    var cameraSkin: CameraSkin = .classicBlack
    var levelRoll: Double = 0.0 // in degrees
    private let motionManager = CMMotionManager()

    // MARK: - Proccam Feature Controls
    enum TimerMode: Int, CaseIterable {
        case off = 0
        case threeSec = 3
        case tenSec = 10
        var title: String {
            switch self {
            case .off: return "OFF"
            case .threeSec: return "3s"
            case .tenSec: return "10s"
            }
        }
    }

    enum AspectRatioMode: String, CaseIterable {
        case ratio3_4 = "3:4"
        case ratio1_1 = "1:1"
        case ratio16_9 = "16:9"
    }

    enum WhiteBalanceMode: String, CaseIterable {
        case auto = "Auto"
        case daylight = "Daylight"
        case cloudy = "Cloudy"
        case tungsten = "Tungsten"
    }

    var timerMode: TimerMode = .off
    var aspectRatioMode: AspectRatioMode = .ratio3_4
    var whiteBalanceMode: WhiteBalanceMode = .auto
    var exposureBias: Float = 0.0 // -2.0 to +2.0
    var timerCountdown: Int? = nil


    /// The film currently loaded into the renderer (`nil` = no film).
    private(set) var selectedFilmID: String? = UserDefaults.standard.string(forKey: Keys.selectedFilm)

    var adjustments: FilmAdjustments = CameraModel.savedAdjustments() {
        didSet {
            renderer?.setAdjustments(adjustments)
            if let data = try? JSONEncoder().encode(adjustments) {
                UserDefaults.standard.set(data, forKey: Keys.adjustments)
            }
        }
    }

    private enum Keys {
        static let selectedFilm = "selectedFilm"
        static let adjustments = "adjustments"
    }

    let renderer: FilmRenderer?
    private let service = CameraService()

    /// An invisible, unconnected preview layer that lives in the view hierarchy
    /// so the rotation coordinator knows the interface orientation.
    let rotationReferenceLayer: AVCaptureVideoPreviewLayer
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    /// Current rotation applied to preview frames, used to map taps to the sensor.
    private var previewRotationAngle: CGFloat = 90

    #if targetEnvironment(simulator)
    private var simulatorFrame: CVPixelBuffer?
    #endif

    init() {
        renderer = FilmRenderer()
        rotationReferenceLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: service.session)
        let renderer = renderer
        service.onFrame = { frame in renderer?.enqueue(frame: frame) }
        renderer?.setAdjustments(adjustments)
        loadLatestPhotoFromLibrary()
    }

    func refreshLatestPhoto() {
        Task { @MainActor in
            if let photo = await PhotoWriter.fetchLatestPhotoThumbnail() {
                self.lastPhoto = photo
            }
        }
    }

    private func loadLatestPhotoFromLibrary() {
        refreshLatestPhoto()
    }

    private static func savedAdjustments() -> FilmAdjustments {
        guard let data = UserDefaults.standard.data(forKey: Keys.adjustments),
              let value = try? JSONDecoder().decode(FilmAdjustments.self, from: data)
        else { return .default }
        return value
    }

    // MARK: - Film

    /// Loads a film's LUT into the renderer. Pass `nil` for no film.
    func selectFilm(_ film: Film?, lutURL: URL?) async {
        selectedFilmID = film?.id
        UserDefaults.standard.set(film?.id, forKey: Keys.selectedFilm)
        guard let film, let lutURL else {
            renderer?.setLUT(nil)
            return
        }
        do {
            let cube = try await Task.detached(priority: .userInitiated) { try CubeLUT(contentsOf: lutURL) }.value
            // Ignore stale loads if the user already picked another film.
            guard selectedFilmID == film.id else { return }
            renderer?.setLUT(cube)
        } catch {
            captureError = "Couldn't load \(film.displayName). \(error.localizedDescription)"
        }
    }

    var displayZoom: CGFloat { zoomFactor * (deviceInfo?.displayMultiplier ?? 1) }

    private func startMotionUpdates() {
        guard !motionManager.isDeviceMotionActive && !motionManager.isAccelerometerActive else { return }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let motion, let self else { return }
                // Gravity vector:
                // Portrait phone upright: gravity.x ≈ 0, gravity.y ≈ -1.0
                // Tilt right: gravity.x > 0
                // Tilt left: gravity.x < 0
                let gx = motion.gravity.x
                let gy = motion.gravity.y
                let angle = atan2(gx, -gy) * 180.0 / .pi
                self.levelRoll = angle
            }
        } else if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 30.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let data, let self else { return }
                let ax = data.acceleration.x
                let ay = data.acceleration.y
                let angle = atan2(ax, -ay) * 180.0 / .pi
                self.levelRoll = angle
            }
        }
    }

    private func stopMotionUpdates() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        if motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }

    // MARK: - Lifecycle

    func start() async {
        if showsLevel { startMotionUpdates() }
        guard status != .running else { return }
        guard renderer != nil else {
            status = .failed("Metal is not available on this device.")
            return
        }

        #if targetEnvironment(simulator)
        startSimulatorFeed()
        #else
        guard await CameraService.requestAccess() else {
            status = .unauthorized
            return
        }
        do {
            apply(try await service.start(position: position))
            status = .running
        } catch {
            status = .failed(error.localizedDescription)
        }
        #endif
    }

    func stop() {
        stopMotionUpdates()
        service.stop()
        if status == .running { status = .idle }
    }

    func flipCamera() async {
        guard status == .running, deviceInfo != nil, !isFlipping else { return }
        isFlipping = true
        let next: AVCaptureDevice.Position = position == .back ? .front : .back
        do {
            let newInfo = try await service.switchCamera(to: next)
            apply(newInfo)
        } catch {
            captureError = error.localizedDescription
        }
        // Brief settling period so Metal renderer receives the first upright frame cleanly
        try? await Task.sleep(for: .milliseconds(300))
        isFlipping = false
    }

    private func apply(_ info: CameraDeviceInfo) {
        deviceInfo = info
        position = info.position
        zoomFactor = info.defaultZoom
        if let device = info.device { observeRotation(of: device) }
    }

    /// Locks preview frames strictly upright in Portrait orientation for both front & back sensors.
    /// Rotation changes from tilting the phone into landscape are ignored so the UI and preview remain pure portrait.
    private func observeRotation(of device: AVCaptureDevice) {
        let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: rotationReferenceLayer)
        rotationCoordinator = coordinator
        // The rotation coordinator computes the exact sensor angle needed to display upright in Portrait.
        // For back camera this is typically 90°, for front camera it is 270°.
        // We read this portrait angle directly and lock it, ignoring any accelerometer landscape tilt.
        let portraitAngle = coordinator.videoRotationAngleForHorizonLevelPreview
        updatePreviewRotation(portraitAngle)
    }

    private func updatePreviewRotation(_ angle: CGFloat) {
        previewRotationAngle = angle
        service.setPreviewRotation(angle)
    }

    // MARK: - Controls

    func setZoom(_ factor: CGFloat, animated: Bool = true) {
        guard let info = deviceInfo else { return }
        zoomFactor = min(max(factor, info.minZoom), info.maxZoom)
        service.setZoom(zoomFactor, animated: animated)
    }

    /// Focus on a point given in normalized preview coordinates (0...1, top-left origin).
    func focus(atNormalized point: CGPoint, previewSize: CGSize) {
        guard deviceInfo != nil, let frameSize = renderer?.latestFrameSize else { return }

        // Undo the preview's aspect-fill crop to get a point in the portrait frame.
        let scale = max(previewSize.width / frameSize.width, previewSize.height / frameSize.height)
        let visibleU = previewSize.width / (frameSize.width * scale)
        let visibleV = previewSize.height / (frameSize.height * scale)
        let u = (1 - visibleU) / 2 + point.x * visibleU
        let v = (1 - visibleV) / 2 + point.y * visibleV

        service.focus(at: Self.sensorPoint(u: u, v: v, rotation: previewRotationAngle, mirrored: position == .front))
    }

    /// Maps a point in the delivered (rotated, possibly mirrored) frame back to
    /// the unrotated sensor image that focus/exposure points of interest use.
    static func sensorPoint(u: CGFloat, v: CGFloat, rotation: CGFloat, mirrored: Bool) -> CGPoint {
        let u = mirrored ? 1 - u : u
        switch Int(rotation.rounded()) % 360 {
        case 90: return CGPoint(x: v, y: 1 - u)
        case 180: return CGPoint(x: 1 - u, y: 1 - v)
        case 270: return CGPoint(x: 1 - v, y: u)
        default: return CGPoint(x: u, y: v)
        }
    }

    // MARK: - Capture

    func capture() async {
        guard !isCapturing, let renderer else { return }
        if timerMode != .off {
            var remaining = timerMode.rawValue
            while remaining > 0 {
                timerCountdown = remaining
                try? await Task.sleep(for: .seconds(1))
                remaining -= 1
            }
            timerCountdown = nil
        }
        isCapturing = true
        shutterCount += 1
        ShutterSoundService.shared.playShutterEffect()
        defer { isCapturing = false }

        do {
            let photo = try await capturePhoto()
            let (data, preview) = try await Task.detached(priority: .userInitiated) {
                guard let image = renderer.renderPhoto(photo.pixelBuffer) else { throw PhotoWriter.WriteError.encodingFailed }
                let data = try PhotoWriter.encode(image, metadata: photo.metadata)
                let orientation = PhotoWriter.orientation(from: photo.metadata)
                let preview = UIImage(cgImage: image, scale: 1, orientation: orientation)
                    .preparingThumbnail(of: CGSize(width: 240, height: 240 * CGFloat(image.width) / CGFloat(image.height)))
                return (data, preview)
            }.value
            lastPhoto = preview
            try await PhotoWriter.saveToLibrary(data)
        } catch {
            captureError = error.localizedDescription
        }
    }

    private func capturePhoto() async throws -> CapturedPhoto {
        #if targetEnvironment(simulator)
        guard let frame = simulatorFrame else { throw CameraError.noCamera }
        return CapturedPhoto(pixelBuffer: frame, metadata: [:])
        #else
        // Always capture in portrait orientation to match the locked portrait UI
        let captureAngle = rotationCoordinator?.videoRotationAngleForHorizonLevelPreview
        return try await service.capturePhoto(flash: flashMode.avMode,
                                              rotationAngle: captureAngle)
        #endif
    }

    /// Imports a photo from the gallery, develops it through the current film LUT & analog shaders, and saves it.
    func processImportedPhoto(_ image: UIImage) async throws {
        guard let renderer else { throw CameraError.noCamera }
        
        // Normalize image orientation and constrain max dimension for smooth Metal pipeline
        let normalized = image.normalizedForMetalProcessing(maxDimension: 3024)
        guard let pixelBuffer = PixelBufferFactory.make(from: normalized) else {
            throw PhotoWriter.WriteError.encodingFailed
        }
        
        let (data, preview) = try await Task.detached(priority: .userInitiated) {
            guard let processedCG = renderer.renderPhoto(pixelBuffer) else {
                throw PhotoWriter.WriteError.encodingFailed
            }
            let processedUI = UIImage(cgImage: processedCG)
            guard let jpegData = processedUI.jpegData(compressionQuality: 0.95) else {
                throw PhotoWriter.WriteError.encodingFailed
            }
            let thumb = processedUI.preparingThumbnail(of: CGSize(width: 240, height: 240))
            return (jpegData, thumb ?? processedUI)
        }.value

        lastPhoto = preview
        try await PhotoWriter.saveToLibrary(data)
        refreshLatestPhoto()
    }

    // MARK: - Simulator

    #if targetEnvironment(simulator)
    /// The simulator has no camera, so feed a still scene through the pipeline.
    private func startSimulatorFeed() {
        let image: CGImage? = {
            if let url = Bundle.main.url(forResource: "SampleScene", withExtension: "jpg"),
               let uiImage = UIImage(contentsOfFile: url.path) {
                return uiImage.cgImage
            }
            if let uiImage = UIImage(named: "SampleScene") ?? UIImage(named: "SampleScene.jpg") {
                return uiImage.cgImage
            }
            return Self.createFallbackSimulatorScene()
        }()

        guard let image,
              let frame = PixelBufferFactory.make(from: image, size: CGSize(width: 1080, height: 1440))
        else {
            status = .failed("Sample scene missing.")
            return
        }
        simulatorFrame = frame
        renderer?.enqueue(frame: frame)
        deviceInfo = CameraDeviceInfo(device: nil, position: .back, zoomStops: [1, 2, 4, 8, 16], displayMultiplier: 0.5,
                                      minZoom: 1, maxZoom: 30, defaultZoom: 2, hasFlash: true)
        zoomFactor = 2
        status = .running
    }

    private static func createFallbackSimulatorScene() -> CGImage? {
        let width = 1080
        let height = 1440
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        // Draw a simulated photographic scene: sky gradient, golden sun, silhouette hills
        let colors = [
            UIColor(red: 0.2, green: 0.45, blue: 0.75, alpha: 1.0).cgColor,
            UIColor(red: 0.85, green: 0.65, blue: 0.45, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 1.0).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0.0, 0.65, 1.0]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: 0, y: 0), options: [])
        }
        // Warm sun disc
        context.setFillColor(UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.9).cgColor)
        context.fillEllipse(in: CGRect(x: 440, y: 800, width: 200, height: 200))
        // Landscape shapes
        context.setFillColor(UIColor(red: 0.15, green: 0.2, blue: 0.15, alpha: 1.0).cgColor)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: 350))
        context.addCurve(to: CGPoint(x: 540, y: 280), control1: CGPoint(x: 200, y: 400), control2: CGPoint(x: 380, y: 240))
        context.addCurve(to: CGPoint(x: 1080, y: 380), control1: CGPoint(x: 700, y: 320), control2: CGPoint(x: 900, y: 420))
        context.addLine(to: CGPoint(x: 1080, y: 0))
        context.closePath()
        context.fillPath()
        return context.makeImage()
    }
    #endif
}


extension UIImage {
    /// Normalizes orientation to .up and bounds dimensions to fit within GPU texture limits
    fileprivate func normalizedForMetalProcessing(maxDimension: CGFloat = 3024) -> UIImage {
        let currentWidth = size.width
        let currentHeight = size.height
        let maxSide = max(currentWidth, currentHeight)
        
        let targetSize: CGSize
        if maxSide > maxDimension {
            let scaleRatio = maxDimension / maxSide
            targetSize = CGSize(width: floor(currentWidth * scaleRatio), height: floor(currentHeight * scaleRatio))
        } else {
            targetSize = size
        }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
