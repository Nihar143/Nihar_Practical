import Foundation

struct FavoriteTip: Codable, ListDisplayable {
    let id: String
    let originalName: String
    let displayImageUrl: String
    let languages: [Language]
    
    var displayName: String {
        return LanguageManager.shared.getLocalizedName(from: languages, fallback: originalName)
    }
    
    var htmlDescription: String? {
        return LanguageManager.shared.getLocalizedDescription(from: languages)
    }
}

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "savedFavorites"
    
    private init() {}
    
    func getFavorites() -> [FavoriteTip] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return [] }
        if let favorites = try? JSONDecoder().decode([FavoriteTip].self, from: data) {
            return favorites
        }
        return []
    }
    
    func isFavorite(id: String) -> Bool {
        return getFavorites().contains { $0.id == id }
    }
    
    func toggleFavorite(tip: FavoriteTip) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(where: { $0.id == tip.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(tip)
        }
        
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
}
