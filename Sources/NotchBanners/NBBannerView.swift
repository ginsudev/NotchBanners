//
//  NBBannerView.swift
//  
//
//  Created by Noah Little on 3/4/2022.
//

import UIKit
import NotchBannersC
import CoreGraphics

class NBBannerView: UIStackView {
    var headerView: NBIconLabelView!
    private var titleLabel: UILabel!
    private var bodyLabel: UILabel!
    private var spacerTop: UIView!
    private var spacerTopTop: UIView!
    private var spacerBottom: UIView!
    private var openAppAction: NCNotificationAction?
    private var hasTopText = false
    private var insets = 10.0
    var hasActions = false
    
    init(frame: CGRect, header headerText: String, title titleText: String, subtitle subtitleText: String, body bodyText: String, iconImage icon: UIImage, actions actionList: [NCNotificationAction]?) {
        super.init(frame: frame)
        
        if localSettings.borderColours {
            self.layer.borderColor = localSettings.colours[4].cgColor
            self.layer.borderWidth = localSettings.borderWeight
        }
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(executeTapAction))
        tapG.numberOfTapsRequired = 1
        addGestureRecognizer(tapG)
        
        if actionList != nil {
            openAppAction = actionList?.first
        }
        
        self.backgroundColor = localSettings.colours.first
        self.axis = .vertical
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.layer.cornerRadius = 24
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        if let droppedActionList = actionList?.dropFirst() {
            if !droppedActionList.isEmpty {
                hasActions = true
                spacerTopTop = UIView()
                spacerTopTop.translatesAutoresizingMaskIntoConstraints = false
                self.addArrangedSubview(spacerTopTop)
                //Constraints
                spacerTopTop.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
                spacerTopTop.heightAnchor.constraint(equalToConstant: NBBannerManager.sharedInstance.statusBarHeight).isActive = true
            }
            
            for action in droppedActionList {
                let actionButton = action.behavior == 1 ? NBTextInputActionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), actionBlob: action) : NBActionButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), actionBlob: action)
                
                if localSettings.borderColours {
                    actionButton.layer.borderColor = localSettings.colours[5].cgColor
                    actionButton.layer.borderWidth = localSettings.borderWeight
                }
                
                actionButton.translatesAutoresizingMaskIntoConstraints = false
                self.addArrangedSubview(actionButton)
                //Constraints
                actionButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
                actionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
        }
        
        spacerTop = UIView()
        spacerTop.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(spacerTop)
        //Constraints
        spacerTop.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        spacerTop.heightAnchor.constraint(equalToConstant: NBBannerManager.sharedInstance.statusBarHeight).isActive = true

        if headerText.count > 0 {
            hasTopText = true
            
            headerView = NBIconLabelView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 20), string: headerText, iconImage: icon)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(headerView)

            //Constraints
            headerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
            headerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            headerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: insets).isActive = true
        }
        
        if (titleText.count > 0 || subtitleText.count > 0) {
            if hasTopText == true {
                titleLabel = UILabel()
                titleLabel.textColor = localSettings.colours[1]
                titleLabel.font = .systemFont(ofSize: 14)
                titleLabel.text = (titleText.count > 0) ? titleText : subtitleText
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                self.addArrangedSubview(titleLabel)
                
                //Constraints
                titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
                titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: insets).isActive = true
            } else {
                hasTopText = true
                headerView = NBIconLabelView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 20), string: (titleText.count > 0) ? titleText : subtitleText, iconImage: icon)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                self.addArrangedSubview(headerView)

                //Constraints
                headerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
                headerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                headerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: insets).isActive = true
            }
        }
        
        if bodyText.count > 0 {
            bodyLabel = UILabel()
            bodyLabel.textColor = localSettings.colours[1]
            bodyLabel.font = .systemFont(ofSize: 12)
            bodyLabel.lineBreakMode = .byWordWrapping
            bodyLabel.numberOfLines = 5
            bodyLabel.text = bodyText
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(bodyLabel)
            
            //Constraints
            bodyLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
            bodyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: insets).isActive = true
        }
        
        spacerBottom = UIView()
        spacerBottom.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(spacerBottom)
        //Constraints
        spacerBottom.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        spacerBottom.heightAnchor.constraint(equalToConstant: insets).isActive = true
        
        
    }
    
    func textInputButton() -> NBTextInputActionView? {
        for view in self.arrangedSubviews {
            if view.responds(to: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:))) {
                return (view as! NBTextInputActionView)
            }
        }
        return nil
    }
    
    @objc func executeTapAction() {
        openAppAction?.actionRunner.executeAction(openAppAction, fromOrigin: nil, endpoint: nil, withParameters: openAppAction?.behaviorParameters, completion: { finished in
            DispatchQueue.main.async {
                NBBannerManager.sharedInstance.dismissAllWindows()
            }
        })
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
