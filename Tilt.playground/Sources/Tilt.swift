import PlaygroundSupport
import UIKit

/// Utility view that pins all edges for AutoLayout
class PinnedView: UIView {
    override func layoutSubviews() {
        self.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.topAnchor),
                $0.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
        }
        
    }
}

/// The game class
///
/// Tilt works by calling static functions that update the current shown view.
public class Tilt {
    /// The PinnedView we add our subviews to
    static var view: PinnedView = PinnedView(frame: .init(x: 0, y: 0, width: 200, height: 200))
    
    /// Runs the game & all required setup
    public static func runGame() {
        // Add a custom font
        // Downloaded from https://fonts.google.com/specimen/Righteous?selection.family=Righteous
        let fontUrl = Bundle.main.url(forResource: .righteousFontName, withExtension: "ttf")!
        CTFontManagerRegisterFontsForURL(fontUrl as CFURL, .process, nil)
        
        // Set needsIndefiniteExecution and show the main page
        PlaygroundPage.current.needsIndefiniteExecution = true
        showMain()
        PlaygroundPage.current.liveView = view
    }
    
    /// Shows the main page
    static func showMain() {
        // This function updates subviews instead of the actual liveView
        // because updating the liveView loads of times caused random crashes
        view.subviews.forEach { $0.removeFromSuperview() }
        let v = MainView()
        view.addSubview(v)
    }
    
    /// Shows the level view with the specified grid size
    static func showLevel(_ size: GridSize) {
        // This function updates subviews instead of the actual liveView
        // because updating the liveView loads of times caused random crashes
        view.subviews.forEach { $0.removeFromSuperview() }
        let v = LevelView(size)
        view.addSubview(v)
    }
}
