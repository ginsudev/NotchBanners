//
//  NBContainerController.swift
//  
//
//  Created by Noah Little on 16/4/2022.
//

import UIKit
import NotchBannersC

class NBContainerController: SBFTouchPassThroughViewController {
    var bannerController: NBBannerController?
    var contentBlob: NBContent!
    var isExpanded = false
    var isTyping = false
    var associatedWindow: NBBannerWindow!
    
    //Init
    convenience init(data content: NBContent, associatedWindow window: NBBannerWindow) {
        self.init(nibName: nil, bundle: nil, data: content, associatedWindow: window)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, data content: NBContent, associatedWindow window: NBBannerWindow) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        associatedWindow = window
        contentBlob = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //View stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup initial frame
        let initFrame = NBBannerManager.sharedInstance.getOptimalBannerFrame(actionCount: contentBlob.actions?.dropFirst().count ?? 0)
        bannerController!.view.frame = CGRect(x: view.frame.width/2 - initFrame.width/2,
                                              y: initFrame.origin.y,
                                              width: initFrame.width,
                                              height: initFrame.height)
        
        //Create the banner with data to present.
        bannerController!.createBanner(withContent: contentBlob)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerController = NBBannerController()
        self.addChild(bannerController!)
        view.addSubview(bannerController!.view)
        
        //Add panning gesture
        let panG = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bannerController!.view.addGestureRecognizer(panG)
    }
    
    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: bannerController!.view)

        bannerController!.view.center = CGPoint(x: bannerController!.view.center.x, y: bannerController!.view.center.y + translation.y)
        panGesture.setTranslation(CGPoint(x: 0, y: 0), in: bannerController!.view)

        if panGesture.state == .began {
            bannerController!.timerConfig(startTimer: false)
            bannerController!.bannerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        }

        if panGesture.state == .ended {
            updateFrameToFitInBounds()
            
            if !isTyping {
                bannerController!.timerConfig(startTimer: true)
            }
        }
    }
    
    func updateFrameToFitInBounds() {
        let minY = bannerController!.bannerView.hasActions ? -(bannerController!.bannerView.arrangedSubviews[contentBlob.actions?.count ?? 0].frame.origin.y) : 0.0
        let offsetY = 25.0
        var t_frame = bannerController!.view.frame
        var dismiss = false
        
        //Dismiss the banner
        if bannerController!.view.frame.origin.y < (minY - offsetY) {
            t_frame.origin.y = -bannerController!.view.frame.height
            dismiss = true
        }

        //In this case, let's set the frame's yPos back to 0.
        if bannerController!.view.frame.origin.y < 50 && bannerController!.view.frame.origin.y > (minY - offsetY) {
            t_frame.origin.y = minY
            setExpanded(false)
            dismiss = false
        }

        //Expand the banner
        if bannerController!.view.frame.origin.y > 50 {
            if bannerController!.bannerView.hasActions && !isExpanded {
                t_frame.origin.y = 0.0
                setExpanded(true)
                dismiss = false
            } else {
                t_frame.origin.y = minY
                setExpanded(false)
                dismiss = isExpanded ? false : true
            }
            NBBannerManager.sharedInstance.thudSound()
        }
        
        animateSetFrame(t_frame, shouldDismiss: dismiss)
    }
    
    func animateSetFrame(_ frame: CGRect, shouldDismiss dismiss: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.bannerController!.view.frame = frame
        }, completion: { action in
            self.bannerController!.bannerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

            guard dismiss else {
                return
            }

            //NBBannerManager.sharedInstance.dismissAllWindows()
        })
    }
    
    func setExpanded(_ expanded: Bool) {
        isExpanded = expanded
        
        guard let txtInputAction = bannerController!.bannerView.textInputButton() else {
            return
        }
        
        if isExpanded {
            bannerController!.timerConfig(startTimer: false)
            isTyping = true
            txtInputAction.becomeFirstResponder()
        } else {
            bannerController!.timerConfig(startTimer: true)
            isTyping = false
            txtInputAction.resignFirstResponder()
        }
    }
}
