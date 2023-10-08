//
//  BaseCell.swift
//  ARKitVisionObjectDetection
//
//  Created by Andrea Giachetti on 10/03/21.
//  Copyright © 2021 Rozengain. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init errore")
    }
}
