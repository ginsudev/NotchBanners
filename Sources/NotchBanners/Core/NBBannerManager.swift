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
    var activeWindows = [NBBannerWindow]()
    var statusBarHeight = (UIWindow().windowScene?.statusBarManager?.statusBarHeight ?? 15.0) - 15.0
    
    func createBannerWindow(withContent content: NBContent) {
        
        for window in activeWindows {
            if window.isFullyPresented {
                dismissBannerWindow(window)
            } else {
                killWindow(window)
            }
        }
        
        let window = NBBannerWindow(screen: UIScreen.main, debugName: "NotchBanners", content: content)
        window.windowLevel = .statusBar + 999999
        activeWindows.append(window)
        window.makeKeyAndVisible()
    }
    
    @objc func dismissAllWindows() {
        for window in activeWindows {
            if window.isFullyPresented {
                dismissBannerWindow(window)
            } else {
                killWindow(window)
            }
        }
        TLAlert._stopAllAlerts()
    }
    
    func dismissBannerWindow(_ window: NBBannerWindow) {
        UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
            window.transform = CGAffineTransform(translationX: 0, y: -window.frame.height)
        }, completion: { action in
            self.killWindow(window)
        })
    }
    
    func killWindow(_ window: NBBannerWindow) {
        window.isHidden = true
        window.windowScene = nil
        window.containerController.bannerController!.timer.invalidate()
        TLAlert._stopAllAlerts()
        activeWindows = activeWindows.filter {$0 != window}
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
                
                for window in self.activeWindows {
                    NBBannerManager.sharedInstance.dismissBannerWindow(window)
                }
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
        
        let buttonHeight: Double = localSettings.customButtonHeight ? localSettings.customButtonHeightValue : 50.0
        let lastActionMaxY: Double = (actions ?? 0 > 0) ? -(statusBarHeight + 3.0 + (Double(actions!) * buttonHeight) + (Double(actions!) * 3.0)) : 0.0
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
    
    private override init() { }
}
