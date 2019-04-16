import SpriteKit

/// Coordinate of a tile
public struct Coordinate: Equatable, CustomStringConvertible {
    public var x: Int
    public var y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public static func == (_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public var description: String {
        return "(\(x), \(y))"
    }
}

/// Directions a tile can be open (or closed) in
public enum OpeningDirection {
    case up, down, left, right
    
    /// Oposite of the direction
    public var opposite: OpeningDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

/// A tile is a buildstone in a grid building up the track
public protocol Tile: class, CustomStringConvertible {
    /// Coordinate of the tile
    var coordinate: Coordinate { get }
    
    /// Indicates if this tile has an opening to the top
    static var isOpenTop: Bool { get }
    /// Indicates if this tile has an opening to the right
    static var isOpenRight: Bool { get }
    /// Indicates if this tile has an opening to the bottom
    static var isOpenBottom: Bool { get }
    /// Indicates if this tile has an opening to the left
    static var isOpenLeft: Bool { get }
    
    /// Identifier of the tile. For debugging purposes
    static var identifier: String { get }
    
    /// Name of the node in the scene that should be copied
    static var nodeName: String { get }
    /// Required rotation of the node in degrees
    static var requiredRotation: Int { get }
    
    /// Create a new tile with a coordinate
    init(_ coordinate: Coordinate)
    
    /// A function to add the next tile to the grid
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection)
    
    /// Generates and adds an SKNode to the given SKScene
    func generateNode(in scene: SKScene)
}

extension Tile {
    /// See `CustomStringConvertible`
    public var description: String {
        return "\(Self.self)"
    }
    
    /// Generates and adds an SKNode to the given SKScene
    public func generateNode(in scene: SKScene) {
        let stat = type(of: self)
        guard let n = scene.childNode(withName: stat.nodeName), let node = n.copy() as? SKNode else { fatalError("This should not happen") }
        node.name = "\(self.coordinate)\(stat.identifier)"
        node.position = .init(x: (coordinate.x * 800) + 400, y: (coordinate.y * 800) + 400)
        node.zRotation = CGFloat(Double(stat.requiredRotation) * .pi / 180)
        
        scene.addChild(node)
    }
}

/// A utilitarian subscript to [Tile] using Coordinates
extension Array where Element == Tile {
    public subscript (_ coords: Coordinate) -> Tile? {
        return first { $0.coordinate == coords }
    }
}

// MARK: - Tiles

/*
Below are all the tiles the game can render.
 
 They're all inheriting from `Tile` and specify the required values
 for the default implementation of functions to generate the next tiles
 in the grid.
 */

public class StartTile: Tile {
    public var coordinate: Coordinate
    
    required public init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    public static var isOpenTop: Bool = true
    public static var isOpenRight: Bool = false
    public static var isOpenBottom: Bool = false
    public static var isOpenLeft: Bool = false
    public static var identifier: String = .startIdentifier
    
    public static var nodeName: String = .startPiece
    public static var requiredRotation: Int = 0
    
    public func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = [.left]
        if coordinate.y == gridSize.height - 1 { closings.insert(.up) }
        let coord = Coordinate(x: self.coordinate.x, y: self.coordinate.y + 1)
        guard let tile = StartTile.randomTile(withOpenings: [.down], andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: .down))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: .down)
    }
}

class FinishTile: Tile {
    var coordinate: Coordinate
    var incommingDir: OpeningDirection

    required init(_ coordinate: Coordinate) {
        self.incommingDir = .right
        self.coordinate = coordinate
    }
    
    init(_ coordinate: Coordinate, incomming dir: OpeningDirection) {
        self.incommingDir = dir
        self.coordinate = coordinate
    }
    
    static var isOpenTop: Bool = false
    static var isOpenRight: Bool = true
    static var isOpenBottom: Bool = false
    static var isOpenLeft: Bool = false
    static var identifier: String = .finishIdentifier
    
    static var nodeName: String = .finishPiece
    static var requiredRotation: Int = 0

    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) { }
    
    func generateNode(in scene: SKScene) {
        let stat = type(of: self)
        guard let n = scene.childNode(withName: stat.nodeName), let node = n.copy() as? SKNode else { fatalError("This should not happen") }
        node.name = "\(self.coordinate)\(stat.identifier)"
        switch self.incommingDir {
        case .up: node.zRotation = CGFloat(90 * Double.pi / 180)
        case .down: node.zRotation = CGFloat(270 * Double.pi / 180)
        case .left: node.zRotation = CGFloat(180 * Double.pi / 180)
        case .right: node.zRotation = 0
        }
        node.position = .init(x: (coordinate.x * 800) + 400, y: (coordinate.y * 800) + 400)
        
        scene.addChild(node)
    }
}

class BottomRightTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    static var isOpenTop: Bool = false
    static var isOpenRight: Bool = true
    static var isOpenBottom: Bool = true
    static var isOpenLeft: Bool = false
    static var identifier: String = "_BR"
    
    static var nodeName: String = .cornerPiece
    static var requiredRotation: Int = 270
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir == .down ? .left : .up]
        switch dir {
        case .down:
            if coordinate.y == gridSize.height - 1 { closings.insert(.up) }
            if coordinate.x == gridSize.width - 2 { closings.insert(.right) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .right)
        case .right:
            if coordinate.y == 1 { closings.insert(.down) }
            if coordinate.x == 0 { closings.insert(.left) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .down)
        default:
            break
        }
        
        let coord = dir == .down ? Coordinate(x: coordinate.x + 1, y: coordinate.y) : Coordinate(x: coordinate.x, y: coordinate.y - 1)
        guard let tile = BottomRightTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir == .down ? .left : .up))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir == .down ? .left : .up)
    }
}

class BottomLeftTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }

    static var isOpenTop: Bool = false
    static var isOpenRight: Bool = false
    static var isOpenBottom: Bool = true
    static var isOpenLeft: Bool = true
    static var identifier: String = "_BL"
    
    static var nodeName: String = .cornerPiece
    static var requiredRotation: Int = 180
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir == .down ? .right : .up]
        switch dir {
        case .down:
            if coordinate.y == gridSize.height - 1 { closings.insert(.up) }
            if coordinate.x == 1 { closings.insert(.left) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .left)
        case .left:
            if coordinate.y == 1 { closings.insert(.down) }
            if coordinate.x == gridSize.width - 1 { closings.insert(.right) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .down)
        default:
            break
        }
        
        let coord = dir == .down ? Coordinate(x: coordinate.x - 1, y: coordinate.y) : Coordinate(x: coordinate.x, y: coordinate.y - 1)
        guard let tile = BottomLeftTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir == .down ? .right : .up))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir == .down ? .right : .up)
    }
}

class TopRightTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    weak var grid: Grid?
    
    static var isOpenTop: Bool = true
    static var isOpenRight: Bool = true
    static var isOpenBottom: Bool = false
    static var isOpenLeft: Bool = false
    static var identifier: String = "_TR"
 
    static var nodeName: String = .cornerPiece
    static var requiredRotation: Int = 0
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir == .up ? .left : .down]
        switch dir {
        case .up:
            if coordinate.y == 0 { closings.insert(.down) }
            if coordinate.x == gridSize.width - 2 { closings.insert(.right) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .right)
        case .right:
            if coordinate.y == gridSize.height - 2 { closings.insert(.up) }
            if coordinate.x == 0 { closings.insert(.left) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .up)
        default: break
        }
        
        let coord = dir == .up ? Coordinate(x: coordinate.x + 1, y: coordinate.y) : Coordinate(x: coordinate.x, y: coordinate.y + 1)
        guard let tile = TopRightTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir == .up ? .left : .down))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir == .up ? .left : .down)
    }
}

class TopLeftTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }

    static var isOpenTop: Bool = true
    static var isOpenRight: Bool = false
    static var isOpenBottom: Bool = false
    static var isOpenLeft: Bool = true
    static var identifier: String = "_TL"
    
    static var nodeName: String = .cornerPiece
    static var requiredRotation: Int = 90
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir == .up ? .right : .down]
        switch dir {
        case .up:
            if coordinate.x == 1 { closings.insert(.left) }
            if coordinate.y == 0 { closings.insert(.down) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .left)
        case .left:
            if coordinate.y == gridSize.height - 2 { closings.insert(.up) }
            if coordinate.x == gridSize.width - 1 { closings.insert(.right) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .up)
        default: break
        }
        
        let coord = dir == .up ? Coordinate(x: coordinate.x - 1, y: coordinate.y) : Coordinate(x: coordinate.x, y: coordinate.y + 1)
        guard let tile = TopLeftTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir == .up ? .right : .down))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir == .up ? .right : .down)
    }
}

class TopBottomTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    static var isOpenTop: Bool = true
    static var isOpenRight: Bool = false
    static var isOpenBottom: Bool = true
    static var isOpenLeft: Bool = false
    static var identifier: String = "_TB"
    
    static var nodeName: String = .straightPiece
    static var requiredRotation: Int = 0
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir]
        if coordinate.x == 0 { closings.insert(.left) }
        if coordinate.x == gridSize.width - 1 { closings.insert(.right) }
        switch dir {
        case .up:
            if coordinate.y == 1 { closings.insert(.down) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .down)
        case .down:
            if coordinate.y == gridSize.height - 2 { closings.insert(.up) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .up)
        default: break
        }
        
        let coord = Coordinate(x: coordinate.x, y: coordinate.y + (dir == .up ? -1 : 1))
        guard let tile = TopBottomTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir)
    }
}

class LeftRightTile: Tile {
    var coordinate: Coordinate
    
    required init(_ coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    static var isOpenTop: Bool = false
    static var isOpenRight: Bool = true
    static var isOpenBottom: Bool = false
    static var isOpenLeft: Bool = true
    static var identifier: String = "_LR"
    
    static var nodeName: String = .straightPiece
    static var requiredRotation: Int = 90
    
    func addAdjecentTiles(to field: inout [Tile], gridSize: GridSize, fromDirection dir: OpeningDirection) {
        var closings: Set<OpeningDirection> = []
        var openings: Set<OpeningDirection> = [dir]
        if coordinate.y == 0 { closings.insert(.down) }
        if coordinate.y == gridSize.width - 1 { closings.insert(.up) }
        switch dir {
        case .right:
            if coordinate.x == 1 { closings.insert(.left) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .left)
        case .left:
            if coordinate.x == gridSize.height - 2 { closings.insert(.right) }
            self.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .right)
        default: break
        }

        let coord = Coordinate(x: coordinate.x + (dir == .right ? -1 : 1), y: coordinate.y)
        guard let tile = LeftRightTile.randomTile(withOpenings: openings, andNoOpeningsIn: closings)?.init(coord) else {
            field.append(FinishTile(coord, incomming: dir))
            return
        }
        field.append(tile)
        tile.addAdjecentTiles(to: &field, gridSize: gridSize, fromDirection: dir)
    }
}

