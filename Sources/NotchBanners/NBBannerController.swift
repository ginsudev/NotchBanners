//
//  NBBannerController.swift
//  
//
//  Created by Noah Little on 15/4/2022.
//

import UIKit
import NotchBannersC

class NBBannerController: UIViewController {
    private var timer = Timer()
    var bannerView: NBBannerView!
    var currentContentBlob: NBContent!

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var updatedFrame = self.view.frame
        updatedFrame.size.height = bannerView.frame.height
        updatedFrame.size.width = bannerView.frame.width
        self.view.frame = updatedFrame
    }
    
    func createBanner(withContent content: NBContent) {
        
        currentContentBlob = content
        
        self.view.transform = .identity
        
        bannerView = NBBannerView(frame: self.view.bounds,
                                  header: content.header,
                                  title: content.title,
                                  subtitle: content.subtitle,
                                  body: content.body,
                                  iconImage: content.icon,
                                  actions: content.actions)
        view.addSubview(bannerView)
        
        let frame_special_cache = NBBannerManager.sharedInstance.getOptimalBannerFrame(actionCount: currentContentBlob.actions.dropFirst().count)
        bannerView.widthAnchor.constraint(equalToConstant: frame_special_cache.width).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: self.parent!.view.centerXAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        //Animate in
        self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.transform = .identity
        })
        
        timerConfig(startTimer: true)
    }
    
    func dismissBannerAndCreateNewWithContent(_ content: NBContent?) {
        //Animate out and create new banner
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        }, completion: { action in
            self.bannerView.removeFromSuperview()
            
            if let content = content {
                self.createBanner(withContent: content)
            }
        })
    }
    
    func timerConfig(startTimer start: Bool) {
        guard currentContentBlob.dismissAutomatically else {
            //Return if the banner is sticky.
            return
        }
        
        if timer.isValid {
            timer.invalidate()
        }
        
        guard start else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(postWindowKillRequest), userInfo: nil, repeats: false)
    }
    
    @objc func postWindowKillRequest() {
        NBBannerManager.sharedInstance.dismissBannerWindow()
    }
}
