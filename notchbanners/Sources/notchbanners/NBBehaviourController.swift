import Preferences
import Foundation
import notchbannersC

class NBBehaviourController: PSListController {
    private var name = "notchbanners"

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
                    
                    if let specifierCell: UITableViewCell = dynamicSpecifier.property(forKey: PSTableCellKey) as? UITableViewCell {
                        specifierCell.clipsToBounds = shouldHide
                        
                        if shouldHide {
                            if !hiddenSpecifiers.contains(dynamicSpecifier) {
                                hiddenSpecifiers.append(dynamicSpecifier)
                            }
                            return 0
                        }

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
        
        //Hide for all values except one... Useful for list controllers.
        if components.count == 3 {
            let shouldStayVisible: Bool = components[1] == "s" //s for show, h for hide.
            
            if shouldStayVisible {
                if hiddenSpecifiers.contains(opposingSpecifier!) {
                    return true
                }
                
                if opposingValue.intValue == requiredValue {
                    return false
                }
                
                return true
            }
        }
        
        //If there's no h or s in the dynamicRule, don't do anything fancy...
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
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        
        let plistURL = URL(fileURLWithPath: "/User/Library/Preferences/com.ginsu.\(name).plist")

        guard let plistXML = try? Data(contentsOf: plistURL) else {
            return specifier.properties["default"]
        }
        
        guard let plistDict = try! PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String : AnyObject] else {
            return specifier.properties["default"]
        }
        
        guard let value = plistDict[specifier.properties["key"] as! String] else {
            return specifier.properties["default"]
        }
        
        return value    }
    
    override func setPreferenceValue(_ value: Any!, specifier: PSSpecifier!) {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        
        let plistURL = URL(fileURLWithPath: "/User/Library/Preferences/com.ginsu.\(name).plist")

        guard let plistXML = try? Data(contentsOf: plistURL) else {
            return
        }
        
        guard var plistDict = try! PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String : AnyObject] else {
            return
        }
    
        plistDict[specifier.properties["key"] as! String] = value! as AnyObject
        
        do {
            let newData = try PropertyListSerialization.data(fromPropertyList: plistDict, format: propertyListFormat, options: 0)
            try newData.write(to: plistURL)
        } catch {
            return
        }
        
        if hasDynamicSpecifiers {
            if let specifierID = specifier.property(forKey: PSIDKey) as? String {
                let dynamicSpecifier = self.dynamicSpecifiers[specifierID]
                
                guard dynamicSpecifier != nil else {
                    return
                }
                
                self.table.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadSpecifiers()
        self.table.reloadData()
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
