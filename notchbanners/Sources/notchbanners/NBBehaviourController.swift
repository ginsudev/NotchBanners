import Preferences
import Foundation
import notchbannersC

class NBBehaviourController: PSListController {
    
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                self.collectDynamicSpecifiersFromArray(specifiers)
                return specifiers
            } else {
                let specifiers = loadSpecifiers(fromPlistName: "Behaviour", target: self)
                setValue(specifiers, forKey: "_specifiers")
                self.collectDynamicSpecifiersFromArray(specifiers!)
                return specifiers
            }
        }
        set {
            super.specifiers = newValue
        }
    }
    
    var hasDynamicSpecifiers: Bool!
    var dynamicSpecifiers = [String : [PSSpecifier]]()
    var hiddenSpecifiers = [PSSpecifier]()
    
    override func reloadSpecifiers() {
        super.reloadSpecifiers()
        self.collectDynamicSpecifiersFromArray(self.specifiers!)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard hasDynamicSpecifiers else {
            return UITableView.automaticDimension
        }
                
        if let dynamicSpecifier = specifier(at: indexPath) {
            for array in dynamicSpecifiers.values {
                if array.contains(dynamicSpecifier) {
                    let shouldHide = shouldHideSpecifier(dynamicSpecifier)
                    
                    let specifierCell: UITableViewCell = dynamicSpecifier.property(forKey: PSTableCellKey) as! UITableViewCell
                    specifierCell.clipsToBounds = shouldHide
                    
                    if shouldHide {
                        if !hiddenSpecifiers.contains(dynamicSpecifier) {
                            hiddenSpecifiers.append(dynamicSpecifier)
                        }
                        return 0
                    }
                } else {
                    if hiddenSpecifiers.contains(dynamicSpecifier) {
                        hiddenSpecifiers = hiddenSpecifiers.filter({$0 != dynamicSpecifier})
                    }
                }
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func shouldHideSpecifier(_ specifier: PSSpecifier) -> Bool {
        let dynamicSpecifierRule = specifier.property(forKey: "dynamicRule") as! String
        let components: [String] = dynamicSpecifierRule.components(separatedBy: ",")
        let opposingSpecifier = self.specifier(forID: components.first)
        let opposingValue: NSNumber = self.readPreferenceValue(opposingSpecifier) as! NSNumber
        let requiredValueString: String = components.last!
        let requiredValue = Int(requiredValueString)
        
        return hiddenSpecifiers.contains(opposingSpecifier!) || opposingValue.intValue == requiredValue
    }
    
    func collectDynamicSpecifiersFromArray(_ array: NSArray) {
        if !self.dynamicSpecifiers.isEmpty {
            self.dynamicSpecifiers.removeAll()
        }
        
        var dynamicSpecifiersArray: [PSSpecifier] = [PSSpecifier]()
        
        for item in array {
            if let item = item as? PSSpecifier {
                if let dynamicSpecifierRule = item.property(forKey: "dynamicRule") as? String {
                    if dynamicSpecifierRule.count > 0 {
                        dynamicSpecifiersArray.append(item)
                    }
                }
            }
        }
        
        let groupedDict = Dictionary(grouping: dynamicSpecifiersArray, by: {($0.property(forKey: "dynamicRule") as! String).components(separatedBy: ",").first!})
                
        for key in groupedDict.keys {
            let sortedSpecifiers = groupedDict[key]!
            dynamicSpecifiers[key] = sortedSpecifiers
        }
        
        self.hasDynamicSpecifiers = (self.dynamicSpecifiers.count > 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.keyboardDismissMode = .onDrag

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
        
        if hasDynamicSpecifiers {
            if let specifierID = specifier.property(forKey: PSIDKey) as? String {
                let dynamicSpecifier = self.dynamicSpecifiers[specifierID]
                
                guard dynamicSpecifier != nil else {
                    return
                }
                
                self.table.beginUpdates()
                self.table.endUpdates()
            }
        }
    }
    
    override func tableViewStyle() -> UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        } else {
            return .grouped
        }
    }
    
    override func _returnKeyPressed(_ arg1: Any!) {
        self.view.endEditing(true)
    }
    
}
