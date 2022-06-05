//
//  NBIconLabelView.swift
//  
//
//  Created by Noah Little on 14/4/2022.
//

import UIKit
import NotchBannersC

//A UIView subclass that places an icon / image next to a label.
class NBIconLabelView: UIView {
    private var iconView: UIImageView!
    private var headerLabel: UILabel!
    
    init(frame: CGRect, string text: String?, iconImage icon: UIImage) {
        super.init(frame: frame)
        
        iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        headerLabel = UILabel()
        headerLabel.textColor = localSettings.colours[1]
        headerLabel.font = .systemFont(ofSize: 14)
        headerLabel.text = text
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
        
        //Constraints
        iconView.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        iconView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        headerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            iconView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            headerLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 5.0).isActive = true
        } else {
            iconView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            headerLabel.rightAnchor.constraint(equalTo: iconView.leftAnchor, constant: -5.0).isActive = true
            headerLabel.textAlignment = .right
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
