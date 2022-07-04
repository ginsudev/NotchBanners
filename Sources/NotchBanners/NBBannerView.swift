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
    private var buttonHeight = localSettings.customButtonHeight ? localSettings.customButtonHeightValue : 50.0
    var hasActions = false
    
    init(frame: CGRect, header headerText: String, title titleText: String, subtitle subtitleText: String, body bodyText: String, iconImage icon: UIImage, actions actionList: [NCNotificationAction]?) {
        super.init(frame: frame)
        
        if localSettings.borderColours {
            if (localSettings.bordersDarkModeOnly && UITraitCollection.current.userInterfaceStyle == .dark) || !localSettings.bordersDarkModeOnly {
                self.layer.borderColor = localSettings.borderColourStyle == 2 ? localSettings.colours[4].withAlphaComponent(localSettings.adaptiveBorderAlpha).cgColor : localSettings.colours[4].cgColor
                
                self.layer.borderWidth = localSettings.bannerBorderWeight
            }
        }
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(executeTapAction))
        tapG.numberOfTapsRequired = 1
        addGestureRecognizer(tapG)
        
        if actionList != nil {
            openAppAction = actionList?.first
        }
        
        self.backgroundColor = localSettings.colouringStyle == 2 ? localSettings.colours.first!.withAlphaComponent(localSettings.adaptiveBGAlpha) : localSettings.colours.first
        self.axis = .vertical
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.layer.cornerRadius = localSettings.customRadius ? localSettings.customRadiusValue : 24
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
            
            //Adding action buttons
            for action in droppedActionList {
                var button: NBButton
                
                if action.behavior == 1 {
                    button = NBTextInputActionButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), actionBlob: action)
                } else {
                    button = NBTapActionButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), actionBlob: action)
                }
                
                button.translatesAutoresizingMaskIntoConstraints = false
                
                if localSettings.borderColours {
                    if localSettings.borderColourStyle == 2 {
                        button.layer.borderColor = localSettings.colours[5].withAlphaComponent(localSettings.adaptiveBorderAlpha).cgColor
                    } else {
                        button.layer.borderColor = localSettings.colours[5].cgColor
                    }
                    
                    button.layer.borderWidth = localSettings.buttonBorderWeight
                }
                
                addActionButton(button)
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
    
    func addActionButton(_ button: NBButton) {
        addArrangedSubview(button)
        //Constraints
        button.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(insets*2)).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight!).isActive = true
    }
    
    func textInputButton() -> NBTextInputActionButton? {
        if let textButton = arrangedSubviews.first(where: {$0 is NBTextInputActionButton}) as? NBTextInputActionButton {
            return textButton
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
