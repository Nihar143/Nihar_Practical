import UIKit
import Kingfisher

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.kf.cancelDownloadTask()
        categoryImageView.image = nil
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10
        
        categoryImageView.layer.cornerRadius = 12
        categoryImageView.clipsToBounds = true
        
        // Ensure system icons (like chevron.right) automatically flip for RTL languages
        for subview in cardView.subviews {
            if let imgView = subview as? UIImageView, imgView != categoryImageView {
                if let currentImage = imgView.image {
                    imgView.image = currentImage.imageFlippedForRightToLeftLayoutDirection()
                }
            }
        }
    }
    
    func configure(with name: String, imageUrl: String) {
        categoryTitleLabel.text = name
        
        let isArabic = LanguageManager.shared.currentLanguage == "arabic"
        categoryTitleLabel.textAlignment = isArabic ? .right : .left
        
        let placeholder = UIImage(systemName: "photo.artframe")
        categoryImageView.setImage(from: imageUrl, placeholder: placeholder, isLoader: true)
    }
}
