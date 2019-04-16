import SpriteKit

/// Overview delegate used to keep
/// track of the position of the ball
public protocol OverviewDelegate: class {
    func ballMovedTo(_ point: CGPoint)
}

/// Overview Scene, aka the mini map
public class OverviewScene: SKScene {
    /// The ball / player
    private var ball: SKShapeNode!
    
    /// Initial point of the ball
    private let point: CGPoint = .init(x: 400.0, y: 65.0)
    
    public override func didMove(to view: SKView) {
        // Add the ball and set it's position
        ball = SKShapeNode(circleOfRadius: 30.0)
        ball.fillColor = .red
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        ball.physicsBody?.affectedByGravity = false
        ball.name = .ballIdentifier
        addChild(ball)
        
        self.ball.position = self.point
    }
    
    /// Moves the ball to the specified point
    public func setBallTo(_ point: CGPoint) {
        self.ball.position = point
    }
}
