import UIKit

class ManagedUserTableViewCell: UITableViewCell {
    static let identifier = "ManagedUserTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    
    var onActionsTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
        selectionStyle = .none
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(completionLabel)
        contentView.addSubview(actionsButton)
        
        // Create gear icon
        let gearIcon = createGearIcon()
        actionsButton.setImage(gearIcon, for: .normal)
        actionsButton.addTarget(self, action: #selector(actionsButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Name label - 40% width
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            
            // Completion label - 20% width
            completionLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            completionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            // Actions button - remaining space
            actionsButton.leadingAnchor.constraint(equalTo: completionLabel.trailingAnchor, constant: 8),
            actionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionsButton.widthAnchor.constraint(equalToConstant: 30),
            actionsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func createGearIcon() -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Set color to white
            UIColor.white.setFill()
            UIColor.white.setStroke()
            
            // Scale to fit in 30x30
            let scale: CGFloat = 0.3
            ctx.translateBy(x: size.width / 2, y: size.height / 2)
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: -50, y: -50)
            
            // Main gear body
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 50, y: 50), radius: 30, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            circlePath.fill()
            
            // Six teeth
            let toothWidth: CGFloat = 10
            let toothHeight: CGFloat = 12
            let toothRadius: CGFloat = 2
            
            for i in 0..<6 {
                let angle = CGFloat(i) * 60 * .pi / 180
                ctx.saveGState()
                ctx.translateBy(x: 50, y: 50)
                ctx.rotate(by: angle)
                ctx.translateBy(x: -50, y: -50)
                
                let toothRect = CGRect(x: 45, y: 8, width: toothWidth, height: toothHeight)
                let toothPath = UIBezierPath(roundedRect: toothRect, cornerRadius: toothRadius)
                toothPath.fill()
                
                ctx.restoreGState()
            }
            
            // Inner ring
            let innerRingPath = UIBezierPath(arcCenter: CGPoint(x: 50, y: 50), radius: 14, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            innerRingPath.lineWidth = 6
            innerRingPath.stroke()
        }
        
        return image
    }
    
    @objc private func actionsButtonTapped() {
        onActionsTapped?()
    }
    
    func configure(with user: ManagedUser) {
        nameLabel.text = user.displayName
        
        // Configure completion indicator
        if let percentComplete = user.fmPercentComplete {
            if percentComplete >= 100 {
                completionLabel.text = "✓"
                completionLabel.textColor = .green
            } else {
                completionLabel.text = "✗"
                completionLabel.textColor = .red
            }
        } else {
            completionLabel.text = "✗"
            completionLabel.textColor = .red
        }
    }
}
