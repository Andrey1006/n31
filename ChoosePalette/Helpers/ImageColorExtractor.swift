import SwiftUI
import UIKit

enum ImageColorExtractor {
    static func extractVerticalGradient(from image: UIImage, samples: Int = 32) -> [Color] {
        let size = CGSize(width: 1, height: samples)
        let renderer = UIGraphicsImageRenderer(size: size)
        let small = renderer.image { ctx in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let cgImage = small.cgImage else { return [] }

        let width = 1
        let height = samples
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return [] }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return [] }

        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var colors: [Color] = []
        for y in 0..<height {
            let row = height - 1 - y
            let offset = row * 4
            let r = Int(buffer[offset])
            let g = Int(buffer[offset + 1])
            let b = Int(buffer[offset + 2])
            colors.append(Color.rgb(r, g, b))
        }
        return colors
    }
}
