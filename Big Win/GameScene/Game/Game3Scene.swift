//
//  Game3Scene.swift
//  Big Win
//
//  Created by Anton on 11/4/24.
//

import Foundation
import SwiftUI
import SpriteKit
import GameKit

class Game3Scene: SKScene, SKPhysicsContactDelegate {
    
    let gameId = UUID().uuidString
    let pegDimension: CGFloat = 20
    
    private var pegs = [(CGFloat, CGFloat)]()
    
    private let balls = ["blue_ball", "green_ball", "yellow_ball", "red_ball"]
    private var objectiveBall = ""
    private var objectiveCount = 0 {
        didSet {
            objectiveBallsLabel.text = "\(objectiveCount)/\(objectiveMaxCount)"
            if objectiveCount >= objectiveMaxCount {
                gameOver()
                NotificationCenter.default.post(name: Notification.Name("GAME_WIN"), object: nil, userInfo: ["gameId": gameId, "objectiveScore": objectiveCount, "lifes": lifes, "timeLeft": timeLeft])
            }
        }
    }
    private var objectiveMaxCount = 0
    private let objectivesCount = [10, 20, 30, 40, 50]
    
    private var caughterNode: SKSpriteNode!
    
    private var objectiveBallsLabel: SKLabelNode!
    
    var ballsTimer = Timer()
    var gameTimer = Timer()
    
    var timeLeft = 240 {
        didSet {
            let time = secondsToMinutesAndSeconds(seconds: timeLeft)
            gameTimeLabel.text = "0\(time.0):\(time.1)"
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
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        size = CGSize(width: 750, height: 1335)
        
        drawBackground()
        drawBoard()
        createCaughter()
        drawTutor()
        invisibleRec()
        
        objectiveBall = balls.randomElement() ?? "blue_ball"
        objectiveMaxCount = objectivesCount.randomElement() ?? 10
        
        ballsTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(createBall), userInfo: nil, repeats: true)
        
        createMenuItems()
        
        gameTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTimerFunc), userInfo: nil, repeats: true)
        
        createLife()
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
    
    private func gameOver() {
        gameTimer.invalidate()
        ballsTimer.invalidate()
    }
    
    private func createMenuItems() {
        let objectiveBallIcon = SKSpriteNode(imageNamed: objectiveBall)
        objectiveBallIcon.position = CGPoint(x: 70, y: size.height - 90)
        objectiveBallIcon.size = CGSize(width: 42, height: 40)
        addChild(objectiveBallIcon)
        
        objectiveBallsLabel = SKLabelNode(text: "0/\(objectiveMaxCount)")
        objectiveBallsLabel.position = CGPoint(x: objectiveBallIcon.position.x + 80, y: size.height - 102)
        objectiveBallsLabel.fontSize = 32
        objectiveBallsLabel.fontColor = SKColor.init(red: 243, green: 215, blue: 157, alpha: 1)
        objectiveBallsLabel.fontName = "Lemonada-Bold"
        addChild(objectiveBallsLabel)
        
        gameTimeLabel = SKLabelNode(text: "04:00")
        gameTimeLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        gameTimeLabel.fontSize = 32
        gameTimeLabel.fontName = "Lemonada-Bold"
        addChild(gameTimeLabel)
    }
    
    private func invisibleRec() {
        let invisibleRectangle = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 10))
        invisibleRectangle.position = CGPoint(x: self.size.width / 2, y: caughterNode.position.y - 50)
        invisibleRectangle.name = Game3Names.bounds
        invisibleRectangle.physicsBody = SKPhysicsBody(rectangleOf: invisibleRectangle.size)
        invisibleRectangle.physicsBody?.isDynamic = false
        invisibleRectangle.physicsBody?.affectedByGravity = false
        invisibleRectangle.physicsBody?.categoryBitMask = Game3Names.boundsInt
        invisibleRectangle.physicsBody?.contactTestBitMask = Game3Names.ball
        invisibleRectangle.physicsBody?.collisionBitMask = Game3Names.ball
        
        addChild(invisibleRectangle)
    }
    
    private func drawTutor() {
        let tutor = SKSpriteNode(imageNamed: "tutor")
        tutor.position = CGPoint(x: size.width / 2, y: caughterNode.position.y - 30)
        addChild(tutor)
        
        let actionMove1 = SKAction.move(to: CGPoint(x: size.width / 2 - 20, y: caughterNode.position.y - 30), duration: 0.5)
        let actionMove2 = SKAction.move(to: CGPoint(x: size.width / 2 + 20, y: caughterNode.position.y - 30), duration: 0.5)
        let action3 = SKAction.fadeOut(withDuration: 0.5)
        
        let action = SKAction.repeat(SKAction.sequence([actionMove1, actionMove2]), count: 3)
        let sequince = SKAction.sequence([action, action3])
        tutor.run(sequince)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == Game3Names.ball && contact.bodyB.categoryBitMask == Game3Names.caughterInt) ||
           (contact.bodyA.categoryBitMask == Game3Names.caughterInt && contact.bodyB.categoryBitMask == Game3Names.ball) {
            if contact.bodyA.categoryBitMask == Game3Names.ball {
                collisionBetwenObjects(ball: contact.bodyA.node!, caughter: contact.bodyB.node!)
            } else {
                collisionBetwenObjects(ball: contact.bodyB.node!, caughter: contact.bodyA.node!)
            }
        }
        
        if (contact.bodyA.categoryBitMask == Game3Names.ball && contact.bodyB.categoryBitMask == Game3Names.boundsInt) ||
           (contact.bodyA.categoryBitMask == Game3Names.boundsInt && contact.bodyB.categoryBitMask == Game3Names.ball) {
            if contact.bodyA.categoryBitMask == Game3Names.ball {
                collisionOnInvisible(ball: contact.bodyA.node!, object: contact.bodyB.node!)
            } else {
                collisionOnInvisible(ball: contact.bodyB.node!, object: contact.bodyA.node!)
            }
        }
    }
    
    private func collisionOnInvisible(ball: SKNode, object: SKNode) {
        let ballName = ball.name
        if ballName == objectiveBall {
            if objectiveCount > 0 {
                objectiveCount -= 1
                let objectiveTextVar = SKLabelNode(text: "-1")
                objectiveTextVar.position = CGPoint(x: ball.position.x, y: ball.position.y - 50)
                objectiveTextVar.fontSize = 24
                objectiveTextVar.fontName = "Lemonada-Bold"
                addChild(objectiveTextVar)
                
                let actionWait = SKAction.wait(forDuration: 0.5)
                let actionFadeOut = SKAction.fadeOut(withDuration: 0.5)
                let sequince = SKAction.sequence([actionWait, actionFadeOut])
                objectiveTextVar.run(sequince)
            }
        }
        
        ball.removeFromParent()
    }
    
    private func collisionBetwenObjects(ball: SKNode, caughter: SKNode) {
        let ballName = ball.name
        var textToShow = ""
        if ballName == objectiveBall {
            objectiveCount += 1
            textToShow = "+1"
        } else {
            lifes -= 1
            if objectiveCount > 0 {
                objectiveCount -= 1
                textToShow = "-1"
            }
        }
        let objectiveTextVar = SKLabelNode(text: textToShow)
        objectiveTextVar.position = CGPoint(x: ball.position.x, y: ball.position.y - 50)
        objectiveTextVar.fontSize = 24
        objectiveTextVar.fontName = "Lemonada-Bold"
        addChild(objectiveTextVar)
        
        let actionMoveUp = SKAction.moveTo(y: ball.position.y + 100, duration: 0.7)
        let actionFadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequince = SKAction.sequence([actionMoveUp, actionFadeOut])
        objectiveTextVar.run(sequince)
        
        ball.removeFromParent()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locaation = touch.location(in: self)
            caughterNode.position.x = locaation.x
        }
    }
    
    @objc private func createBall() {
        let xPos = Int.random(in: 300..<500)
        let ballVariant = balls.randomElement() ?? "blue_ball"
        let ballNode = SKSpriteNode(imageNamed: ballVariant)
        ballNode.position = CGPoint(x: Double(xPos), y: size.height)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: ballNode.size.width / 2)
        ballNode.physicsBody?.isDynamic = true
        ballNode.physicsBody?.affectedByGravity = true
        ballNode.physicsBody?.categoryBitMask = Game3Names.ball
        ballNode.physicsBody?.contactTestBitMask = Game3Names.caughterInt | Game3Names.boundsInt
        ballNode.physicsBody?.collisionBitMask = Game3Names.caughterInt | Game3Names.boundsInt
        ballNode.name = ballVariant
        addChild(ballNode)
    }
    
    private func createCaughter() {
        caughterNode = SKSpriteNode(imageNamed: "caughter")
        caughterNode.position = CGPoint(x: size.width / 2, y: 200)
        caughterNode.physicsBody = SKPhysicsBody(rectangleOf: caughterNode.size)
        caughterNode.physicsBody?.affectedByGravity = false
        caughterNode.physicsBody?.isDynamic = false
        caughterNode.physicsBody?.categoryBitMask = Game3Names.caughterInt
        caughterNode.physicsBody?.contactTestBitMask = Game3Names.ball
        caughterNode.physicsBody?.collisionBitMask = Game3Names.ball
        caughterNode.name = Game3Names.caughter
        addChild(caughterNode)
    }
    
    private func drawBackground() {
        let background = SKSpriteNode(imageNamed: "game_3_back")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
    }
    
    private func drawBoard() {
        let width = size.width
        let height = CGFloat(640)
        let numRows = 7 // Number of rows
        
        let pexSize = pegDimension * 3
        let centerPoint = width / 2 + pexSize / 2
        
        pegs = []
        for row in 1..<(numRows + 2) {
            let pegsCount = row
            if pegsCount > 1 {
                let totalWidth = CGFloat(pegsCount) * pexSize
                let startPointX = centerPoint - totalWidth / 2 - 10
                let startPointY = ((pexSize) * CGFloat(row - 2) - 30) - height * 1.4
                
                for peg in 0..<pegsCount + 1 {
                    let x = startPointX + CGFloat(peg) * pexSize
                    let y = startPointY
                    pegs.append((x, -y))
                    
                    let pegNode = SKSpriteNode(imageNamed: "pegImage")
                    pegNode.position = CGPoint(x: x, y: -y)
                    pegNode.size = CGSize(width: 22, height: 22)
                    pegNode.name = Game3Names.peg
                    pegNode.physicsBody = SKPhysicsBody(circleOfRadius: pegNode.size.width / 2)
                    pegNode.physicsBody?.isDynamic = false
                    addChild(pegNode)
                }
            }
        }
    }
    
    struct Game3Names {
        static let peg = "peg"
        static let caughter = "caughter"
        static let bounds = "bounds"
        
        static let ball: UInt32 = 0x1
        static let caughterInt: UInt32 = 0x101
        static let boundsInt: UInt32 = 0x1001
    }
    
}
