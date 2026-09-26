import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var item: ListDisplayable?
    var htmlDescription: String?
    var preloadedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let item = item else { return }
        
        title = item.displayName
        
        let placeholder = preloadedImage ?? UIImage(systemName: "photo.artframe")
        detailImageView.setImage(from: item.displayImageUrl, placeholder: placeholder)
        
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        
        // Parse HTML Description
        if let htmlString = htmlDescription, !htmlString.isEmpty {
            if let data = htmlString.data(using: .utf8) {
                if let attributedString = try? NSMutableAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html,
                              .characterEncoding: String.Encoding.utf8.rawValue],
                    documentAttributes: nil) {
                    
                    let fullRange = NSRange(location: 0, length: attributedString.length)
                    
                    // Preserve Bold traits while changing to System Font
                    attributedString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
                        if let oldFont = value as? UIFont {
                            let isBold = oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) || oldFont.fontName.lowercased().contains("bold")
                            
                            let newFont = isBold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                            attributedString.addAttribute(.font, value: newFont, range: range)
                        }
                    }
                    
                    // Set color and premium line spacing
                    attributedString.addAttribute(.foregroundColor, value: UIColor.darkGray, range: fullRange)
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 6
                    
                    let isArabic = LanguageManager.shared.currentLanguage == "arabic"
                    let alignment: NSTextAlignment = isArabic ? .right : .left
                    paragraphStyle.alignment = alignment
                    
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
                    
                    descriptionTextView.attributedText = attributedString
                } else {
                    descriptionTextView.text = htmlString
                    
                    let isArabic = LanguageManager.shared.currentLanguage == "arabic"
                    descriptionTextView.textAlignment = isArabic ? .right : .left
                }
            }
        } else {
            descriptionTextView.text = LanguageManager.shared.getStaticString(for: "No description available.")
            let isArabic = LanguageManager.shared.currentLanguage == "arabic"
            descriptionTextView.textAlignment = isArabic ? .right : .left
        }
        
        setupNavigationBarButtons()
    }
    
    private func setupNavigationBarButtons() {
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )
        shareButton.tintColor = .label
        
        let isFav = FavoritesManager.shared.isFavorite(id: item?.id ?? "")
        let heartImageName = isFav ? "heart.fill" : "heart"
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: heartImageName),
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        favoriteButton.tintColor = .label
        
        navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
    }
    
    @objc private func favoriteTapped() {
        guard let item = item else { return }
        
        let favTip = FavoriteTip(
            id: item.id,
            originalName: item.displayName,
            displayImageUrl: item.displayImageUrl,
            languages: item.languages
        )
        
        FavoritesManager.shared.toggleFavorite(tip: favTip)
        setupNavigationBarButtons() // Refresh UI
    }
    
    @objc private func shareTapped() {
        guard let titleText = title else { return }
        
        var shareText = "Check out this beauty tip: \(titleText)\n\n"
        if let description = descriptionTextView.text, !description.isEmpty, description != "No description available." {
            shareText += description
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // For iPad support
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
}
