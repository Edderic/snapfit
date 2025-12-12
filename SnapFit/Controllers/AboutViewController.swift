import UIKit

/// View controller displaying information about SnapFit and mask fitting
class AboutViewController: UIViewController {
    
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var contentTextView: UITextView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "About SnapFit"
        view.backgroundColor = UIColor.systemBackground
        
        // Add back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Create content text view
        contentTextView = UITextView()
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.backgroundColor = .clear
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.delegate = self
        
        // Create attributed string with formatted headlines
        let content = """
Air Is Everywhere — And So Are Tiny Particles

Air isn't just empty space — it's full of tiny particles called aerosols that can stay suspended for minutes to hours. These particles can carry viruses, bacteria, mold, and pollutants like smoke and exhaust fine particulates. Aerosolized pathogens are a major way respiratory diseases spread from person to person through breathing, talking, coughing, and sneezing (https://en.wikipedia.org/wiki/Transmission_of_COVID-19?utm_source=chatgpt.com).

The air you breathe matters more than many people realize:

• People inhale many thousands of liters of air every day, far more than the amount of water we usually drink, making healthy air exposure critical. (https://en.wikipedia.org/wiki/Tidal_volume)

• The lungs have an enormous internal surface area — about 70–100 m² — to transfer oxygen to the blood. This large surface makes them efficient for gas exchange but also vulnerable to airborne contaminants. (https://en.wikipedia.org/wiki/Pulmonary_alveolus)

We take hand-washing and clean water for granted because they reduce infection risk and protect our health. We should give the air we inhale the same respect — especially in crowded or poorly ventilated places where airborne particles accumulate. Masking using a fitted respirator is one of the best ways to protect oneself (and others if you are sick).


Why Fit Matters

High-quality respirators like N95s can filter over 95% of airborne particles—but only if they fit your face well.

Even small gaps between a mask and your face let unfiltered air leak in, dramatically reducing protection. A well-fitted respirator can provide 10–1000× more protection than a poorly fitting one, lowering the dose of airborne pathogens you inhale and reducing the risk of infection.

Fit Is Personal

Mask fit isn't one-size-fits-all. Face shape, size, nose bridge height, and movement all affect how well a mask seals. Studies show that:

• Many people need to try multiple masks to find one that fits
• Fit success varies by facial features, age, sex, and ethnicity
• Children and people with smaller or non-average faces often have very limited options

Professional fit testing exists—but it's expensive, time-consuming, and inaccessible for most people.

How SnapFit Helps

SnapFit makes better mask fit accessible.

Using a quick facial scan, SnapFit recommends masks that are most likely to fit your face, based on real fit data and mask performance—not guesswork. No trial-and-error. No specialized equipment.

Better fit means better protection—for you and the people around you.
"""
        
        let attributedString = NSMutableAttributedString(string: content)
        
        // Set default font for all text
        let defaultFont = UIFont.systemFont(ofSize: 17)
        attributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: attributedString.length))
        
        // Format headlines (bold and larger)
        let headlineFont = UIFont.boldSystemFont(ofSize: 24)
        let headlines = ["Air Is Everywhere — And So Are Tiny Particles", "Why Fit Matters", "Fit Is Personal", "How SnapFit Helps"]
        
        for headline in headlines {
            let range = (content as NSString).range(of: headline)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: headlineFont, range: range)
            }
        }
        
        // Add clickable links
        let links = [
            "https://en.wikipedia.org/wiki/Transmission_of_COVID-19?utm_source=chatgpt.com",
            "https://en.wikipedia.org/wiki/Tidal_volume",
            "https://en.wikipedia.org/wiki/Pulmonary_alveolus"
        ]
        
        for link in links {
            let range = (content as NSString).range(of: link)
            if range.location != NSNotFound {
                attributedString.addAttribute(.link, value: link, range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
            }
        }
        
        // Emphasize "fitted" in the last sentence
        let fittedRange = (content as NSString).range(of: "fitted")
        if fittedRange.location != NSNotFound {
            let boldFont = UIFont.boldSystemFont(ofSize: 17)
            attributedString.addAttribute(.font, value: boldFont, range: fittedRange)
        }
        
        contentTextView.attributedText = attributedString
        contentTextView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        contentView.addSubview(contentTextView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Content text view
            contentTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
