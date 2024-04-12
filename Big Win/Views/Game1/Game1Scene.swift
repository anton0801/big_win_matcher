//
//  Game1Scene.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import Foundation
import SpriteKit
import SwiftUI
import CoreGraphics

struct CGLine {
    var start: CGPoint
    var end: CGPoint
}

class Game1Scene: SKScene, SKPhysicsContactDelegate {
    
    private var gameId = UUID().uuidString
    
    private var elements = [
        "game_1_item_1",
        "game_1_item_2",
        "game_1_item_3",
        "game_1_item_4",
        "game_1_item_5",
        "game_1_item_6",
        "game_1_item_7",
    ]
    
    private var objectiveElement = ""
    private var objectiveCount = 0 {
        didSet {
            objectiveElementsLabel.text = "\(objectiveCount)/\(objectiveMaxCount)"
            if objectiveCount >= objectiveMaxCount {
                gameOver()
                NotificationCenter.default.post(name: Notification.Name("GAME_WIN"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": objectiveCount, "lifes": lifes, "timeLeft": timeLeft])
            }
        }
    }
    private var objectiveMaxCount = 0
    private let objectivesCount = [10, 20, 30, 40, 50]
    
    private var objectiveElementsLabel: SKLabelNode!
    var gameTimer = Timer()
    
    var timeLeft = 240 {
        didSet {
            let time = secondsToMinutesAndSeconds(seconds: timeLeft)
            gameTimeLabel.text = "0\(time.0):\(time.1)"
            if timeLeft == 0 {
                gameOver()
                NotificationCenter.default.post(name: Notification.Name("GAMA_OVER"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": objectiveCount, "lifes": lifes, "timeLeft": timeLeft])
            }
        }
    }
    
    private var lifes = 15 {
        didSet {
            lifeLabel.text = "\(lifes)"
            if lifes == 0 {
                gameOver()
                NotificationCenter.default.post(name: Notification.Name("GAMA_OVER"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": objectiveCount, "lifes": lifes, "timeLeft": timeLeft])
            }
        }
    }
    private var lifeLabel: SKLabelNode!
    
    func secondsToMinutesAndSeconds(seconds: Int) -> (Int, Int) {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return (minutes, remainingSeconds)
    }
    
    private var gameTimeLabel: SKLabelNode!
    private var homeBtn: SKSpriteNode!
    
    private func gameOver() {
        gameTimer.invalidate()
    }
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = CGSize(width: 750, height: 1335)
        
        objectiveElement = elements.randomElement() ?? "game_1_item_1"
        objectiveMaxCount = objectivesCount.randomElement() ?? 10
        
        drawBackground()
        createMenuItems()
        invisibleRec()
        
        gameTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTimerFunc), userInfo: nil, repeats: true)
        
        createLife()
        
        addStartElements()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    private func invisibleRec() {
        let invisibleRectangle = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 10))
        invisibleRectangle.position = CGPoint(x: self.size.width / 2, y: 0)
        invisibleRectangle.name = "bounds1"
        invisibleRectangle.physicsBody = SKPhysicsBody(rectangleOf: invisibleRectangle.size)
        invisibleRectangle.physicsBody?.isDynamic = false
        invisibleRectangle.physicsBody?.affectedByGravity = false
        addChild(invisibleRectangle)
        
        let invisibleRectangle2 = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1335))
        invisibleRectangle2.position = CGPoint(x: 0, y: size.height / 2)
        invisibleRectangle2.physicsBody = SKPhysicsBody(rectangleOf: invisibleRectangle2.size)
        invisibleRectangle2.name = "bounds2"
        invisibleRectangle2.physicsBody?.isDynamic = false
        invisibleRectangle2.physicsBody?.affectedByGravity = false
        addChild(invisibleRectangle2)
        
        let invisibleRectangle3 = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1335))
        invisibleRectangle3.position = CGPoint(x: size.width, y: size.height / 2)
        invisibleRectangle3.physicsBody = SKPhysicsBody(rectangleOf: invisibleRectangle3.size)
        invisibleRectangle3.name = "bounds3"
        invisibleRectangle3.physicsBody?.isDynamic = false
        invisibleRectangle3.physicsBody?.affectedByGravity = false
        addChild(invisibleRectangle3)
    }
    
    var previousLocation: CGPoint?
    private let nodeNamesNoDelete = ["background", "bounds1", "bounds2", "bounds3"]
    
    var lines = [SKShapeNode]()
    var lastPoint: CGPoint?
    
    private var newElementsEvent = SingleEvent()
    private var objectiveAddEvent = SingleEvent()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        guard !nodes(at: location).contains(homeBtn) else {
            NotificationCenter.default.post(name: Notification.Name("TO_HOME"), object: nil, userInfo: nil)
            return
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let sceneLocation = convertPoint(fromView: location)
        
        switch gesture.state {
        case .began:
            previousLocation = sceneLocation
        case .changed:
            guard let previousLocation = self.previousLocation else { return }
                        
            let path = CGMutablePath()
            path.move(to: previousLocation)
            path.addLine(to: sceneLocation)
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .white
            line.lineWidth = 0
            
            line.position = CGPoint(x: sceneLocation.x, y: sceneLocation.y)
            
            addChild(line)
            
            // Добавляем линию в массив линий
            lines.append(line)
            
            self.previousLocation = sceneLocation
        case .ended, .cancelled:
            newElementsEvent = SingleEvent()
            objectiveAddEvent = SingleEvent()
            var nodesToRemove = [SKNode]()
            for line in lines {
                print("line pos x \(line.position.x) y \(line.position.y)")
                let nodesAtLine = nodes(at: line.position)
                for node in nodesAtLine {
                    if !nodeNamesNoDelete.contains(node.name ?? "") && node.name?.contains("item_") == true {
                        nodesToRemove.append(node)
                        break
                    }
                }
                
                line.removeFromParent()
            }
            for nodesUnique in nodesToRemove {
                removeElementItem(node: nodesUnique)
            }
            lines.removeAll()
        default:
            break
        }
    }
    
    private var currentMatch = [SKNode]()
    
    private var removesCount = 0
    
    private func removeElementItem(node: SKNode) {
        let action = SKAction.fadeOut(withDuration: 0.1)
        node.run(action)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            node.removeFromParent()
        }
        if node.name == objectiveElement {
            if !objectiveAddEvent.isDataRead {
                objectiveCount += 1
                objectiveAddEvent.storeData(data: true)
            }
        }
        
        if !newElementsEvent.isDataRead {
            for _ in 0..<3 {
                dropElement()
            }
            newElementsEvent.storeData(data: true)
        }
    }
    
    private func createLife() {
        let lifesIcon = SKSpriteNode(imageNamed: "life")
        lifesIcon.position = CGPoint(x: size.width / 2 - 10, y: size.height - 180)
        addChild(lifesIcon)
        
        lifeLabel = SKLabelNode(text: "15")
        lifeLabel.position = CGPoint(x: size.width / 2 + 25, y: size.height - 190)
        lifeLabel.fontSize = 24
        lifeLabel.fontName = "Lemonada-Bold"
        addChild(lifeLabel)
    }
    
    @objc private func gameTimerFunc() {
        timeLeft -= 1
        if timeLeft == 0 {
            gameOver()
            NotificationCenter.default.post(name: Notification.Name("GAMA_OVER"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": objectiveCount, "lifes": lifes, "timeLeft": timeLeft])
        }
    }
    
    private func drawBackground() {
        let background = SKSpriteNode(imageNamed: "game_1_back")
        background.name = "background"
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }

    private func createMenuItems() {
        let objectiveElementIcon = SKSpriteNode(imageNamed: objectiveElement)
        objectiveElementIcon.position = CGPoint(x: 70, y: size.height - 90)
        objectiveElementIcon.size = CGSize(width: 52, height: 52)
        addChild(objectiveElementIcon)
        
        objectiveElementsLabel = SKLabelNode(text: "0/\(objectiveMaxCount)")
        objectiveElementsLabel.position = CGPoint(x: objectiveElementIcon.position.x + 80, y: size.height - 100)
        objectiveElementsLabel.fontSize = 32
        objectiveElementsLabel.fontColor = SKColor.init(red: 243, green: 215, blue: 157, alpha: 1)
        objectiveElementsLabel.fontName = "Lemonada-Bold"
        addChild(objectiveElementsLabel)
        
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
    }
    
    private func dropElement() {
        let elementRandom = elements.randomElement() ?? "game_1_item_1"
        let elementNode = SKSpriteNode(imageNamed: elementRandom)
        let xPos = Int.random(in: 0..<Int(size.width))
        elementNode.position = CGPoint(x: xPos, y: 1400)
        elementNode.size = CGSize(width: 120, height: 120)
        elementNode.physicsBody = SKPhysicsBody(circleOfRadius: elementNode.size.width / 2)
        elementNode.physicsBody?.affectedByGravity = true
        elementNode.physicsBody?.isDynamic = true
        elementNode.physicsBody?.restitution = 0.5
        elementNode.name = elementRandom
        addChild(elementNode)
    }
    
    private func addStartElements() {
        for _ in 0...7 {
            dropElement()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            for _ in 0...7 {
                self.dropElement()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for _ in 0...7 {
                self.dropElement()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            for _ in 0...7 {
                self.dropElement()
            }
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: Game1Scene())
            .ignoresSafeArea()
    }
}

class SingleEvent {
    var isDataRead = false
    private var storedData: Bool?
    
    init() {}
    
    func readData() -> Bool? {
        if !isDataRead {
            isDataRead = true
            return storedData
        }
        return nil
    }
    
    func storeData(data: Bool) {
        storedData = data
        isDataRead = true
    }
    
}
