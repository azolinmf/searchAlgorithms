//
//  Model.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 26/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Model {
    
    static let instance = Model()
    
    internal init() {
        notFirstLaunch = UserDefaults.standard.bool(forKey: "notFirstLaunch")
    }
    
    var algorithm = "A-star"
    var speed = 1.5
    var diagDost = 1.5
    var heuristics = "Euclidean"
    
    var notFirstLaunch: Bool {
        didSet{
            UserDefaults.standard.set(self.notFirstLaunch, forKey: "notFirstLaunch")
        }
    }
    
    var hints = [
        Hint(hintIcon: UIImage(named: "chooseIcon")!, hintTitle: "Choose the algorithm", hintDescription: "Pick the algorithm you want to run to search for the shortest path."),
        Hint(hintIcon: UIImage(named: "adaptIcon")!, hintTitle: "Adapt the settings", hintDescription: "You can change the speed of excecution, the diagonal cost and the heuristics (for algorithms that use these)."),
        Hint(hintIcon: UIImage(named: "puzzleIcon")!, hintTitle: "Place obstacles", hintDescription: "Touch on the grid to place or remove obstacles and see how the search develops itself."),
        Hint(hintIcon: UIImage(named: "targetIcon")!, hintTitle: "Move beginning and target", hintDescription: "Drag and drop the beggining and target nodes to move them.")
    ]
    
}
