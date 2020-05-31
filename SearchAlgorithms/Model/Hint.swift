//
//  Hint.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 29/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import Foundation
import UIKit

class Hint {
    
    internal init(hintIcon: UIImage, hintTitle: String, hintDescription: String) {
        self.hintIcon = hintIcon
        self.hintTitle = hintTitle
        self.hintDescription = hintDescription
    }
    
    var hintIcon : UIImage
    var hintTitle : String
    var hintDescription : String
    
}
