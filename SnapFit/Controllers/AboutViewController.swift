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
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.textColor = UIColor.label
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the content
        let content = """
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
        
        contentTextView.text = content
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
