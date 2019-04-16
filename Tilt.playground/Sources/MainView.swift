import UIKit
import PlaygroundSupport

/// The main view of the game
/// Holding some explanation
/// and the grid chooser
public class MainView: UIView {
    
    /// Button lock to prevent button taps from going through more than once
    var buttonLock: Bool = false
    
    /// Create a new MainView
    public init() {
        super.init(frame: .init(x: 0, y: 0, width: 12, height: 12))
        // Setup view and add subviews
        self.backgroundColor = .white
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        self.addSubview(threeXThreeButton)
        self.addSubview(fiveXFiveButton)
        self.addSubview(tenXTenButton)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        /// Disable autoresizingMasks and setup constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        threeXThreeButton.translatesAutoresizingMaskIntoConstraints = false
        fiveXFiveButton.translatesAutoresizingMaskIntoConstraints = false
        tenXTenButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            threeXThreeButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24),
            threeXThreeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            threeXThreeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            fiveXFiveButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            fiveXFiveButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            tenXTenButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tenXTenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
            ])
    }
    
    // Mark: Views
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .init())
        label.text = .welcomeTitle
        label.font = .righteous(withFontSize: 50)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel(frame: .init())
        label.text = .descriptionText
        label.numberOfLines = 0
        label.font = .righteous(withFontSize: 30)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    lazy var threeXThreeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .righteous(withFontSize: 16)
        button.setTitle(.threeXThree, for: .init())
        button.setTitleColor(.white, for: .init())
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(startGame(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var fiveXFiveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .righteous(withFontSize: 16)
        button.setTitle(.fiveXFive, for: .init())
        button.setTitleColor(.white, for: .init())
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(startGame(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var tenXTenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .righteous(withFontSize: 16)
        button.setTitle(.tenXTen, for: .init())
        button.setTitleColor(.white, for: .init())
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(startGame(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Functions
    
    /// Starts the game with specified size
    @objc func startGame(_ sender: UIButton) {
        if buttonLock { return }
        buttonLock = true
        switch sender {
        case tenXTenButton:
            Tilt.showLevel(.init(width: 10, height: 10))
        case fiveXFiveButton:
            Tilt.showLevel(.init(width: 5, height: 5))
        case threeXThreeButton:
            Tilt.showLevel(.init(width: 3, height: 3))
        default: break
        }
        self.buttonLock = false
    }
}
