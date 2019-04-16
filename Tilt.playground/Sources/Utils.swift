import UIKit

/// This adds all string constants I use througout my project as a static property
/// This prevents typos and allows for me to use Auto Complete
/// This also allows you to edit all strings througout your app in one convenient place
extension String {
    public static let ballIdentifier = "_Ball"
    public static let wallIdentifier = "_Wall"
    public static let startIdentifier = "_Start"
    public static let finishIdentifier = "_Finish"
    
    public static let introScene = "IntroScene"
    public static let levelScene = "LevelScene"
    
    static let righteousFontName = "Righteous-Regular"
    
    static let regenButtonTitle = "regenerate grid"
    static let playAgainTitle = "play again"
    static let backHomeTitle = "back home"
    
    static let youWonTitle = "You won! 🎉"
    static let youLostTitle = "You lost! 😦"
    
    static func livesLabelText(_ lives: Int) -> String { return "Lives: \(lives)" }
    
    static let welcomeTitle = "Welcome to Tilt"
    static let descriptionText = "To play, choose a grid size below and the game will generate a random playing field.\nThe objective of the game is to reach the end of the track and touch the green wall by tilting your iPad in the direction you want to move in. All of this without touching the walls more than 5 times. Good luck!"
    
    static let threeXThree = "3x3 Grid"
    static let fiveXFive = "5x5 Grid"
    static let tenXTen = "10x10 Grid"
    
    static let startPiece = "_StartPiece"
    static let finishPiece = "_FinishPiece"
    static let cornerPiece = "_CornerPiece"
    static let straightPiece = "_StraightPiece"
}

// Small extension to array adding `Array.empty`
// purely for it reading more smoothly in my opinion
extension Array {
    /// Creates an empty array
    public static var empty: Array<Element> {
        return []
    }
}

// Convienience function on set to turn it into an
// array, used while calculating the next tile in the grid
extension Set {
    /// Turns this set into an array
    public func toArray() -> Array<Element> {
        return self.reduce(into: Array<Element>()) { $0.append($1) }
    }
}

// Convienience function to get my custom font with the specified
// font size.
extension UIFont {
    /// Get the righteuos font with the specified size
    public static func righteous(withFontSize size: CGFloat) -> UIFont {
        return UIFont(name: .righteousFontName, size: size)!
    }
}
