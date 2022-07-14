import Preferences
import Foundation
import notchbannersC

class RootListController: PSListController {
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            } else {
                let specifiers = loadSpecifiers(fromPlistName: "Root", target: self)
                setValue(specifiers, forKey: "_specifiers")
                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.keyboardDismissMode = .onDrag

        if let icon = UIImage(named: "/Library/PreferenceBundles/notchbanners.bundle/PrefIcon.png") {
            self.navigationItem.titleView = UIImageView(image: icon)
        }
        
        let applyButton = GSRespringButton()
        self.navigationItem.rightBarButtonItem = applyButton
    }
    
    override func readPreferenceValue(_ specifier: PSSpecifier!) -> Any! {
        let path = "/User/Library/Preferences/com.ginsu.notchbanners.plist"
        let settings = NSMutableDictionary()
        let pathDict = NSDictionary(contentsOfFile: path)
        settings.addEntries(from: pathDict as! [AnyHashable : Any])
        return ((settings[specifier.properties["key"]!]) != nil) ? settings[specifier.properties["key"]!] : specifier.properties["default"]
    }
    
    override func setPreferenceValue(_ value: Any!, specifier: PSSpecifier!) {
        let path = "/User/Library/Preferences/com.ginsu.notchbanners.plist"
        let settings = NSMutableDictionary()
        let pathDict = NSDictionary(contentsOfFile: path)
        settings.addEntries(from: pathDict as! [AnyHashable : Any])
        settings.setObject(value!, forKey: specifier.properties["key"] as! NSCopying)
        settings.write(toFile: path, atomically: true)
    }
    
    override func tableViewStyle() -> UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        } else {
            return .grouped
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return GSHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 200),
                                twitterHandle: "ginsudev",
                                developerName: "Ginsu",
                                tweakName: "NotchBanners",
                                tweakVersion: "v2.2.4",
                                email: "njl02@outlook.com",
                                discordURL: "https://discord.gg/BhdUyCbgkZ",
                                donateURL: "https://paypal.me/xiaonuoya")
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 150 : 45
    }
    
    override func _returnKeyPressed(_ arg1: Any!) {
        self.view.endEditing(true)
    }

}
