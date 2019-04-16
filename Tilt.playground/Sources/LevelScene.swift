import SpriteKit
import CoreMotion

/// Delegate to indicate colisions between our ball and
/// other objects in the scene.
public protocol ColisionDelegate: class {
    /// Tell the delegate the ball hit a wall
    func ballHitWall()
    /// Tell the delegate the ball hit the finish
    func ballHitFinish()
}

/// The LevelScene is the scene that does all physics calculations
/// and colision checking
public class LevelScene: SKScene, SKPhysicsContactDelegate {
    
    /// Our ball (aka the player)
    private var ball: SKShapeNode!
    
    /// The motion manager
    private var manager = CMMotionManager()
    
    /// The initial point to set our ball to
    private let point: CGPoint = .init(x: 400.0, y: 65.0)
    
    /// The overview delegate used for our minimap
    public weak var overviewDelegate: OverviewDelegate?
    
    /// The colision delegate used for scoring
    public weak var colisionDelegate: ColisionDelegate?
    
    public override func didMove(to view: SKView) {
        // set ourself as physics delegate
        self.physicsWorld.contactDelegate = self
        
        // Create and add our ball
        ball = SKShapeNode(circleOfRadius: 30.0)
        ball.fillColor = .red
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.name = .ballIdentifier
        addChild(ball)
        
        // Get a hold of and insert our camera
        // so that we can move it later down the line
        let camera = SKCameraNode()
        self.camera = camera
        self.addChild(camera)
        
        // Set the ball position
        self.ball.position = self.point
        
        // Start accelerometer updates
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdates(to: .main) { (data, err) in
                guard let data = data, err == nil else { return }
                self.physicsWorld.gravity = CGVector(dx: data.acceleration.y * -10, dy: data.acceleration.x * 10)
            }
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        // Get a hold of the names of the two bodies
        guard   let nameA = contact.bodyA.node?.name,
                let nameB = contact.bodyB.node?.name else { return }
        // Check if we had a colision between ball and wall or between ball and finish
        // and tell the delegate
        switch (nameA, nameB) {
        case (.ballIdentifier, .finishIdentifier), (.finishIdentifier, .ballIdentifier):
            self.colisionDelegate?.ballHitFinish()
        case (.ballIdentifier, .wallIdentifier), (.wallIdentifier, .ballIdentifier):
            self.colisionDelegate?.ballHitWall()
        default:
            break
        }
    }
    
    /// Pauses the scene, imobalizing the ball and
    /// turnining off the accelerometer
    public func pause() {
        guard let ball = ball else { return }
        let pos = ball.position
        ball.physicsBody?.isDynamic = false
        self.physicsWorld.gravity = CGVector()
        self.manager.stopAccelerometerUpdates()
        ball.position = pos
    }
    
    @objc public static override var supportsSecureCoding: Bool {
        return true
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Update the camera so the ball is always the center of our screen
        // Also lets the overviewDelegate know the position of the ball
        // Used to update the position in the minimap
        guard let ball = ball, let cam = camera else { return }
        cam.position = ball.position
        self.overviewDelegate?.ballMovedTo(ball.position)
    }
}

