//
//  Ex_UIImageView.swift
//  Nihar_Practical
//
//  Created by Nihar Dudhat on 26/09/26.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {

    func setImage(
        from urlString: String?,
        placeholder: UIImage? = nil,
        isLoader: Bool = false,
        completion: ((Swift.Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {

        self.kf.indicatorType = isLoader ? .activity : .none

        let encodedUrlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: encodedUrlString) else {
            self.image = placeholder
            completion?(.failure(.requestError(reason: .emptyRequest)))
            return
        }

        superview?.layoutIfNeeded()
        layoutIfNeeded()
        
        var size = bounds.size
        if size.width == 0 || size.height == 0 {
            size = CGSize(width: 75, height: 75) // Fallback size for our cells
        }
        
        let processor = DownsamplingImageProcessor(size: size)

        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .backgroundDecode,             // Decode off main thread
                .memoryCacheExpiration(.seconds(180)) // 3 min TTL
            ],
            progressBlock: nil
        ) { result in
            self.kf.indicatorType = .none
            completion?(result)
        }
    }
}
