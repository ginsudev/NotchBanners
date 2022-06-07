//
//  NBBannerWindow.swift
//  
//
//  Created by Noah Little on 3/4/2022.
//

import UIKit
import NotchBannersC

class NBBannerWindow: SBFTouchPassThroughWindow {
    var containerController: NBContainerController!
    var isFrontMost = true
    var isFullyPresented = false
    
    init(screen arg1: UIScreen, debugName arg2: String, content data: NBContent) {
        super.init(screen: arg1, debugName: arg2)
        
        containerController = NBContainerController(data: data)
        containerController.view.frame = UIScreen.main.bounds
        self.rootViewController = containerController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
