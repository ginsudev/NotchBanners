//
//  NBActionButton.swift
//  
//
//  Created by Noah Little on 15/4/2022.
//

import UIKit
import NotchBannersC

class NBActionButton: UIButton {
    private var mainAction: NCNotificationAction!
    
    init(frame: CGRect, actionBlob action: NCNotificationAction) {
        super.init(frame: frame)
        
        mainAction = action
        
        backgroundColor = localSettings.colours[2]
        clipsToBounds = true
        layer.cornerRadius = 14
                
        let colour = action.isDestructiveAction ? UIColor.red : localSettings.colours[1]

        setTitle(action.title, for: .normal)
        setTitleColor(colour, for: .normal)
        titleLabel?.textAlignment = .center
        
        addTarget(self, action: #selector(executeAction), for: .touchUpInside)
    }

    @objc func executeAction() {
        NBBannerManager.sharedInstance.execAction(mainAction, withParams: mainAction.behaviorParameters)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
