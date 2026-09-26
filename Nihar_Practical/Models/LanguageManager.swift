import Foundation
import UIKit

class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "selectedLanguage"
    
    let availableLanguages = ["English", "Hindi", "Telugu", "Arabic", "Spanish", "French"]
    
    var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: languageKey) ?? "english"
        }
        set {
            if newValue.lowercased() != currentLanguage {
                UserDefaults.standard.set(newValue.lowercased(), forKey: languageKey)
                updateRTL(shouldRecreateRoot: true)
            }
        }
    }
    
    private init() {
        updateRTL(shouldRecreateRoot: false)
    }
    
    func updateRTL(shouldRecreateRoot: Bool) {
        let isArabic = currentLanguage == "arabic"
        UIView.appearance().semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        
        if shouldRecreateRoot {
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                
                // Re-instantiate the root view controller to apply the RTL layout immediately
                sceneDelegate.recreateRootViewController()
            }
        }
    }
    
    func getLocalizedName(from languages: [Language], fallback: String) -> String {
        let lang = languages.first(where: { $0.languageName.lowercased() == currentLanguage }) ?? languages.first
        let name = lang?.name ?? fallback
        return name.isEmpty ? fallback : name
    }
    
    // MARK: - Static UI Translations
    private let staticTranslations: [String: [String: String]] = [
        "Beauty Tips": [
            "hindi": "ब्यूटी टिप्स", "telugu": "బ్యూటీ చిట్కాలు", "arabic": "نصائح الجمال",
            "spanish": "Consejos de Belleza", "french": "Astuces Beauté"
        ],
        "Home": [
            "hindi": "होम", "telugu": "హోమ్", "arabic": "الرئيسية",
            "spanish": "Inicio", "french": "Accueil"
        ],
        "Favorites": [
            "hindi": "पसंदीदा", "telugu": "ఇష్టమైనవి", "arabic": "المفضلة",
            "spanish": "Favoritos", "french": "Favoris"
        ],
        "Select Language": [
            "hindi": "भाषा चुनें", "telugu": "భాషను ఎంచుకోండి", "arabic": "اختر اللغة",
            "spanish": "Seleccionar Idioma", "french": "Choisir la langue"
        ],
        "Cancel": [
            "hindi": "रद्द करें", "telugu": "రద్దు చేయండి", "arabic": "إلغاء",
            "spanish": "Cancelar", "french": "Annuler"
        ],
        "Search categories...": [
            "hindi": "श्रेणियां खोजें...", "telugu": "వర్గాలను శోధించండి...", "arabic": "البحث في الفئات...",
            "spanish": "Buscar categorías...", "french": "Rechercher des catégories..."
        ],
        "No items found.": [
            "hindi": "कोई आइटम नहीं मिला।", "telugu": "ఏ వస్తువులు కనుగొనబడలేదు.", "arabic": "لم يتم العثور على عناصر.",
            "spanish": "No se encontraron artículos.", "french": "Aucun article trouvé."
        ],
        "No description available.": [
            "hindi": "कोई विवरण उपलब्ध नहीं है।", "telugu": "వివరణ అందుబాటులో లేదు.", "arabic": "لا يوجد وصف متاح.",
            "spanish": "Sin descripción disponible.", "french": "Aucune description disponible."
        ],
        // Home Screen Categories
        "Face": [
            "hindi": "चेहरा", "telugu": "ముఖం", "arabic": "وجه",
            "spanish": "Cara", "french": "Visage"
        ],
        "Hair": [
            "hindi": "बाल", "telugu": "జుట్టు", "arabic": "شعر",
            "spanish": "Cabello", "french": "Cheveux"
        ],
        "Eye": [
            "hindi": "आंख", "telugu": "కన్ను", "arabic": "عين",
            "spanish": "Ojo", "french": "Œil"
        ],
        "Lips": [
            "hindi": "होंठ", "telugu": "పెదవులు", "arabic": "شفاه",
            "spanish": "Labios", "french": "Lèvres"
        ],
        "Teeth": [
            "hindi": "दांत", "telugu": "పళ్ళు", "arabic": "أسنان",
            "spanish": "Dientes", "french": "Dents"
        ],
        "Nail": [
            "hindi": "नाखून", "telugu": "గోరు", "arabic": "ظفر",
            "spanish": "Uña", "french": "Ongle"
        ],
        "Hand": [
            "hindi": "हाथ", "telugu": "చెయ్యి", "arabic": "يد",
            "spanish": "Mano", "french": "Main"
        ],
        "Leg": [
            "hindi": "पैर", "telugu": "కాలు", "arabic": "ساق",
            "spanish": "Pierna", "french": "Jambe"
        ],
        "Skincare Routine": [
            "hindi": "स्किनकेयर रूटीन", "telugu": "చర్మ సంరక్షణ", "arabic": "روتين العناية بالبشرة",
            "spanish": "Rutina de Cuidado", "french": "Routine de Soin"
        ]
    ]
    
    func getStaticString(for key: String) -> String {
        let lang = currentLanguage.lowercased()
        if lang == "english" { return key }
        return staticTranslations[key]?[lang] ?? key
    }
    
    func getLocalizedDescription(from languages: [Language]) -> String? {
        let lang = languages.first(where: { $0.languageName.lowercased() == currentLanguage }) ?? languages.first
        return lang?.description
    }
}
