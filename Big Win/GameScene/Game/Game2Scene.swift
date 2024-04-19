//
//  Game2Scene.swift
//  Big Win
//
//  Created by Anton on 18/4/24.
//

import Foundation
import SpriteKit
import SwiftUI

class Game2Scene: SKScene, SKPhysicsContactDelegate {

    let gameId = UUID().uuidString
    
    var timeLeft = 1200 {
        didSet {
           let time = secondsToMinutesAndSeconds(seconds: timeLeft)
           gameTimeLabel.text = "\(time.0):\(time.1)"
        }
    }
    private var gameTimeLabel: SKLabelNode!
    var gameTimer = Timer()
    
    private var homeBtn: SKSpriteNode!
    private var refreshBtn: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = CGSize(width: 750, height: 1335)
        drawBackground()
        createMenuItems()
        makeZone()
          
        gameTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTimerFunc), userInfo: nil, repeats: true)
    }
    
    
    private func drawBackground() {
        let background = SKSpriteNode(imageNamed: "game_1_back")
        background.name = "background"
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }
    
    @objc private func gameTimerFunc() {
        timeLeft -= 1
        if timeLeft == 0 {
            gameOverFunc()
            NotificationCenter.default.post(name: Notification.Name("GAMA_OVER"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": 0, "lifes": 0, "timeLeft": timeLeft])
        }
    }
    
    private func createMenuItems() {
        gameTimeLabel = SKLabelNode(text: "04:00")
        gameTimeLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        gameTimeLabel.fontSize = 32
        gameTimeLabel.fontName = "Lemonada-Bold"
        addChild(gameTimeLabel)
        
        homeBtn = SKSpriteNode(imageNamed: "ic_home")
        homeBtn.position = CGPoint(x: size.width - 60, y: size.height - 90)
        homeBtn.size = CGSize(width: 48, height: 42)
        homeBtn.name = "home"
        addChild(homeBtn)
        
        refreshBtn = SKSpriteNode(imageNamed: "refresh")
        refreshBtn.position = CGPoint(x: size.width - 60, y: size.height - 90 - homeBtn.size.height - 24)
        refreshBtn.size = CGSize(width: 48, height: 42)
        refreshBtn.name = "refresh"
        addChild(refreshBtn)
    }
    
    private func gameOverFunc() {
        gameTimer.invalidate()
    }
    
    func secondsToMinutesAndSeconds(seconds: Int) -> (Int, Int) {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return (minutes, remainingSeconds)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        guard !nodes(at: location).contains(homeBtn) else {
            NotificationCenter.default.post(name: Notification.Name("TO_HOME"), object: nil, userInfo: nil)
            return
        }
        
        guard !nodes(at: location).contains(refreshBtn) else {
            for block in blocksPutted {
                block.removeFromParent()
            }
            return
        }
        
        for node in nodes(at: location) {
            if node.name?.contains("zone_item") == true {
                let comp = node.name?.components(separatedBy: "_") ?? []
                let column = Int(comp[3]) ?? 0
                let row = Int(comp[2]) ?? 0
                putSomeBlockToConstruct(col: column, row: row)
                break
            }
        }
    }
    
    private var currentShape: Shape!
    
    private var blocksPutted: [SKNode] = []
    
    private func putSomeBlockToConstruct(col: Int, row: Int) {
        currentShape = Shape.random(startingColumn: col, startingRow: row)
        let sprite = SKSpriteNode(imageNamed: "block_apple")
        sprite.size = CGSize(width: blockWidth, height: blockHeight)
        sprite.position = pointFor(column: col, row: row)
        addChild(sprite)
        blocksPutted.append(sprite)
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(x: CGFloat(column) * blockWidth + blockWidth / 2, y: CGFloat(row) * blockHeight + blockHeight / 1.70)
    }
    
    var blockWidth: CGFloat = 30
    var blockHeight: CGFloat = 30

    private func makeZone() {
        let zoneItemWidth = Int(size.width) / GameboardColumns
        let zoneItemHeight = Int(size.height - 260) / GameboardRows
        blockWidth = CGFloat(zoneItemWidth)
        blockHeight = CGFloat(zoneItemHeight)
        for column in 0..<GameboardRows {
            for row in 0..<GameboardColumns {
                let x = row * zoneItemWidth + (zoneItemWidth / 2)
                let y = column * zoneItemHeight + 70
                makeZoneItem(x: CGFloat(x), y: CGFloat(y), width: zoneItemWidth, height: zoneItemHeight, column: column, row: row)
            }
        }
    }
    
    private func makeZoneItem(x: CGFloat, y: CGFloat, width: Int, height: Int, column: Int, row: Int) {
        let zoneItem = SKSpriteNode(imageNamed: "block_zone_item")
        zoneItem.size = CGSize(width: width, height: height)
        zoneItem.position = CGPoint(x: x, y: y)
        zoneItem.name = "zone_item_\(column)_\(row)"
        addChild(zoneItem)
    }

}

let GameboardColumns = 6
let GameboardRows = 9

class Array2D<T> {
    let columns: Int
    let rows: Int
    var array: Array<T?>

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows * columns)
    }

    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row * columns + column]
        }
        set(newValue) {
            array[row * columns + column] = newValue
        }
    }
}

class Block {
    var column: Int
    var row: Int
    let color: UIColor
    var sprite: SKSpriteNode?

    init(column: Int, row: Int, color: UIColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

class Shape {
    var blocks = [Block]()
    var column: Int = 0
    var row: Int = 0
    var delegate: ShapeDelegate?
    
    var blockWidth: Int = 30
    var blockHeight: Int = 30
    
    init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    // Создание случайной фигуры
    class func random(startingColumn: Int, startingRow: Int) -> Shape {
        let shapes = [
            ShapeL(column: startingColumn, row: startingRow),
            ShapeO(column: startingColumn, row: startingRow),
            ShapeT(column: startingColumn, row: startingRow)
            // Добавьте сюда другие типы фигур, если необходимо
        ]
        let randomIndex = Int.random(in: 0..<shapes.count)
        let shape = shapes[randomIndex]
        shape.spawnBlocks()
        return shape
    }

    // Перемещение фигуры в новую позицию
    func moveTo(column: Int, row: Int, blockWidth: Int, blockHeight: Int) {
        self.blockWidth = blockWidth
        self.blockHeight = blockHeight
        self.column = column
        self.row = row
        for block in blocks {
            block.sprite?.position = pointFor(column: block.column + column, row: block.row + row,  w: blockWidth, h: blockHeight)
        }
    }

    // Опускание фигуры на одну строку
    func lowerShapeByOneRow() -> Bool {
        let newRow = row - 1
        guard isValidPosition(column: column, row: newRow) else {
            return false
        }
        moveTo(column: column, row: newRow, blockWidth: blockWidth, blockHeight: blockHeight)
        return true
    }

    // Поднятие фигуры на одну строку
    func raiseShapeByOneRow() {
        moveTo(column: column, row: row + 1, blockWidth: blockWidth, blockHeight: blockHeight)
    }

    // Проверка текущего положения фигуры
    func isValidPosition(column: Int, row: Int) -> Bool {
        for block in blocks {
            let (blockColumn, blockRow) = (block.column + column, block.row + row)
            // Проверяем, находится ли блок в пределах игрового поля
            guard blockColumn >= 0 && blockColumn < GameboardColumns && blockRow >= 0 && blockRow < GameboardRows else {
                return false
            }
            // Проверяем, нет ли конфликтов с другими блоками на игровом поле
            guard delegate?.isBlockAt(column: blockColumn, row: blockRow) == false else {
                return false
            }
        }
        return true
    }

    // Функция, которая должна быть реализована в подклассах для создания блоков фигуры
    func spawnBlocks() {}

    func pointFor(column: Int, row: Int, w blockWidth: Int, h blockHeight: Int) -> CGPoint {
        let blockWidth: CGFloat = 30
        let blockHeight: CGFloat = 30
        return CGPoint(x: CGFloat(column) * blockWidth + blockWidth / 2, y: CGFloat(row) * blockHeight + blockHeight / 2)
    }
}

class ShapeL: Shape {
    override func spawnBlocks() {
        let color = UIColor.red // Цвет блока фигуры
        blocks.append(Block(column: 0, row: 0, color: color))
        blocks.append(Block(column: 0, row: 1, color: color))
        blocks.append(Block(column: 0, row: 2, color: color))
        blocks.append(Block(column: 1, row: 2, color: color))
    }
}

class ShapeO: Shape {
    override func spawnBlocks() {
        let color = UIColor.blue // Цвет блока фигуры
        blocks.append(Block(column: 0, row: 0, color: color))
        blocks.append(Block(column: 1, row: 0, color: color))
        blocks.append(Block(column: 0, row: 1, color: color))
        blocks.append(Block(column: 1, row: 1, color: color))
    }
}

class ShapeT: Shape {
    override func spawnBlocks() {
        let color = UIColor.green // Цвет блока фигуры
        blocks.append(Block(column: 0, row: 1, color: color))
        blocks.append(Block(column: 1, row: 1, color: color))
        blocks.append(Block(column: 2, row: 1, color: color))
        blocks.append(Block(column: 1, row: 0, color: color))
    }
}


protocol ShapeDelegate: AnyObject {
    func shapeDidDrop(shape: Shape)
    func isBlockAt(column: Int, row: Int) -> Bool
}

#Preview {
    VStack {
        SpriteView(scene: Game2Scene())
            .ignoresSafeArea()
    }
}
