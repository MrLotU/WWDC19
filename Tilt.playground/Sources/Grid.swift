/// Holds the width and height of a grid
public struct GridSize {
    public var width: Int
    public var height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

/// A grid the game can be played in
public protocol Grid: class {
    /// The individual tiles in the grid
    var tiles: [Tile] { get set }
    /// THe size of the grid
    var gridSize: GridSize { get }
    
    /// Called to setup the grid
    func setupGrid()
}

// Mark: Tile extensions

extension Tile {
    /// Array of tile types we can plug into our grid
    public static var selectableTiles: [Tile.Type]{
        return [
            BottomLeftTile.self,
            BottomRightTile.self,
            TopLeftTile.self,
            TopRightTile.self,
            TopBottomTile.self,
            LeftRightTile.self
        ]
    }
    
    /// Selects a random tile with openings and closings in the specified directions
    ///
    ///     let tyleType = Tile.randomTile(withOpenings: [.down], andNoOpeningsIn: [.top, .left]
    ///
    /// The example above would return BottomRightTile indicating an opening in the bottom and right side of the tile.
    ///
    /// - Parameters:
    ///     - directions: Directions the tile should be open in
    ///     - blocks: Directions the tile should be closed in
    ///
    /// - Returns: A tile type that can be initialized to create a new tile
    public static func randomTile(withOpenings directions: Set<OpeningDirection>, andNoOpeningsIn blocks: Set<OpeningDirection>) -> Tile.Type? {
        return Self.randomTile(withOpenings: directions.toArray(), andNoOpeningsIn: blocks.toArray())
    }
    
    /// Selects a random tile with openings and closings in the specified directions
    ///
    ///     let tyleType = Tile.randomTile(withOpenings: [.down], andNoOpeningsIn: [.top, .left]
    ///
    /// The example above would return BottomRightTile indicating an opening in the bottom and right side of the tile.
    ///
    /// - Parameters:
    ///     - directions: Directions the tile should be open in
    ///     - blocks: Directions the tile should be closed in
    ///
    /// - Returns: A tile type that can be initialized to create a new tile
    public static func randomTile(withOpenings directions: [OpeningDirection], andNoOpeningsIn blocks: Set<OpeningDirection>) -> Tile.Type? {
        return Self.randomTile(withOpenings: directions, andNoOpeningsIn: blocks.toArray())
    }
    
    /// Selects a random tile with openings and closings in the specified directions
    ///
    ///     let tyleType = Tile.randomTile(withOpenings: [.down], andNoOpeningsIn: [.top, .left]
    ///
    /// The example above would return BottomRightTile indicating an opening in the bottom and right side of the tile.
    ///
    /// - Parameters:
    ///     - directions: Directions the tile should be open in
    ///     - blocks: Directions the tile should be closed in
    ///
    /// - Returns: A tile type that can be initialized to create a new tile
    public static func randomTile(withOpenings directions: [OpeningDirection], andNoOpeningsIn blocks: [OpeningDirection]) -> Tile.Type? {
        assert(directions.count >= 1 && blocks.count <= 3, "You can not have a tile with either: No openings or: more than 3 closings.")
        var tiles = Self.selectableTiles
        for direction in directions {
            tiles = tiles.filter { t in
                return t.isOpenIn(direction)
            }
        }
        for block in blocks {
            tiles = tiles.filter { t in
                return !t.isOpenIn(block)
            }
        }
        return tiles.randomElement()
    }
    
    public static func isOpenIn(_ dir: OpeningDirection) -> Bool {
        switch dir {
        case .up:
            return isOpenTop
        case .down:
            return isOpenBottom
        case .left:
            return isOpenLeft
        case .right:
            return isOpenRight
        }
    }
    
    /// Checks if a tile is open in a specified direction
    public func isOpenIn(_ dir: OpeningDirection) -> Bool {
        return type(of: self).isOpenIn(dir)
    }
    
    /// Gets the coordinates of possible tiles the next calculated tile COULD intersect with
    ///
    ///     let tile = SomeTile(Coordinate(x: 1, y: 1)
    ///     let coordinates = tile.intersectionCoordinates(moving: .up)
    ///     // coordinates = [((2, 2), .left), ((1, 3), .down), (0, 1), .right)]
    ///
    /// - Paramters:
    ///     - dir: Direction to check in
    ///
    /// - Returns: An array of coordinates and the relevant direction to check for said coordinates
    func intersectionCoordinates(moving dir: OpeningDirection) -> [(Coordinate, OpeningDirection)] {
        let x = coordinate.x
        let y = coordinate.y
        switch dir {
        case .up:
            return [(.init(x: x + 1, y: y + 1), .left), (.init(x: x, y: y + 2), .down), (.init(x: x - 1, y: y + 1), .right)]
        case .down:
            return [(.init(x: x - 1, y: y - 1), .right), (.init(x: x, y: y - 2), .up), (.init(x: x + 1, y: y - 1), .left)]
        case .left:
            return [(.init(x: x - 1, y: y + 1), .down), (.init(x: x - 2, y: y), .right), (.init(x: x - 1, y: y - 1), .up)]
        case .right:
            return [(.init(x: x + 1, y: y + 1), .down), (.init(x: x + 2, y: y), .left), (.init(x: x + 1, y: y - 1), .up)]
        }
    }
    
    /// Checks the surrounding tiles to fill the set of openings and closings
    ///
    ///     let tile = SomeTile(Coordinate(x: 1, y: 1)
    ///     let otherTile = SomeTile(Coordinate(x: 2, y: 2)
    ///     let field = [tile, otherTile]
    ///     var openings = Set<OpeningDirection>()
    ///     var closings = Set<OpeningDirection>()
    ///
    ///     tile.checkTile(in: field, openings: &openings, closings: &closings, outgoingDirection: .up)
    ///     // Will add .left to the closings set, since we have a tile at (2, 2) we can not connect with
    ///
    /// - Arguments:
    ///     - field: Field to check tiles from
    ///     - openings: Set of openings to append to
    ///     - closings: Set of closings to append to
    ///     - dir: Direction the next tile will be in, used to check adjacent tiles
    public func checkTile(in field: [Tile], openings: inout Set<OpeningDirection>, closings: inout Set<OpeningDirection>, outgoingDirection dir: OpeningDirection) {
        let coords = intersectionCoordinates(moving: dir)
        coords.forEach { (coord, opening) in
            if let tile = field[coord] {
                if tile.isOpenIn(opening) {
                    openings.insert(opening.opposite)
                } else {
                    closings.insert(opening.opposite)
                }
            }
        }
    }
}

