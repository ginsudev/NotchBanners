//
//  NBTextInputActionView.swift
//  
//
//  Created by Noah Little on 16/4/2022.
//

import UIKit
import NotchBannersC

class NBTextInputActionView: UITextField, UITextFieldDelegate {
    private var mainAction: NCNotificationAction!
    
    init(frame: CGRect, actionBlob action: NCNotificationAction) {
        super.init(frame: frame)
        
        mainAction = action
        
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
            if text.count > 0 {
                executeAction(withText: text)
            }
        }
        
        return true
    }
    
    @objc func executeAction(withText text: String) {
        let mutableParams: NSMutableDictionary = NSMutableDictionary(dictionary: mainAction.behaviorParameters)
        mutableParams["UIUserNotificationActionResponseTypedTextKey"] = text
        NBBannerManager.sharedInstance.execAction(mainAction, withParams: mutableParams)
    }
}
