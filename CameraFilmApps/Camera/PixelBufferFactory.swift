//
//  PixelBufferFactory.swift
//  Film Camera
//

import CoreGraphics
import CoreVideo
import Foundation
import UIKit

/// Creates `CVPixelBuffer`s from `CGImage`s or `UIImage`s (for stand-in simulator frames and
/// photo-capture fallbacks).
nonisolated enum PixelBufferFactory {
    static func make(from image: CGImage, size: CGSize? = nil) -> CVPixelBuffer? {
        let width = Int(size?.width ?? CGFloat(image.width))
        let height = Int(size?.height ?? CGFloat(image.height))

        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferMetalCompatibilityKey: true,
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA,
            attributes as CFDictionary, &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let context = CGContext(
            data: base, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: space, bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        // Draw the image upright into the bitmap context.
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }

    static func make(from uiImage: UIImage, size: CGSize? = nil) -> CVPixelBuffer? {
        guard let cgImage = uiImage.cgImage else { return nil }
        return make(from: cgImage, size: size)
    }
}
