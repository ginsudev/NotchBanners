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
    static var borderWeight: Double!
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
        
        if localSettings.colouringStyle == 2 {
            if request.content.icon != nil {
                localSettings.colours = NBBannerManager.sharedInstance.getAdaptiveColours(forImage: request.content.icon)
            }
        }

        //Create an NBContent object containing important data needed for the initialisation of our own banner system.
        let content = NBContent(header: request.content.header ?? "",
                                title: request.content.title ?? "",
                                subtitle: request.content.subtitle ?? "",
                                body: request.options.contentPreviewSetting != 2 ? (request.content.message ?? "") : (request.content.header ?? ""),
                                icon: request.content.icon ?? UIImage(systemName: "app.badge.fill"),
                                actions: actions,
                                dismissAutomatically: request.options.dismissAutomatically)

        //Create & present the banner with our content.
        NBBannerManager.sharedInstance.createBannerWindow(withContent: content)

        /* Finally, create a ToneLibrary Alert (TLAlert) with the TLAlertConfiguration property
        found in the NCNotificationRequest's NCNotificationSound object. */
        if let alertConfig = request.sound?.alertConfiguration {
            //Play banner sound.
            let tl_alert = TLAlert(configuration: alertConfig)
            tl_alert?.play()
        }
    }
}

class DNDNotificationsService_Hook: ClassHook<DNDNotificationsService> {
    
    func stateService(_ arg1: AnyObject, didReceiveDoNotDisturbStateUpdate update: DNDStateUpdate) {
        orig.stateService(arg1, didReceiveDoNotDisturbStateUpdate: update)
        UserDefaults.standard.set((update.state.isActive && update.state.suppressionState == 1), forKey: "NotchBanners_DND")
    }
}

//MARK: - Preferences
func readPrefs() {
    
    let path = "/var/mobile/Library/Preferences/com.ginsu.notchbanners.plist"
    
    if !FileManager().fileExists(atPath: path) {
        try? FileManager().copyItem(atPath: "Library/PreferenceBundles/notchbanners.bundle/defaults.plist", toPath: path)
    }
    
    guard let dict = NSDictionary(contentsOfFile: path) else {
        return
    }
    
    //Reading values
    localSettings.isEnabled = dict.value(forKey: "isEnabled") as? Bool ?? true
    localSettings.colouringStyle = dict.value(forKey: "colouringStyle") as? Int ?? 1
    localSettings.colours = [UIColor(hexString: dict.value(forKey: "bgColour") as? String ?? "#000000FF"),
                             UIColor(hexString: dict.value(forKey: "textColour") as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict.value(forKey: "buttonColour") as? String ?? "#7F7F7FFF"),
                             UIColor(hexString: dict.value(forKey: "buttonTextColour") as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict.value(forKey: "bannerBorderColour") as? String ?? "#FEFFFEFF"),
                             UIColor(hexString: dict.value(forKey: "buttonBorderColour") as? String ?? "#FEFFFEFF")]
    localSettings.customWidth = dict.value(forKey: "customWidth") as? Bool ?? false
    localSettings.customWidthValue = dict.value(forKey: "customWidthValue") as? Double ?? 209.0
    localSettings.dismissTime = dict.value(forKey: "dismissTime") as? Double ?? 5.0
    localSettings.borderColours = dict.value(forKey: "borderColours") as? Bool ?? false
    localSettings.borderWeight = dict.value(forKey: "borderWeight") as? Double ?? 2.0
    
}

struct NotchBanners: Tweak {
    init() {
        readPrefs()
        if (localSettings.isEnabled) {
            tweak().activate()
        }
    }
}
