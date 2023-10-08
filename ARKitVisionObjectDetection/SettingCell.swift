//
//  SettingCell.swift
//  ARKitVisionObjectDetection
//
//  Created by Andrea Giachetti on 10/03/21.
//  Copyright © 2021 Rozengain. All rights reserved.
//

import UIKit

class SettingCell: BaseCell{
    
    override var isHighlighted: Bool{
        didSet{
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        //add font
        //label.font
        return label
    }()
    
    var setting: Setting? {
        didSet{
            nameLabel.text = setting?.name
        }
    }
    
    override func setupView() {
        super.setupView()
        
        addSubview(nameLabel)
        addConstraintWithFormat(format: "H:|-16-[v0]|", views: nameLabel)
        addConstraintWithFormat(format: "V:|-16-[v0]|", views: nameLabel)
    }
}
