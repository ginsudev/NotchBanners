//
//  NBBannerManager.swift
//  
//
//  Created by Noah Little on 3/4/2022.
//

import UIKit
import NotchBannersC

class NBBannerManager: NSObject {
    static let sharedInstance = NBBannerManager()
    var window: NBBannerWindow!
    var statusBarHeight = (UIWindow().windowScene?.statusBarManager?.statusBarHeight ?? 15.0) - 15.0
    var isActive = false
    
    func createBannerWindow(withContent content: NBContent) {
        window = NBBannerWindow(screen: UIScreen.main, debugName: "NotchBanners", content: content)
        window.windowLevel = .statusBar + 999999
        window.makeKeyAndVisible()
        isActive = true
    }
    
    func dismissBannerWindow() {
        UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
            self.window.transform = CGAffineTransform(translationX: 0, y: -self.window.frame.height)
        }, completion: { action in
            self.killWindow()
        })
    }
    
    func killWindow() {
        window.isHidden = true
        window.windowScene = nil
        TLAlert._stopAllAlerts()
        isActive = false
    }
    
    func thudSound() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
    }
    
    func execAction(_ action: NCNotificationAction, withParams parameters: Any?) {
        action.actionRunner.executeAction(action, fromOrigin: "BulletinDestinationBanner", endpoint: nil, withParameters: parameters, completion: { finished in
            DispatchQueue.main.async {
                NBBannerManager.sharedInstance.thudSound()
                NBBannerManager.sharedInstance.dismissBannerWindow()
                TLAlert._stopAllAlerts()
            }
        })
    }
    
    func getOptimalBannerFrame(actionCount actions: Int?) -> CGRect {
        
        //Measurements from https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf
        let screenModels = ["iPhone10,3" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 63.12),    //X
                            "iPhone10,6" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 63.12),    //X
                            "iPhone11,8" : ScreenModel(notchWidth_mm: 34.96, screenWidth_mm: 64.58),    //XR
                            "iPhone11,2" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 63.13),    //XS
                            "iPhone11,6" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 69.61),    //XS MAX
                            "iPhone12,1" : ScreenModel(notchWidth_mm: 34.96, screenWidth_mm: 64.58),    //11
                            "iPhone12,3" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 62.33),    //11 Pro
                            "iPhone12,5" : ScreenModel(notchWidth_mm: 33.90, screenWidth_mm: 68.81),    //11 Pro Max
                            "iPhone13,1" : ScreenModel(notchWidth_mm: 33.36, screenWidth_mm: 57.67),    //12 Mini
                            "iPhone13,2" : ScreenModel(notchWidth_mm: 33.36, screenWidth_mm: 64.58),    //12
                            "iPhone13,3" : ScreenModel(notchWidth_mm: 33.36, screenWidth_mm: 64.58),    //12 Pro
                            "iPhone13,4" : ScreenModel(notchWidth_mm: 33.36, screenWidth_mm: 71.13),    //12 Pro Max
                            "iPhone14,4" : ScreenModel(notchWidth_mm: 25.36, screenWidth_mm: 57.67),    //13 Mini
                            "iPhone14,5" : ScreenModel(notchWidth_mm: 25.36, screenWidth_mm: 64.58),    //13
                            "iPhone14,2" : ScreenModel(notchWidth_mm: 25.36, screenWidth_mm: 64.58),    //13 Pro
                            "iPhone14,3" : ScreenModel(notchWidth_mm: 25.36, screenWidth_mm: 71.13),    //13 Pro Max
                            
                            "DEFAULT" : ScreenModel(notchWidth_mm: 1.00, screenWidth_mm: 1.00),         //Default
        ]
        
        let lastActionMaxY: Double = (actions ?? 0 > 0) ? -(20 + Double(actions!)*(50.0 + 10)) : 0.0
        let currentModel = screenModels[UIDevice.current.modelName] ?? screenModels["DEFAULT"]
        let width = localSettings.customWidth ? localSettings.customWidthValue! : width(notchWidth: currentModel!.notchWidth_mm, screenWidth: currentModel!.screenWidth_mm)
        
        return CGRect(x: UIScreen.main.bounds.width/2 - width/2, y: lastActionMaxY, width: width, height: 120)
    }
    
    func width(notchWidth notch: Double, screenWidth screen: Double) -> Double {
        return (isLandscape() ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) * (notch / screen) + 6.0
    }
    
    func isLandscape() -> Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }
    
    func getAdaptiveColours(forImage image: UIImage) -> [UIColor] {
        
        var coloursArray: [UIColor] = localSettings.colours
        
        var averageColor: UIColor {
            let inputImage = CIImage(image: image)!
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
        
        coloursArray[0] = averageColor
        coloursArray[1] = textColor
        
        return coloursArray
    }
    
    private override init() { }
}
