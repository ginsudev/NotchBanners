//
//  UIImage+Adaptive.swift
//  
//
//  Created by Noah Little on 28/7/2022.
//

import UIKit

extension UIImage {
    
    public func getAdaptiveColours() -> [UIColor] {
        
        var coloursArray: [UIColor] = localSettings.colours
        
        var averageColor: UIColor {
            let inputImage = CIImage(image: self)!
            let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

            let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector])!
            let outputImage = filter.outputImage!

            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull!])
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

            return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: 1.0)
        }
        
        var textColor: UIColor {
            let originalCGColor = averageColor.cgColor
            let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)!
            let components = RGBCGColor.components!
            
            guard components.count >= 3 else {
                return .white
            }

            let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
            return (brightness > 0.5) ? .black : .white
        }
        
        if localSettings.colouringStyle == 2 {
            coloursArray[0] = averageColor
            coloursArray[1] = textColor
        }
        
        if localSettings.borderColourStyle == 2 {
            coloursArray[4] = averageColor
            coloursArray[5] = averageColor
        }
        
        return coloursArray
    }
    
}
