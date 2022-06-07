//
//  NBStructs.swift
//  
//
//  Created by Noah Little on 8/4/2022.
//

import UIKit
import NotchBannersC

//A collection of data needed for the construction of an NBBanner*.
struct NBContent {
    var header: String!
    var title: String!
    var subtitle: String!
    var body: String!
    var icon: UIImage!
    var actions: [NCNotificationAction]?
    var dismissAutomatically: Bool!
}

/* An object that contains measurements for the screen and notch width,
needed to calculate the amount of pixels taken up by the notch. */
struct ScreenModel {
    var notchWidth_mm: Double
    var screenWidth_mm: Double
}
