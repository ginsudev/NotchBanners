import Orion
import NotchBannersC

struct localSettings {
    static var isEnabled: Bool!
    static var colouringStyle: Int!
    static var colours: [UIColor]!
    static var customWidth: Bool!
    static var customWidthValue: Double!
    static var dismissTime: Double!
    static var borderColours: Bool!
    static var bannerBorderWeight: Double!
    static var buttonBorderWeight: Double!
    static var bordersDarkModeOnly: Bool!
    static var customButtonHeight: Bool!
    static var customButtonHeightValue: Double!
    static var adaptiveBGAlpha: Double!
    static var borderColourStyle: Int!
    static var adaptiveBorderAlpha: Double!
    static var customRadius: Bool!
    static var customButtonRadius: Bool!
    static var customRadiusValue: Double!
    static var customButtonRadiusValue: Double!
    static var showAttachments: Bool!
}

struct tweak: HookGroup {}

class SBNotificationBannerDestination_Hook: ClassHook<SBNotificationBannerDestination> {
    typealias Group = tweak

    func postNotificationRequest(_ request: AnyObject?) {
        
        guard let request = request as? NCNotificationRequest else {
            orig.postNotificationRequest(request)
            return
        }
        
        guard !UserDefaults.standard.bool(forKey: "NotchBanners_DND") else {
            target._test_dismiss(request)
            return
        }
        
        //Create an array consisting of the open action, as well as app-specific actions.
        var actions = [NCNotificationAction]()
        
        if let defaultAction = request.defaultAction {
            actions.append(defaultAction)
        }

        if request.supplementaryActions != nil {
            if let appSpecificActionArray = request.supplementaryActions.first?.value as? [AnyObject] {
                for action in appSpecificActionArray {
                    if let action = action as? NCNotificationAction {
                        actions.append(action)
                    }
                }
            }
        }
        
        //Undo changes made by the system when recieving a notification banner. This fixes a bug that only lets us recieve 1 banner.
        target._test_dismiss(request)
        
        if localSettings.colouringStyle == 2 || localSettings.borderColourStyle == 2 {
            if let icon = request.content.icon {
                localSettings.colours = icon.getAdaptiveColours()
            }
        }

        //Create an NBContent object containing important data needed for the initialisation of our own banner system.
        let content = NBContent(header: request.content.header ?? "",
                                title: request.content.title ?? "",
                                subtitle: request.content.subtitle ?? "",
                                body: request.options.contentPreviewSetting != 2 ? (request.content.message ?? "") : (request.content.header ?? ""),
                                icon: request.content.icon ?? UIImage(systemName: "app.badge.fill"),
                                actions: actions,
                                dismissAutomatically: request.options.dismissAutomatically,
                                attachmentImage: (request.content.attachmentImage != nil && localSettings.showAttachments) ? request.content.attachmentImage : nil)

        //Create & present the banner with our content.
        NBBannerManager.sharedInstance.createBannerWindow(withContent: content)

        /* Finally, create a ToneLibrary Alert (TLAlert) with the TLAlertConfiguration property
        found in the NCNotificationRequest's NCNotificationSound object. */
        if let alertConfig = request.sound?.alertConfiguration,
            let tl_alert = TLAlert(configuration: alertConfig) {
            //Play banner sound.
            tl_alert.play()
        }
    }
}

class DNDNotificationsService_Hook: ClassHook<DNDNotificationsService> {
    typealias Group = tweak

    func stateService(_ arg1: AnyObject, didReceiveDoNotDisturbStateUpdate update: DNDStateUpdate) {
        orig.stateService(arg1, didReceiveDoNotDisturbStateUpdate: update)
        UserDefaults.standard.set((update.state.isActive && update.state.suppressionState == 1),
                                  forKey: "NotchBanners_DND")
    }
}

class SBLockStateAggregator_Hook: ClassHook<SBLockStateAggregator> {
    typealias Group = tweak
    
    func _updateLockState() {
        orig._updateLockState()
        
        /* Lock states
         0 = Device unlocked and lock screen dismissed.
         1 = Device unlocked and lock screen not dismissed.
         2 = Locking... ??
         3 = Locked.
        */
        
        guard !NBBannerManager.sharedInstance.activeWindows.isEmpty else {
            return
        }
        
        if target.lockState() == 2 || target.lockState() == 3 {
            NBBannerManager.sharedInstance.dismissAllWindows()
        }
    }
}

//MARK: - Preferences
fileprivate func prefsDict() -> [String : AnyObject]? {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    
    let path = "/var/mobile/Library/Preferences/com.ginsu.notchbanners.plist"
    
    if !FileManager().fileExists(atPath: path) {
        try? FileManager().copyItem(atPath: "Library/PreferenceBundles/notchbanners.bundle/defaults.plist",
                                    toPath: path)
    }
    
    let plistURL = URL(fileURLWithPath: path)

    guard let plistXML = try? Data(contentsOf: plistURL) else {
        return nil
    }
    
    guard let plistDict = try! PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String : AnyObject] else {
        return nil
    }
    
    return plistDict
}

fileprivate func readPrefs() {
    
    let dict = prefsDict() ?? [String : AnyObject]()
    
    //Reading values
    localSettings.isEnabled = dict["isEnabled"] as? Bool ?? true
    localSettings.colouringStyle = dict["colouringStyle"] as? Int ?? 1
    localSettings.colours = [UIColor(hexString: dict["bgColour"] as? String ?? "#000000FF"),
                             UIColor(hexString: dict["textColour"] as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict["buttonColour"] as? String ?? "#7F7F7FFF"),
                             UIColor(hexString: dict["buttonTextColour"] as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict["bannerBorderColour"] as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict["buttonBorderColour"] as? String ?? "#FEFFFEFF")]
    localSettings.customWidth = dict["customWidth"] as? Bool ?? false
    localSettings.customWidthValue = dict["customWidthValue"] as? Double ?? 209.0
    localSettings.dismissTime = dict["dismissTime"] as? Double ?? 5.0
    localSettings.borderColours = dict["borderColours"] as? Bool ?? false
    localSettings.bannerBorderWeight = dict["bannerBorderWeight"] as? Double ?? 2.0
    localSettings.buttonBorderWeight = dict["buttonBorderWeight"] as? Double ?? 2.0
    localSettings.bordersDarkModeOnly = dict["bordersDarkModeOnly"] as? Bool ?? false
    localSettings.customButtonHeight = dict["customButtonHeight"] as? Bool ?? false
    localSettings.customButtonHeightValue = dict["customButtonHeightValue"] as? Double ?? 50.0
    localSettings.adaptiveBGAlpha = dict["adaptiveBGAlpha"] as? Double ?? 1.0
    localSettings.borderColourStyle = dict["borderColourStyle"] as? Int ?? 1
    localSettings.adaptiveBorderAlpha = dict["adaptiveBorderAlpha"] as? Double ?? 1.0
    localSettings.customRadius = dict["customRadius"] as? Bool ?? false
    localSettings.customRadiusValue = dict["customRadiusValue"] as? Double ?? 24.0
    localSettings.customButtonRadius = dict["customButtonRadius"] as? Bool ?? false
    localSettings.customButtonRadiusValue = dict["customButtonRadiusValue"] as? Double ?? 14.0
    localSettings.showAttachments = dict["showAttachments"] as? Bool ?? false
}

struct NotchBanners: Tweak {
    init() {
        readPrefs()
        if (localSettings.isEnabled) {
            tweak().activate()
        }
    }
}
