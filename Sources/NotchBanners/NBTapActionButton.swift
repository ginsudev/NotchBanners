//
//  NBTapActionButton.swift
//  
//
//  Created by Noah Little on 15/4/2022.
//

import UIKit
import NotchBannersC

class NBTapActionButton: UIButton, NBButton {
    var action: NCNotificationAction!
    
    init(frame: CGRect, actionBlob notificationAction: NCNotificationAction) {
        super.init(frame: frame)
        
        action = notificationAction
        
        let colour = action.isDestructiveAction ? UIColor.red : localSettings.colours[3]
        
        backgroundColor = localSettings.colours[2]
        clipsToBounds = true
        layer.cornerRadius = localSettings.customButtonRadius ? localSettings.customButtonRadiusValue : 14
        setTitle(action.title, for: .normal)
        setTitleColor(colour, for: .normal)
        titleLabel?.textAlignment = .center
        
        addTarget(self, action: #selector(prepareActionExecution), for: .touchUpInside)
    }

    @objc func prepareActionExecution() {
        NBBannerManager.sharedInstance.execAction(action, withParams: action.behaviorParameters)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
