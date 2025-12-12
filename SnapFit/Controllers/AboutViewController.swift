import UIKit

/// View controller displaying information about SnapFit and mask fitting
class AboutViewController: UIViewController {

    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var headerTextView: UITextView!
    private var airborneImageView: UIImageView!
    private var captionLabel: UILabel!
    private var bodyTextView: UITextView!

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

        // Create header text view (content before image)
        headerTextView = UITextView()
        headerTextView.isEditable = false
        headerTextView.isScrollEnabled = false
        headerTextView.backgroundColor = .clear
        headerTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerTextView.textContainer.lineFragmentPadding = 0
        headerTextView.translatesAutoresizingMaskIntoConstraints = false
        headerTextView.delegate = self

        // Create header content
        let headerContent = """
Air Is Everywhere — And So Are Tiny Particles

Air isn't just empty space — it's full of tiny particles called aerosols that can stay suspended for minutes to hours. These particles can carry viruses, bacteria, mold, and pollutants like smoke and exhaust fine particulates. Aerosolized pathogens are a major way respiratory diseases spread from person to person through breathing, talking, coughing, and sneezing.
"""

        // Create body text view (content after image)
        bodyTextView = UITextView()
        bodyTextView.isEditable = false
        bodyTextView.isScrollEnabled = false
        bodyTextView.backgroundColor = .clear
        bodyTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.delegate = self

        // Create body content
        let bodyContent = """
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

        // Create and configure image view
        airborneImageView = UIImageView()
        airborneImageView.image = UIImage(named: "AirborneTransmissionImage")
        airborneImageView.contentMode = .scaleAspectFit
        airborneImageView.translatesAutoresizingMaskIntoConstraints = false
        airborneImageView.isUserInteractionEnabled = true
        
        // Add tap gesture to image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        airborneImageView.addGestureRecognizer(tapGesture)
        
        // Create caption label
        captionLabel = UILabel()
        captionLabel.text = "Phases involved in airborne transmission of respiratory viruses. Credit: From Wang et al., 'Airborne transmission of respiratory viruses' (https://doi.org/10.1126/science.abd9149). N.CARY/SCIENCE"
        captionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        captionLabel.textColor = UIColor.secondaryLabel
        captionLabel.numberOfLines = 0
        captionLabel.textAlignment = .center
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Format header content
        let headerAttributedString = NSMutableAttributedString(string: headerContent)
        let bodyAttributedString = NSMutableAttributedString(string: bodyContent)
        
        let defaultFont = UIFont.systemFont(ofSize: 17)
        let headlineFont = UIFont.boldSystemFont(ofSize: 24)
        
        // Format header
        headerAttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: headerAttributedString.length))
        headerAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: headerAttributedString.length))
        
        // Format header headline
        let headerHeadline = "Air Is Everywhere — And So Are Tiny Particles"
        let headerHeadlineRange = (headerContent as NSString).range(of: headerHeadline)
        if headerHeadlineRange.location != NSNotFound {
            headerAttributedString.addAttribute(.font, value: headlineFont, range: headerHeadlineRange)
        }
        
        // Add link to the sentence about aerosolized pathogens
        let aerosolSentence = "Aerosolized pathogens are a major way respiratory diseases spread from person to person through breathing, talking, coughing, and sneezing."
        let aerosolSentenceRange = (headerContent as NSString).range(of: aerosolSentence)
        if aerosolSentenceRange.location != NSNotFound {
            let scienceLink = "https://www.science.org/doi/10.1126/science.abd9149"
            headerAttributedString.addAttribute(.link, value: scienceLink, range: aerosolSentenceRange)
            headerAttributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: aerosolSentenceRange)
        }
        
        // Format body
        bodyAttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: bodyAttributedString.length))
        bodyAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: bodyAttributedString.length))
        
        // Format body headlines
        let bodyHeadlines = ["Why Fit Matters", "Fit Is Personal", "How SnapFit Helps"]
        for headline in bodyHeadlines {
            let range = (bodyContent as NSString).range(of: headline)
            if range.location != NSNotFound {
                bodyAttributedString.addAttribute(.font, value: headlineFont, range: range)
            }
        }
        
        // Add links in body
        let bodyLinks = [
            "https://en.wikipedia.org/wiki/Tidal_volume",
            "https://en.wikipedia.org/wiki/Pulmonary_alveolus"
        ]
        for link in bodyLinks {
            let range = (bodyContent as NSString).range(of: link)
            if range.location != NSNotFound {
                bodyAttributedString.addAttribute(.link, value: link, range: range)
                bodyAttributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
            }
        }
        
        // Emphasize "fitted"
        let fittedRange = (bodyContent as NSString).range(of: "fitted")
        if fittedRange.location != NSNotFound {
            let boldFont = UIFont.boldSystemFont(ofSize: 17)
            bodyAttributedString.addAttribute(.font, value: boldFont, range: fittedRange)
        }
        
        headerTextView.attributedText = headerAttributedString
        headerTextView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        bodyTextView.attributedText = bodyAttributedString
        bodyTextView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        contentView.addSubview(headerTextView)
        contentView.addSubview(airborneImageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(bodyTextView)

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

            // Header text view
            headerTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Airborne image view
            airborneImageView.topAnchor.constraint(equalTo: headerTextView.bottomAnchor, constant: 20),
            airborneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            airborneImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            airborneImageView.heightAnchor.constraint(equalTo: airborneImageView.widthAnchor, multiplier: 0.75), // Maintain aspect ratio
            
            // Caption label
            captionLabel.topAnchor.constraint(equalTo: airborneImageView.bottomAnchor, constant: 8),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Body text view
            bodyTextView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 20),
            bodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bodyTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func imageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: airborneImageView.image)
        imageViewerVC.modalPresentationStyle = .fullScreen
        present(imageViewerVC, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
