//
//  GamScene.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 24/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    weak var firstViewController: FirstViewController!
    
    var tileArray: [[Tile]] = [[Tile]]()
    var posX = 0
    var posY = 0
    var marginX = 40
    var marginY = 195
    let rows = 16
    let columns = 9
    let nodeSize = 40
    var mapSize = 0
    
    var playerPos = CGPoint(x: 2, y: 11)
    var targetPos = CGPoint(x: 6, y: 7)
    var alreadyFoundTarget = false
    var targetId = 0
    var playerId = 0
    var movingPlayer = false
    var movingTarget = false
    var movableNode : SKNode?
    var movablePlayer = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 3)
    var movableTarget = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 3)
    
    let startButton = SKSpriteNode(imageNamed: "start")
    let clearButton = SKSpriteNode(imageNamed: "trash")
    let moreButton = SKSpriteNode(imageNamed: "settings")
    
    var paintIdList : [Int] = [Int]()
    var pathIdList : [Int] = [Int]()
    var shouldDraw = false
    var shouldPaint = false
    var impossiblePath = false
    var timer : Timer? = Timer()
    var drawingSpeed = 0.05
    var diagonalCost = 1.5
    var heuristics = "Euclidean"
    
    //A* variables
    var lowestCostId = 0
    var lowestCostIndex = 0
    var openList : [Tile] = [Tile]()
    var closedList : [Tile] = [Tile]()
    typealias Pos = (x: Int, y: Int)
    
    //Dijkstra and Breadth-first variables
    var unexploredList : [Tile] = [Tile]()
    
    override func didMove(to view: SKView) {
    
        self.addChild(movablePlayer)
        self.addChild(movableTarget)
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        var id = 0
        for column in 0...columns-1 {
            tileArray.append([Tile]())
            for row in 0...rows-1 {
                
                let square = Tile()
                
                posX = marginX + column * (nodeSize+2)
                posY = marginY + row * (nodeSize+2)
                
                square.tile.fillColor = Colors.instance.purple
                square.tile.strokeColor = .clear
                
                square.tile.position = CGPoint(x: posX, y: posY)
                
                square.id = id
                square.x = column
                square.y = row
                id += 1
                
                self.tileArray[column].append(square)
                self.addChild(square.tile)
                
            }
        }
        mapSize = columns*rows
        
        setPlayerAndTarget()
        createButtons()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        drawingSpeed = (1/Model.instance.speed)/10
        diagonalCost = Model.instance.diagDost
        heuristics = Model.instance.heuristics
    }
    
    func setPlayerAndTarget() {
        tileArray[Int(playerPos.x)][Int(playerPos.y)].isPlayer = true
        tileArray[Int(playerPos.x)][Int(playerPos.y)].tile.fillColor = Colors.instance.yellow
        
        tileArray[Int(targetPos.x)][Int(targetPos.y)].isTarget = true
        tileArray[Int(targetPos.x)][Int(targetPos.y)].tile.fillColor = Colors.instance.orange
                
        playerId = tileArray[Int(playerPos.x)][Int(playerPos.y)].id
        targetId = tileArray[Int(targetPos.x)][Int(targetPos.y)].id
        
        movablePlayer.fillColor = Colors.instance.yellow
        movablePlayer.position = CGPoint(x: 0, y: 0)
        movablePlayer.zPosition = 2
        movablePlayer.isHidden = true
        
        movableTarget.fillColor = Colors.instance.orange
        movableTarget.position = CGPoint(x: 0, y: 0)
        movableTarget.zPosition = 2
        movableTarget.isHidden = true
        
    }
    
    func createButtons() {
        
        startButton.position = CGPoint(x: 207, y: 120)
        startButton.zPosition = 1
        startButton.setScale(1.1)
        startButton.name = "startButton"
        startButton.isUserInteractionEnabled = false
        self.addChild(startButton)
        
        clearButton.position = CGPoint(x: 38, y: 125)
        clearButton.zPosition = 1
        clearButton.setScale(0.8)
        clearButton.name = "clearButton"
        clearButton.isUserInteractionEnabled = false
        self.addChild(clearButton)

        moreButton.position = CGPoint(x: 370, y: 125)
        moreButton.zPosition = 1
        moreButton.setScale(0.8)
        moreButton.name = "moreButton"
        moreButton.isUserInteractionEnabled = false
        self.addChild(moreButton)
        
    }
    
    func copyTileArrayToUnexploredList() {
        for column in 0...tileArray.count-1 {
            for row in 0...tileArray[0].count-1 {
                unexploredList.append(tileArray[column][row])
            }
        }
    }
    
    func euclideanDistance(x1 : Double, y1 : Double, x2 : Double, y2 : Double) -> Double {
        return sqrt(pow((x1-x2), 2) + pow((y1-y2), 2))
    }
    
    func manhattanDistance(x1 : Double, y1 : Double, x2 : Double, y2 : Double) -> Double {
        return abs(x1-x2) + abs(y1-y2)
    }
    
    func resetSearchVariables() {
        
        for column in 0...tileArray.count-1 {
            for row in 0...tileArray[0].count-1 {
                tileArray[column][row].alreadyVisitedNode = false
                tileArray[column][row].fCost = 999.0
                tileArray[column][row].gCost = 0.0
                tileArray[column][row].hCost = 0.0
                tileArray[column][row].currentTile = false
                tileArray[column][row].isOnOpenList = false
                tileArray[column][row].tile.fillColor = Colors.instance.purple
                tileArray[column][row].tile.strokeColor = .clear
                tileArray[column][row].isObstacle = false
                tileArray[column][row].parentId = 0
            }
        }
        
        impossiblePath = false
        
        unexploredList.removeAll()
        closedList.removeAll()
        openList.removeAll()
        
        setPlayerAndTarget()
        
        alreadyFoundTarget = false
        
        pathIdList.removeAll()
        paintIdList.removeAll()
    }
    
    func autoClear() {
        //when the user plays again whitout first clearing the map
        
        for column in 0...tileArray.count-1 {
            for row in 0...tileArray[0].count-1 {
                if !tileArray[column][row].isObstacle {
                    tileArray[column][row].alreadyVisitedNode = false
                    tileArray[column][row].fCost = 999.0
                    tileArray[column][row].gCost = 0.0
                    tileArray[column][row].hCost = 0.0
                    tileArray[column][row].currentTile = false
                    tileArray[column][row].isOnOpenList = false
                    tileArray[column][row].tile.fillColor = Colors.instance.purple
                    tileArray[column][row].tile.strokeColor = .clear
                    tileArray[column][row].isObstacle = false
                    tileArray[column][row].parentId = 0
                }
                
            }
        }
        
        unexploredList.removeAll()
        closedList.removeAll()
        openList.removeAll()
        
        setPlayerAndTarget()
        
        alreadyFoundTarget = false
        
        pathIdList.removeAll()
        paintIdList.removeAll()
    }
    
    func disableUserInteraction(shouldDisable: Bool) {
        self.view?.isUserInteractionEnabled = !shouldDisable
        
        if shouldDisable {
            moreButton.alpha = 0.3
            clearButton.alpha = 0.3
            startButton.alpha = 0.3
        } else {
            moreButton.alpha = 1.0
            clearButton.alpha = 1.0
            startButton.alpha = 1.0
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        if startButton.contains(pos) {
            
            if alreadyFoundTarget {
                autoClear()
            }
            if !alreadyFoundTarget {
                disableUserInteraction(shouldDisable: true)
                var success = true
                switch Model.instance.algorithm {
                case "A-star" :
                    success = aStar()
                case "Dijkstra" :
                    success = dijkstra()
                case "BFS" :
                    success = breadthFirst()
                default:
                    success = aStar()
                }
                
                let searchSuccess = tileArray[Int(targetPos.x)][Int(targetPos.y)].parentId
                if !success || searchSuccess == 0 {
                    disableUserInteraction(shouldDisable: false)
                    autoClear()
                    
                    let alert = UIAlertController(title: "Ops", message: "There's no possible path to the target. Clean the obstacles and try again.", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                    firstViewController.present(alert, animated: true)
                    
                } else {
                    createDrawPathList()
                    
                    timer = Timer.scheduledTimer(timeInterval: drawingSpeed, target: self, selector: #selector(GameScene.paintVisitedTile), userInfo: nil, repeats: true)
                }
            }
            
        } else if moreButton.contains(pos) {
            firstViewController.showSettingsPopUp()
        } else if clearButton.contains(pos) {
            resetSearchVariables()
        } else {
            for column in 0...tileArray.count-1 {
                for row in 0...tileArray[0].count-1 {
                    
                    if !((row == Int(playerPos.y) && column == Int(playerPos.x)) || (row == Int(targetPos.y) && column == Int(targetPos.x))) {
                        //if it's not the player neither the target
                        if tileArray[column][row].tile.contains(pos) && !movingPlayer && !movingTarget {
                            if !tileArray[column][row].isObstacle {
                                clearBeforePlacingObstacle(x: column, y: row)
                                tileArray[column][row].tile.fillColor = Colors.instance.gray
                                tileArray[column][row].isObstacle = true
                                
                            } else {
                                tileArray[column][row].tile.fillColor = Colors.instance.purple
                                tileArray[column][row].isObstacle = false
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func clearBeforePlacingObstacle(x: Int, y: Int) {
        tileArray[x][y].alreadyVisitedNode = false
        tileArray[x][y].fCost = 999.0
        tileArray[x][y].gCost = 0.0
        tileArray[x][y].hCost = 0.0
        tileArray[x][y].currentTile = false
        tileArray[x][y].isOnOpenList = false
        tileArray[x][y].tile.fillColor = Colors.instance.purple
        tileArray[x][y].tile.strokeColor = .clear
        tileArray[x][y].isObstacle = false
        tileArray[x][y].parentId = 0
    }
    
    func aStar() -> Bool {
        
        openList.append(tileArray[Int(playerPos.x)][Int(playerPos.y)])
        tileArray[Int(playerPos.x)][Int(playerPos.y)].isOnOpenList = true
        
        while !alreadyFoundTarget {
            
            //Looks for the lowest F cost square on the open list
            var lowestCost = 9999.0
            
            for (index, candidate) in openList.enumerated() {
                if candidate.fCost < lowestCost && candidate.alreadyVisitedNode == false {
                    lowestCost = candidate.fCost
                    lowestCostId = candidate.id
                    lowestCostIndex = index
                }
            }
            
            //lowestCostIndex is the "current square"
            if openList.isEmpty {
                impossiblePath = true
                return false
            }
            
            let currSquare = openList[lowestCostIndex]
            let currentSquarePos = CGPoint(x: currSquare.x, y: currSquare.y)
            
            //Switch it to the closed list
            tileArray[Int(currentSquarePos.x)][Int(currentSquarePos.y)].alreadyVisitedNode = true
            closedList.append(currSquare)
            
            openList.remove(at: lowestCostIndex)
            
                
            if currSquare.isTarget {
                //found target
                targetId = currSquare.id
                alreadyFoundTarget = true
                
                return true
            }
            
            //the current square on the tileArray is the tile with currentSquarePos
            //for each of the 8 squares adjacent to this current square...
            for offsetY in -1...1 {
                for offsetX in -1...1 {
                    
                    let row = Int(currentSquarePos.y) + offsetY
                    let column = Int(currentSquarePos.x) + offsetX
                    
                    if (column < columns && column >= 0) && (row >= 0 && row < rows) {
                        let nextCandidate = tileArray[column][row]
                        //if it's not out of the screen
                        if !(nextCandidate.isPlayer) {
                            //if it isn't itself
                            
                            if !(nextCandidate.isObstacle) && !(nextCandidate.alreadyVisitedNode) {
                                //if it's not an obstacle and has not been visited yet
                                //if it isn’t on the open list, add it to the open list
                                
                                if !nextCandidate.isOnOpenList {
                                   
                                    openList.append(nextCandidate)
                                    nextCandidate.isOnOpenList = true
                                    
                                    //stores the tile's id to be painted
                                    if !paintIdList.contains(nextCandidate.id){
                                        paintIdList.append(nextCandidate.id)
                                    }
                                    
                                    
                                    //make the current square the parent of this square
                                    nextCandidate.parentId = currSquare.id
                                    
                                    //record the F, G, and H costs of the square
                                    if heuristics == "Euclidean" {
                                        nextCandidate.hCost = euclideanDistance(x1: Double(column), y1: Double(row), x2: Double(targetPos.x), y2: Double(targetPos.y))
                                    } else {
                                        nextCandidate.hCost = manhattanDistance(x1: Double(column), y1: Double(row), x2: Double(targetPos.x), y2: Double(targetPos.y))
                                    }
                                    
                                    
                                    if offsetX == 0 || offsetY == 0 {
                                        //if the tile is horizontal or vertical
                                        nextCandidate.gCost = currSquare.gCost + 1
                                    } else {
                                        //if it is a diagonal
                                        nextCandidate.gCost = currSquare.gCost + diagonalCost
                                    }
                                    
                                    
                                    nextCandidate.fCost = nextCandidate.gCost + nextCandidate.hCost
                                    
                                } else {
                                    //check to see if this path to that square is better
                                    
                                    let potentialGCost = offsetX == 0 || offsetY == 0
                                        ? currSquare.gCost + 1
                                        : currSquare.gCost + diagonalCost
                                    
                                    if nextCandidate.gCost > potentialGCost {
                                        //change the parent of the square to the current square
                                        nextCandidate.parentId = currSquare.id
                                        //recalculate the G and F scores of the square
                                        nextCandidate.gCost = potentialGCost
                                        nextCandidate.fCost = nextCandidate.gCost + nextCandidate.hCost
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
        return false
    }
    
    func breadthFirst() -> Bool {
        
        //set all the node’s distances to infinity and add them to an unexplored set
        //in this case we use fCost as the distance
        copyTileArrayToUnexploredList()
        
        //Set the starting node’s distance to 0
        let startingNodePos = tileArray[Int(playerPos.x)][Int(playerPos.y)].id
        unexploredList[startingNodePos].fCost = 0
        
        while !alreadyFoundTarget {
            
            //look for the node with the lowest distance, let this be the current node
            unexploredList.sort(by: { $0.fCost > $1.fCost }) //sorts in descendent order
            let currSquare = unexploredList.last!
            let currentSquarePos = CGPoint(x: currSquare.x, y: currSquare.y)
            
            if currSquare.isTarget {
                //achou
                alreadyFoundTarget = true
                targetId = currSquare.id

                return true
            }
            
            //remove it from the unexplored set
            if unexploredList.count > 0 {
                unexploredList.removeLast()
            } else {
                impossiblePath = true
                return false
            }
            
            
            //for each of the nodes adjacent to this node…
            for offsetY in -1...1 {
                for offsetX in -1...1 {
                    let row = Int(currentSquarePos.y) + offsetY
                    let column = Int(currentSquarePos.x) + offsetX
                    
                    if (column < columns && column >= 0) && (row >= 0 && row < rows) {
                        //if it's not out of the screen
                        let nextCandidate = tileArray[column][row]
                        
                        if !(nextCandidate.isPlayer) {
                            //if it isn't itself
                            
                            if !(nextCandidate.isObstacle) {
                                
                                //stores the tile's id to be painted
                                if !paintIdList.contains(nextCandidate.id){
                                    paintIdList.append(nextCandidate.id)
                                }
                                
                                //calculate a potential new distance
                                //current node’s distance plus the distance to the adjacent node you are at
                                let potentialNewDistance = currSquare.fCost + 1
                                
                                
                                //If the potential distance is less than the adjacent node’s current distance,
                                //then set the adjacent node’s distance to the potential new distance
                                //and set the adjacent node’s parent to the current node
                                if potentialNewDistance < nextCandidate.fCost {
                                    nextCandidate.fCost = potentialNewDistance
                                    nextCandidate.parentId = currSquare.id
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        return true
    }
    
    func dijkstra() -> Bool {
        
        //set all the node’s distances to infinity and add them to an unexplored set
        //in this case we use fCost as the distance
        copyTileArrayToUnexploredList()
        
        //Set the starting node’s distance to 0
        let startingNodePos = tileArray[Int(playerPos.x)][Int(playerPos.y)].id
        unexploredList[startingNodePos].fCost = 0
        
        while !alreadyFoundTarget {
            
            //look for the node with the lowest distance, let this be the current node
            unexploredList.sort(by: { $0.fCost > $1.fCost }) //sorts in descendent order
            let currSquare = unexploredList.last!
            let currentSquarePos = CGPoint(x: currSquare.x, y: currSquare.y)
            
            if currSquare.isTarget {
                //achou
                alreadyFoundTarget = true
                targetId = currSquare.id
                return true
            }
            
            //remove it from the unexplored set
            if unexploredList.count > 0 {
                unexploredList.removeLast()
            } else {
                impossiblePath = true
                return false
            }
            
            
            //for each of the nodes adjacent to this node…
            for offsetY in -1...1 {
                for offsetX in -1...1 {
                    let row = Int(currentSquarePos.y) + offsetY
                    let column = Int(currentSquarePos.x) + offsetX
                    
                    if (column < columns && column >= 0) && (row >= 0 && row < rows) {
                        //if it's not out of the screen
                        let nextCandidate = tileArray[column][row]
                        
                        if !(nextCandidate.isPlayer) {
                            //if it isn't itself
                            
                            if !(nextCandidate.isObstacle) {
                                
                                //stores the tile's id to be painted
                                if !paintIdList.contains(nextCandidate.id){
                                    paintIdList.append(nextCandidate.id)
                                }
                                
                                //calculate a potential new distance
                                //current node’s distance plus the distance to the adjacent node you are at
                                let potentialNewDistance = offsetX == 0 || offsetY == 0
                                    ? currSquare.fCost + 1
                                    : currSquare.fCost + diagonalCost
                                
                                //If the potential distance is less than the adjacent node’s current distance,
                                //then set the adjacent node’s distance to the potential new distance
                                //and set the adjacent node’s parent to the current node
                                
                                if potentialNewDistance < nextCandidate.fCost {
                                    nextCandidate.fCost = potentialNewDistance
                                    nextCandidate.parentId = currSquare.id
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        return true
        
    }
    
    func createDrawPathList() {
        let targetPos = idToPos(id: targetId)
        var drawingTile = tileArray[targetPos.x][targetPos.y]
        
        while !drawingTile.isPlayer {
            if !drawingTile.isTarget {
                pathIdList.append(drawingTile.id)
            }
            
            let nextPos = idToPos(id: drawingTile.parentId)
            drawingTile = tileArray[nextPos.x][nextPos.y]
        }
    }
    
    @objc func paintVisitedTile() {
        
        let id = paintIdList.first
        let pos = idToPos(id: id ?? 0)
        
        if !(pos.x == Int(targetPos.x) && pos.y == Int(targetPos.y)) {
            tileArray[pos.x][pos.y].tile.fillColor = UIColor.init(displayP3Red: 135/255, green: 125/255, blue: 173/255, alpha: 1.0)
        }
        
        if paintIdList.count > 1 {
            paintIdList.removeFirst()
        } else {
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            
            timer = Timer.scheduledTimer(timeInterval: drawingSpeed, target: self, selector: #selector(GameScene.paintPath), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func paintPath() {
        
        let id = pathIdList.first
        let pos = idToPos(id: id ?? 0)
        
        tileArray[pos.x][pos.y].tile.strokeColor = Colors.instance.orange
        tileArray[pos.x][pos.y].tile.lineWidth = 3.0
        
        if pathIdList.count > 1 {
            pathIdList.removeFirst()
        } else {
            tileArray[Int(playerPos.x)][Int(playerPos.y)].tile.strokeColor = Colors.instance.yellow
            
            disableUserInteraction(shouldDisable: false)
            
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
        }
    }
    
    func idToPos(id: Int) -> Pos {
        return Pos(y: id % rows, x: Int(id/rows))
    }
    
    func posToId(pos: Pos) -> Int {
        return (rows*pos.x + pos.y)
    }
    
    
    func touchUp(atPoint pos : CGPoint) {
        if movingPlayer {
            movingPlayer = false
            for column in 0...tileArray.count-1 {
                for row in 0...tileArray[0].count-1 {
                    if tileArray[column][row].tile.contains(pos) {
                        
                        tileArray[Int(playerPos.x)][Int(playerPos.y)].isPlayer = false
                        tileArray[Int(playerPos.x)][Int(playerPos.y)].tile.fillColor = Colors.instance.purple
                        tileArray[Int(playerPos.x)][Int(playerPos.y)].tile.isHidden = false
                        
                        tileArray[column][row].tile.isHidden = false
                        tileArray[column][row].tile.fillColor = .yellow
                        tileArray[column][row].isPlayer = true
                        playerPos.x = CGFloat(column)
                        playerPos.y = CGFloat(row)
                        playerId = posToId(pos: Pos(column, row))
                        
                        movablePlayer.position = playerPos
                        
                        return
                    }
                    
                }
            }
            //se nao entrou no for quer dizer que ta pra fora da tela
            tileArray[Int(playerPos.x)][Int(playerPos.y)].tile.isHidden = false
        }
        
        if movingTarget {
            movingTarget = false
            for column in 0...tileArray.count-1 {
                for row in 0...tileArray[0].count-1 {
                    if tileArray[column][row].tile.contains(pos) {
                        
                        tileArray[Int(targetPos.x)][Int(targetPos.y)].isTarget = false
                        tileArray[Int(targetPos.x)][Int(targetPos.y)].tile.removeAllActions()
                        tileArray[Int(targetPos.x)][Int(targetPos.y)].tile.fillColor = Colors.instance.purple
                        tileArray[Int(targetPos.x)][Int(targetPos.y)].tile.isHidden = false
                        
                        tileArray[column][row].tile.isHidden = false
                        tileArray[column][row].tile.fillColor = Colors.instance.orange
                        
                        tileArray[column][row].isTarget = true
                        targetPos.x = CGFloat(column)
                        targetPos.y = CGFloat(row)
                        targetId = posToId(pos: Pos(column, row))
                        
                        movableTarget.position = targetPos
                        
                        return
                    }
                    
                }
            }
            tileArray[Int(targetPos.x)][Int(targetPos.y)].tile.isHidden = false
            
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        for column in 0...tileArray.count-1 {
            for row in 0...tileArray[0].count-1 {
                if tileArray[column][row].tile.contains(pos) {
                    if (row == Int(playerPos.y) && column == Int(playerPos.x)) {
                        //if it's moving the player
                        movingPlayer = true
                        tileArray[column][row].tile.isHidden = true
                        
                    }
                    if (row == Int(targetPos.y) && column == Int(targetPos.x)) {
                        //if it's moving the target
                        movingTarget = true
                        tileArray[column][row].tile.isHidden = true
                        
                    }
                }
            }
        }
    
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: self)) }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            for column in 0...tileArray.count-1 {
                for row in 0...tileArray[0].count-1 {
                    
                    if tileArray[column][row].tile.contains(location) && tileArray[column][row].isPlayer {
                    
                        movablePlayer.isHidden = false
                        movableNode = movablePlayer
                        movableNode!.position = location
                    }
                    if tileArray[column][row].tile.contains(location) && tileArray[column][row].isTarget {
                    
                        movableTarget.isHidden = false
                        movableNode = movableTarget
                        movableNode!.position = location
                    }
                }
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: self)) }
        if let touch = touches.first, movableNode != nil {
            movableNode!.position = touch.location(in: self)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
        if let touch = touches.first, movableNode != nil {
            movableNode!.position = touch.location(in: self)
            movableNode = nil
            movablePlayer.isHidden = true
            movableTarget.isHidden = true
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
        
        if let touch = touches.first {
            movableNode = nil
        }
    }
    
}
