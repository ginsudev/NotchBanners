import Orion
import NotchBannersC
import AVFoundation

struct localSettings {
    static var isEnabled: Bool!
    static var colouringStyle: Int!
    static var colours: [UIColor]!
    static var customWidth: Bool!
    static var customWidthValue: Double!
}

struct tweak: HookGroup {}

class SBNotificationBannerDestination_Hook: ClassHook<SBNotificationBannerDestination> {
    typealias Group = tweak

    func postNotificationRequest(_ request: AnyObject?) {
        
        guard let request = request as? NCNotificationRequest else {
            orig.postNotificationRequest(request)
            return
        }

        //Create an array consisting of the open action, as well as app-specific actions.
        var actions = [NCNotificationAction]()
        actions.append(request.defaultAction)

        if let appSpecificActionArray = request.supplementaryActions.first?.value as? [AnyObject] {
            for action in appSpecificActionArray {
                if let action = action as? NCNotificationAction {
                    actions.append(action)
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
        let content = NBContent(header: request.content.header,
                                title: request.content.title,
                                subtitle: request.content.subtitle,
                                body: request.content.message,
                                icon: request.content.icon,
                                actions: actions,
                                dismissAutomatically: request.options.dismissAutomatically)

//        /* If a banner is already presented, we will dismiss that banner but reuse it's NBBannerWindow object to present a new banner.
//        Else, we'll create an entirely new NBBannerWindow object to present our banner. */
//        if NBBannerManager.sharedInstance.isActive {
//            NBBannerManager.sharedInstance.window.containerController.bannerController!.dismissBannerAndCreateNewWithContent(content)
//        } else {
//            NBBannerManager.sharedInstance.createBannerWindow(withContent: content)
//        }
        
        //Straight up creating a new window instance fixes an issue where some banners may not appear if >= 1 is recieved at the same time. Will need to investigate the issue further, soon..
        NBBannerManager.sharedInstance.createBannerWindow(withContent: content)

        /* Finally, create a ToneLibrary Alert (TLAlert) with the TLAlertConfiguration property
        found in the NCNotificationRequest's NCNotificationSound object. */
        if let alertConfig = request.sound?.alertConfiguration {
            //Play banner sound.
            let tl_alert = TLAlert(configuration: alertConfig)
            tl_alert?.play()
        }
    }

//    //orion: new
//    func getCraneContainerForNotificationRequest(_ request: NCNotificationRequest) -> String? {
//        guard let craneManager = CraneManager_NotchBanners.sharedManager() else {
//            return nil
//        }
//
//        let context: NSDictionary = request.context! as NSDictionary
//        let sectionIdentifier: String = request.sectionIdentifier
//
//        return craneManager.containerNameToDisplayInNotification(withUserInfoOrContext: context as? [AnyHashable : Any], ofApplicationWithIdentifier: sectionIdentifier)
//    }
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
                             UIColor(hexString: dict.value(forKey: "buttonColour") as? String ?? "#7F7F7FFF")]
    localSettings.customWidth = dict.value(forKey: "customWidth") as? Bool ?? false
    localSettings.customWidthValue = dict.value(forKey: "customWidthValue") as? Double ?? 209.0
    
}

struct NotchBanners: Tweak {
    init() {
        readPrefs()
        if (localSettings.isEnabled) {
            tweak().activate()
        }
    }
}
