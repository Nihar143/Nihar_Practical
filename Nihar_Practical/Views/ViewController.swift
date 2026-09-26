//
//  ViewController.swift
//  Nihar_Practical
//
//  Created by Nihar Dudhat on 26/09/26.
//

import UIKit

class ViewController: UIViewController {
        
    let categoryIds: [String: String] = [
        "Face": "19",
        "Hair": "21",
        "Eye": "22",
        "Lips": "23",
        "Teeth": "24",
        "Nail": "25",
        "Hand": "28",
        "Leg": "29"
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        localizeButtons(in: view)
    }
    
    private func localizeButtons(in view: UIView) {
        for subview in view.subviews {
            if let button = subview as? UIButton {
                // If the button has an accessibility identifier, it was already parsed. Otherwise, set it to the original English title.
                let englishTitle = button.accessibilityIdentifier ?? button.configuration?.title ?? button.titleLabel?.text ?? ""
                
                if categoryIds.keys.contains(englishTitle) {
                    button.accessibilityIdentifier = englishTitle // Store English title for the tap action
                    let localizedTitle = LanguageManager.shared.getStaticString(for: englishTitle)
                    
                    if button.configuration != nil {
                        button.configuration?.title = localizedTitle
                    } else {
                        button.setTitle(localizedTitle, for: .normal)
                    }
                }
            } else if let label = subview as? UILabel {
                let englishText = label.accessibilityIdentifier ?? label.text ?? ""
                if englishText == "Skincare Routine" {
                    label.accessibilityIdentifier = englishText
                    label.text = LanguageManager.shared.getStaticString(for: englishText)
                    let isArabic = LanguageManager.shared.currentLanguage == "arabic"
                    label.textAlignment = isArabic ? .right : .left
                }
            }
            // Always recurse to find nested buttons or labels inside StackViews
            localizeButtons(in: subview)
        }
    }
    
    private func setupNavigationBar() {
        title = LanguageManager.shared.getStaticString(for: "Beauty Tips")
        let languageButton = UIBarButtonItem(image: UIImage(systemName: "globe"), style: .plain, target: self, action: #selector(languageButtonTapped))
        navigationItem.rightBarButtonItem = languageButton
    }
    
    @objc private func languageButtonTapped() {
        let alertTitle = LanguageManager.shared.getStaticString(for: "Select Language")
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        
        for lang in LanguageManager.shared.availableLanguages {
            let action = UIAlertAction(title: lang, style: .default) { _ in
                LanguageManager.shared.currentLanguage = lang
            }
            // Checkmark the current one
            if lang.lowercased() == LanguageManager.shared.currentLanguage.lowercased() {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        let cancelTitle = LanguageManager.shared.getStaticString(for: "Cancel")
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        // Use accessibilityIdentifier to safely get the original English title
        let englishTitle = sender.accessibilityIdentifier ?? sender.configuration?.title ?? sender.titleLabel?.text ?? ""
        
        guard let applicationId = categoryIds[englishTitle] else {
            print("Unknown category tapped: \(englishTitle)")
            return
        }
        
        let localizedTitle = LanguageManager.shared.getStaticString(for: englishTitle)
        print("Tapped \(englishTitle) with Application ID: \(applicationId)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CategoryListViewController") as? CategoryListViewController {
            vc.categoryTitle = localizedTitle
            vc.viewModel = CategoryListViewModel(mode: .category(applicationId: applicationId))
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
