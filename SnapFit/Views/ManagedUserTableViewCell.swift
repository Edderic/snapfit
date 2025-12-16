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
    
    private let demogLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let facialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let masksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
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
        contentView.addSubview(demogLabel)
        contentView.addSubview(facialLabel)
        contentView.addSubview(masksLabel)
        contentView.addSubview(actionsButton)
        
        // Create gear icon
        let gearIcon = createGearIcon()
        actionsButton.setImage(gearIcon, for: .normal)
        actionsButton.addTarget(self, action: #selector(actionsButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Name label - 25% width
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            
            // Demog label - 15% width
            demogLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            demogLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            demogLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            
            // Facial label - 15% width
            facialLabel.leadingAnchor.constraint(equalTo: demogLabel.trailingAnchor, constant: 8),
            facialLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            facialLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            
            // Masks label - 15% width
            masksLabel.leadingAnchor.constraint(equalTo: facialLabel.trailingAnchor, constant: 8),
            masksLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            masksLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            
            // Actions button - remaining space
            actionsButton.leadingAnchor.constraint(equalTo: masksLabel.trailingAnchor, constant: 8),
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
        
        // Configure demographics percentage
        if let demogPercent = user.demogPercentComplete {
            demogLabel.text = String(format: "%.0f%%", demogPercent)
        } else {
            demogLabel.text = "0%"
        }
        
        // Configure facial measurements completion indicator
        if let fmPercent = user.fmPercentComplete {
            if fmPercent >= 100 {
                facialLabel.text = "✓"
                facialLabel.textColor = .green
            } else {
                facialLabel.text = "✗"
                facialLabel.textColor = .red
            }
        } else {
            facialLabel.text = "✗"
            facialLabel.textColor = .red
        }
        
        // Configure masks tested count
        if let maskCount = user.numUniqueMasksTested {
            masksLabel.text = "\(maskCount)"
        } else {
            masksLabel.text = "0"
        }
    }
}
