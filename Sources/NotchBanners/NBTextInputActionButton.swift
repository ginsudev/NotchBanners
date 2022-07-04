//
//  NBTextInputActionButton.swift
//  
//
//  Created by Noah Little on 16/4/2022.
//

import UIKit
import NotchBannersC

class NBTextInputActionButton: UITextField, UITextFieldDelegate, NBButton {
    var action: NCNotificationAction!
    var additionalContent: String?
    
    init(frame: CGRect, actionBlob notificationAction: NCNotificationAction) {
        super.init(frame: frame)
        
        action = notificationAction
        
        let colour = action.isDestructiveAction ? UIColor.red : localSettings.colours[3]
        
        delegate = self
        backgroundColor = localSettings.colours[2]
        clipsToBounds = true
        layer.cornerRadius = localSettings.customButtonRadius ? localSettings.customButtonRadiusValue : 14
        attributedPlaceholder = NSAttributedString(string: action.title, attributes: [NSAttributedString.Key.foregroundColor: colour])
        textColor = colour
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let ancestor = _viewControllerForAncestor() as? NBBannerController else {
            return
        }
        
        ancestor.timerConfig(startTimer: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text {
            if !text.isEmpty {
                additionalContent = text
                prepareActionExecution()
            }
        }
        
        return true
    }
    
    @objc func prepareActionExecution() {
        guard let additionalContent = additionalContent else {
            NBBannerManager.sharedInstance.execAction(action, withParams: action.behaviorParameters)
            return
        }
        
        let mutableParams = NSMutableDictionary(dictionary: action.behaviorParameters)
        mutableParams["UIUserNotificationActionResponseTypedTextKey"] = additionalContent

        NBBannerManager.sharedInstance.execAction(action, withParams: mutableParams)
    }
}
