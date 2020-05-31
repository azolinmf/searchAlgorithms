//
//  Tile.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 24/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import Foundation
import SpriteKit

class Tile {
    
    var tile = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 3)
    var isPlayer = false
    var isObstacle = false
    var isTarget = false
    var alreadyVisitedNode = false
    var fCost = 999.0
    var gCost = 0.0
    var hCost = 0.0
    var currentTile = false
    var isOnOpenList = false
    var id = -1
    var parentId = 0
    var x = 0
    var y = 0

}
