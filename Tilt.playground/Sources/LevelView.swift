import SpriteKit
import UIKit
import PlaygroundSupport

/// The mode of the game
/// Either playing when the game is running
/// or resetting when the player is out of lives
/// or hit the finish
enum Mode {
    case playing, resetting
}

/// The view coordinating the game
public class LevelView: UIView, OverviewDelegate, Grid {
    
    /// The level scene
    public var levelScene: LevelScene!
    /// The minimap
    public var overviewScene: OverviewScene!
    // Sceneviews the above scenes go in
    public let sceneView: SKView
    public let overviewSceneView: SKView
    /// Label to keep track of lives
    public var livesLabel: UILabel
    /// Tiles in the grid
    public var tiles: [Tile]
    /// Size of the grid
    public var gridSize: GridSize
    
    /// Current mode of the game
    private var mode: Mode = .playing {
        didSet {
            switch mode {
            case .playing:
                self.lives = 5
                self.regenButton.setTitle(.regenButtonTitle, for: .init())
            case .resetting:
                self.regenButton.setTitle(.playAgainTitle, for: .init())
            }
            self.regenButton.sizeToFit()
        }
    }
    
    /// Current lives
    public var lives: Int {
        didSet {
            self.livesLabel.text = .livesLabelText(lives)
            self.livesLabel.sizeToFit()
        }
    }
    
    /// Create a new LevelView with the specified GridSize
    public init(_ gridSize: GridSize) {
        // Initialize all properties
        // and call super.init(frame:)
        self.levelScene = LevelScene(fileNamed: .levelScene)!
        self.overviewScene = OverviewScene(fileNamed: .levelScene)!
        self.sceneView = SKView()
        self.overviewSceneView = SKView()
        self.livesLabel = UILabel()
        self.lives = 5
        self.tiles = .empty
        self.gridSize = gridSize
        super.init(frame: .init(x: 0, y: 0, width: 20, height: 800))
        
        // Add all subviews
        self.addSubview(sceneView)
        self.addSubview(overviewSceneView)
        self.addSubview(livesLabel)
        self.addSubview(backButton)
        self.addSubview(regenButton)
        self.addSubview(titleLabel)
        
        // Initial setup of the levelScene
        self.levelScene.overviewDelegate = self
        self.levelScene.colisionDelegate = self
        self.levelScene.scaleMode = .aspectFill
        
        // Initial setup of the minimap
        self.overviewScene.size = .init(width: gridSize.width * 800, height: gridSize.height * 800)
        self.overviewScene.scaleMode = .aspectFit
        self.overviewSceneView.layer.borderColor = UIColor.white.cgColor
        self.overviewSceneView.layer.borderWidth = 0.4
        
        // Set the lives label
        self.livesLabel.text = .livesLabelText(lives)
        self.livesLabel.textColor = .white
        
        // Setup the grid
        self.setupGrid()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Overview delegate method
    /// This moves the ball to the same point in the
    /// minimap
    public func ballMovedTo(_ point: CGPoint) {
        self.overviewScene.setBallTo(point)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Disable autoresizingMasks and setup constraints
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.overviewSceneView.translatesAutoresizingMaskIntoConstraints = false
        self.livesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.regenButton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.sceneView.topAnchor.constraint(equalTo: self.topAnchor),
            self.sceneView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.overviewSceneView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.overviewSceneView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.overviewSceneView.heightAnchor.constraint(equalToConstant: 100),
            self.overviewSceneView.widthAnchor.constraint(equalToConstant: 100),
            self.livesLabel.bottomAnchor.constraint(equalTo: self.regenButton.topAnchor, constant: -4),
            self.backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            self.livesLabel.leadingAnchor.constraint(equalTo: self.overviewSceneView.trailingAnchor, constant: 16.0),
            self.backButton.leadingAnchor.constraint(equalTo: self.overviewSceneView.trailingAnchor, constant: 16.0),
            self.regenButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.overviewSceneView.trailingAnchor, constant: 16.0),
            self.regenButton.bottomAnchor.constraint(equalTo: self.backButton.topAnchor, constant: -8)
        ])
    }
    
    // MARK: Views
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .init())
        label.font = .righteous(withFontSize: 60)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .righteous(withFontSize: 16)
        button.setTitle(.backHomeTitle, for: .init())
        button.setTitleColor(.white, for: .init())
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    lazy var regenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .righteous(withFontSize: 16)
        button.setTitle(.regenButtonTitle, for: .init())
        button.setTitleColor(.white, for: .init())
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(resetGrid), for: .touchUpInside)
        return button
    }()
    
    // MARK: Functions
    
    /// Go back to the main screen
    @objc func back() {
        self.levelScene = nil
        self.overviewScene = nil

        Tilt.showMain()
    }
    
    /// Reset the grid after game over
    /// or game completion
    @objc func resetGrid() {
        self.titleLabel.text = nil
        self.levelScene = nil
        self.overviewScene = nil

        self.levelScene = LevelScene(fileNamed: .levelScene)!
        self.overviewScene = OverviewScene(fileNamed: .levelScene)!
        
        self.levelScene.overviewDelegate = self
        self.levelScene.colisionDelegate = self
        self.levelScene.scaleMode = .aspectFill
        
        self.overviewScene.size = .init(width: gridSize.width * 800, height: gridSize.height * 800)
        self.overviewScene.scaleMode = .aspectFit
        
        if mode == .playing {
            self.setupGrid()
        } else {
            self.mode = .playing
            self.addTilesToGrid()
        }
    }
    
    /// Add the current calculated tilse
    /// to the scenes
    func addTilesToGrid() {
        self.tiles.forEach { (tile) in
            tile.generateNode(in: self.overviewScene)
            tile.generateNode(in: self.levelScene)
        }
        
        self.overviewSceneView.presentScene(overviewScene)
        self.sceneView.presentScene(levelScene)
    }
    
    /// Generate a grid for the game
    public func setupGrid() {
        guard self.gridSize.width >= 3 && self.gridSize.height >= 3 else { fatalError("This should not happen") }
        self.tiles = .empty
        let start = StartTile(Coordinate(x: 0, y: 0))
        self.tiles.append(start)
        start.addAdjecentTiles(to: &self.tiles, gridSize: gridSize, fromDirection: .down)
        
        addTilesToGrid()
    }
}

extension LevelView: ColisionDelegate {
    /// Stops the game and show the `You won` label
    public func ballHitFinish() {
        self.mode = .resetting
        self.titleLabel.text = .youWonTitle
        self.levelScene.pause()
    }
    
    /// Reduces the current lives by 1
    public func ballHitWall() {
        if self.lives > 1 {
            self.lives -= 1
            return
        }
        if self.lives == 1 {
            self.lives -= 1
            gameOver()
            return
        }
    }
    
    /// Stops the game and shows the `You lost` label
    func gameOver() {
        self.mode = .resetting
        self.titleLabel.text = .youLostTitle
        self.levelScene.pause()
    }
}
