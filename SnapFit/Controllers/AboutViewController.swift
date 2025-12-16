import UIKit

/// View controller displaying information about MasqFit and mask fitting
class AboutViewController: UIViewController {

    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var headerTextView: UITextView!
    private var airborneImageView: UIImageView!
    private var captionLabel: UILabel!
    private var middleTextView: UITextView!
    private var airBreathedImageView: UIImageView!
    private var middle2TextView: UITextView!
    private var handsLungsImageView: UIImageView!
    private var middle3TextView: UITextView!
    private var qlftImageView: UIImageView!
    private var qlftCaptionLabel: UILabel!
    private var qnftImageView: UIImageView!
    private var qnftCaptionLabel: UILabel!
    private var bodyTextView: UITextView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        title = "About MasqFit"
        // Set background color to #2F80ED
        view.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
        
        // Set navigation bar title text color to white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

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
        headerTextView.textColor = .white
        headerTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerTextView.textContainer.lineFragmentPadding = 0
        headerTextView.translatesAutoresizingMaskIntoConstraints = false
        headerTextView.delegate = self

        // Create header content
        let headerContent = """
Air Is Everywhere — And So Are Tiny Particles

Air isn't just empty space — it's full of tiny particles called aerosols that can stay suspended for minutes to hours. These particles can carry viruses, bacteria, mold, and pollutants like smoke and exhaust fine particulates. Aerosolized pathogens are a major way respiratory diseases spread from person to person through breathing, talking, coughing, and sneezing.
"""

        // Create middle text view (content between first and second image)
        middleTextView = UITextView()
        middleTextView.isEditable = false
        middleTextView.isScrollEnabled = false
        middleTextView.backgroundColor = .clear
        middleTextView.textColor = .white
        middleTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        middleTextView.textContainer.lineFragmentPadding = 0
        middleTextView.translatesAutoresizingMaskIntoConstraints = false
        middleTextView.delegate = self

        // Create middle content
        let middleContent = """
The air you breathe matters more than many people realize:

• People inhale many thousands of liters of air every day, far more than the amount of water we usually drink, making healthy air exposure critical. (https://en.wikipedia.org/wiki/Tidal_volume)
"""

        // Create middle2 text view (content between second and third image)
        middle2TextView = UITextView()
        middle2TextView.isEditable = false
        middle2TextView.isScrollEnabled = false
        middle2TextView.backgroundColor = .clear
        middle2TextView.textColor = .white
        middle2TextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        middle2TextView.textContainer.lineFragmentPadding = 0
        middle2TextView.translatesAutoresizingMaskIntoConstraints = false
        middle2TextView.delegate = self

        // Create middle2 content
        let middle2Content = """
• The lungs have an enormous internal surface area — about 70–100 m² — to transfer oxygen to the blood. This large surface makes them efficient for gas exchange but also vulnerable to airborne contaminants. Your lungs expose an area about the size of a tennis court to the air you breathe — every day.
"""

        // Create middle3 text view (content between third and fourth image)
        middle3TextView = UITextView()
        middle3TextView.isEditable = false
        middle3TextView.isScrollEnabled = false
        middle3TextView.backgroundColor = .clear
        middle3TextView.textColor = .white
        middle3TextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        middle3TextView.textContainer.lineFragmentPadding = 0
        middle3TextView.translatesAutoresizingMaskIntoConstraints = false
        middle3TextView.delegate = self

        // Create middle3 content
        let middle3Content = """

We wash our hands. We regulate drinking water to high standards. Yet the largest interface between your body and the environment is your lungs. We should give the air we inhale the same respect — especially in crowded or poorly ventilated places where airborne particles accumulate. Masking using a fitted respirator is one of the best ways to protect oneself (and others if you are sick).


Why Fit Matters

High-quality respirators like N95s can filter over 95% of airborne particles—but only if they fit your face well.

Even small gaps between a mask and your face let unfiltered air leak in, dramatically reducing protection. A well-fitted respirator can provide 10–1000× more protection than a poorly fitting one, lowering the dose of airborne pathogens you inhale and reducing the risk of infection.

Fit Is Personal

Mask fit isn't one-size-fits-all. Face shape, size, nose measurements, and movement all affect how well a mask seals, and depends on the design of the mask. Studies show that:

• Some people need to try multiple masks to find one that fits
• Fit success varies by facial features, age, sex, and ethnicity
• Children and people with smaller or non-average faces often have very limited options

Professional fit testing exists—but it can be expensive, time-consuming, and/or inaccessible for most people.
"""

        // Create body text view (content after fourth image)
        bodyTextView = UITextView()
        bodyTextView.isEditable = false
        bodyTextView.isScrollEnabled = false
        bodyTextView.backgroundColor = .clear
        bodyTextView.textColor = .white
        bodyTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bodyTextView.textContainer.lineFragmentPadding = 0
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.delegate = self

        // Create body content
        let bodyContent = """

How MasqFit Helps

MasqFit makes better mask fit accessible.

Using a quick facial scan, MasqFit recommends masks that are most likely to fit your face, based on real fit data and mask performance—not guesswork, decreasing the need for trial-and-error and specialized equipment. It strikes a balance between accuracy and accessibility.

Better fit means better protection—for you and the people around you.
"""

        // Create and configure first image view (airborne transmission)
        airborneImageView = UIImageView()
        airborneImageView.image = UIImage(named: "AirborneTransmissionImage")
        airborneImageView.contentMode = .scaleAspectFit
        airborneImageView.translatesAutoresizingMaskIntoConstraints = false
        airborneImageView.isUserInteractionEnabled = true

        // Add tap gesture to first image
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(airborneImageTapped))
        airborneImageView.addGestureRecognizer(tapGesture1)

        // Create and configure second image view (air breathed)
        airBreathedImageView = UIImageView()
        airBreathedImageView.image = UIImage(named: "AirBreathedImage")
        airBreathedImageView.contentMode = .scaleAspectFit
        airBreathedImageView.translatesAutoresizingMaskIntoConstraints = false
        airBreathedImageView.isUserInteractionEnabled = true

        // Add tap gesture to second image
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(airBreathedImageTapped))
        airBreathedImageView.addGestureRecognizer(tapGesture2)

        // Create and configure third image view (hands vs lungs)
        handsLungsImageView = UIImageView()
        handsLungsImageView.image = UIImage(named: "HandsLungsSurfaceImage")
        handsLungsImageView.contentMode = .scaleAspectFit
        handsLungsImageView.translatesAutoresizingMaskIntoConstraints = false
        handsLungsImageView.isUserInteractionEnabled = true

        // Add tap gesture to third image
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handsLungsImageTapped))
        handsLungsImageView.addGestureRecognizer(tapGesture3)

        // Create and configure fourth image view (QLFT)
        qlftImageView = UIImageView()
        qlftImageView.image = UIImage(named: "QualitativeFitTestImage")
        qlftImageView.contentMode = .scaleAspectFit
        qlftImageView.translatesAutoresizingMaskIntoConstraints = false
        qlftImageView.isUserInteractionEnabled = true

        // Add tap gesture to fourth image
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(qlftImageTapped))
        qlftImageView.addGestureRecognizer(tapGesture4)

        // Create and configure fifth image view (QNFT)
        qnftImageView = UIImageView()
        qnftImageView.image = UIImage(named: "QuantitativeFitTestImage")
        qnftImageView.contentMode = .scaleAspectFit
        qnftImageView.translatesAutoresizingMaskIntoConstraints = false
        qnftImageView.isUserInteractionEnabled = true

        // Add tap gesture to fifth image
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(qnftImageTapped))
        qnftImageView.addGestureRecognizer(tapGesture5)

        // Create caption label for first image (airborne transmission)
        captionLabel = UILabel()
        captionLabel.text = "Phases involved in airborne transmission of respiratory viruses. Credit: From Wang et al., 'Airborne transmission of respiratory viruses' (https://doi.org/10.1126/science.abd9149). N.CARY/SCIENCE"
        captionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        captionLabel.textColor = .white
        captionLabel.numberOfLines = 0
        captionLabel.textAlignment = .center
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create caption label for QLFT image
        qlftCaptionLabel = UILabel()
        qlftCaptionLabel.text = "Qualitative Fit Testing"
        qlftCaptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        qlftCaptionLabel.textColor = .white
        qlftCaptionLabel.numberOfLines = 0
        qlftCaptionLabel.textAlignment = .center
        qlftCaptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create caption label for QNFT image
        qnftCaptionLabel = UILabel()
        qnftCaptionLabel.text = "Quantitative Fit Testing"
        qnftCaptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        qnftCaptionLabel.textColor = .white
        qnftCaptionLabel.numberOfLines = 0
        qnftCaptionLabel.textAlignment = .center
        qnftCaptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Format header content
        let headerAttributedString = NSMutableAttributedString(string: headerContent)
        let middleAttributedString = NSMutableAttributedString(string: middleContent)
        let middle2AttributedString = NSMutableAttributedString(string: middle2Content)
        let middle3AttributedString = NSMutableAttributedString(string: middle3Content)
        let bodyAttributedString = NSMutableAttributedString(string: bodyContent)

        let defaultFont = UIFont.systemFont(ofSize: 17)
        let headlineFont = UIFont.boldSystemFont(ofSize: 24)

        // Format header
        headerAttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: headerAttributedString.length))
        headerAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: headerAttributedString.length))

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
            headerAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: aerosolSentenceRange)
            headerAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: aerosolSentenceRange)
        }

        // Format middle content
        middleAttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: middleAttributedString.length))
        middleAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: middleAttributedString.length))

        // Add tidal volume link in middle content
        let tidalVolumeLink = "https://en.wikipedia.org/wiki/Tidal_volume"
        let tidalVolumeRange = (middleContent as NSString).range(of: tidalVolumeLink)
        if tidalVolumeRange.location != NSNotFound {
            middleAttributedString.addAttribute(.link, value: tidalVolumeLink, range: tidalVolumeRange)
            middleAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: tidalVolumeRange)
            middleAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tidalVolumeRange)
        }

        // Format middle2 content
        middle2AttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: middle2AttributedString.length))
        middle2AttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: middle2AttributedString.length))

        // Format middle3 content
        middle3AttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: middle3AttributedString.length))
        middle3AttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: middle3AttributedString.length))

        // Format middle3 headlines
        let middle3Headlines = ["Why Fit Matters", "Fit Is Personal"]
        for headline in middle3Headlines {
            let range = (middle3Content as NSString).range(of: headline)
            if range.location != NSNotFound {
                middle3AttributedString.addAttribute(.font, value: headlineFont, range: range)
            }
        }

        // Format body
        bodyAttributedString.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: bodyAttributedString.length))
        bodyAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: bodyAttributedString.length))

        // Format body headlines
        let bodyHeadlines = ["Why Fit Matters", "Fit Is Personal", "How MasqFit Helps"]
        for headline in bodyHeadlines {
            let range = (bodyContent as NSString).range(of: headline)
            if range.location != NSNotFound {
                bodyAttributedString.addAttribute(.font, value: headlineFont, range: range)
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
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        middleTextView.attributedText = middleAttributedString
        middleTextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        middle2TextView.attributedText = middle2AttributedString
        middle2TextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        middle3TextView.attributedText = middle3AttributedString
        middle3TextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        bodyTextView.attributedText = bodyAttributedString
        bodyTextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        contentView.addSubview(headerTextView)
        contentView.addSubview(airborneImageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(middleTextView)
        contentView.addSubview(airBreathedImageView)
        contentView.addSubview(middle2TextView)
        contentView.addSubview(handsLungsImageView)
        contentView.addSubview(middle3TextView)
        contentView.addSubview(qlftImageView)
        contentView.addSubview(qlftCaptionLabel)
        contentView.addSubview(qnftImageView)
        contentView.addSubview(qnftCaptionLabel)
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

            // Middle text view
            middleTextView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 20),
            middleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            middleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Air breathed image view
            airBreathedImageView.topAnchor.constraint(equalTo: middleTextView.bottomAnchor, constant: 20),
            airBreathedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            airBreathedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            airBreathedImageView.heightAnchor.constraint(equalTo: airBreathedImageView.widthAnchor, multiplier: 0.6), // Maintain aspect ratio

            // Middle2 text view
            middle2TextView.topAnchor.constraint(equalTo: airBreathedImageView.bottomAnchor, constant: 20),
            middle2TextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            middle2TextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Hands vs lungs image view
            handsLungsImageView.topAnchor.constraint(equalTo: middle2TextView.bottomAnchor, constant: 20),
            handsLungsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            handsLungsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            handsLungsImageView.heightAnchor.constraint(equalTo: handsLungsImageView.widthAnchor, multiplier: 0.65), // Maintain aspect ratio

            // Middle3 text view
            middle3TextView.topAnchor.constraint(equalTo: handsLungsImageView.bottomAnchor, constant: 20),
            middle3TextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            middle3TextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // QLFT image view
            qlftImageView.topAnchor.constraint(equalTo: middle3TextView.bottomAnchor, constant: 20),
            qlftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            qlftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            qlftImageView.heightAnchor.constraint(equalTo: qlftImageView.widthAnchor, multiplier: 0.6), // Maintain aspect ratio

            // QLFT caption label
            qlftCaptionLabel.topAnchor.constraint(equalTo: qlftImageView.bottomAnchor, constant: 8),
            qlftCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            qlftCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // QNFT image view
            qnftImageView.topAnchor.constraint(equalTo: qlftCaptionLabel.bottomAnchor, constant: 20),
            qnftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            qnftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            qnftImageView.heightAnchor.constraint(equalTo: qnftImageView.widthAnchor, multiplier: 0.55), // Maintain aspect ratio

            // QNFT caption label
            qnftCaptionLabel.topAnchor.constraint(equalTo: qnftImageView.bottomAnchor, constant: 8),
            qnftCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            qnftCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Body text view
            bodyTextView.topAnchor.constraint(equalTo: qnftCaptionLabel.bottomAnchor, constant: 20),
            bodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bodyTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func airborneImageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: airborneImageView.image)
        imageViewerVC.modalPresentationStyle = .fullScreen
        present(imageViewerVC, animated: true)
    }

    @objc private func airBreathedImageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: airBreathedImageView.image)
        imageViewerVC.modalPresentationStyle = .fullScreen
        present(imageViewerVC, animated: true)
    }

    @objc private func handsLungsImageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: handsLungsImageView.image)
        imageViewerVC.modalPresentationStyle = .fullScreen
        present(imageViewerVC, animated: true)
    }

    @objc private func qlftImageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: qlftImageView.image)
        imageViewerVC.modalPresentationStyle = .fullScreen
        present(imageViewerVC, animated: true)
    }

    @objc private func qnftImageTapped() {
        // Create a full-screen image viewer for zooming
        let imageViewerVC = ImageViewerViewController(image: qnftImageView.image)
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
