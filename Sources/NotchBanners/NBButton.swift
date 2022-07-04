//
//  NBButton.swift
//  
//
//  Created by Noah Little on 4/7/2022.
//

import UIKit
import NotchBannersC

protocol NBButton: UIView {
    var action: NCNotificationAction! { get set }
    func prepareActionExecution()
}
