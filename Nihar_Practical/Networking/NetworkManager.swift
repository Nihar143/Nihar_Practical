import Foundation

enum AppError: Error, LocalizedError {
    case invalidURL
    case noInternet
    case badRequest(Int)
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided is invalid."
        case .noInternet: return "No Internet connection. Please check your network."
        case .badRequest(let code): return "Bad response from server (Code: \(code))."
        case .serverError(let msg): return msg
        case .decodingError: return "Failed to process data from server."
        case .unknown: return "An unexpected error occurred."
        }
    }
}

protocol NetworkServiceType {
    func getCategories(applicationId: String) async throws -> [Category]
    func getSubcategories(applicationId: String, categoryId: String) async throws -> [Subcategory]
}

class NetworkManager: NetworkServiceType {
    static let shared = NetworkManager()
    
    private let baseURL = "https://mobilehubs.website/appmanagement123/api/"
    
    private init() {}
    
    private func handleNetworkError(_ error: Error) -> AppError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost:
                return .noInternet
            default:
                return .unknown
            }
        }
        return (error as? AppError) ?? .unknown
    }
    
    // MARK: - Offline Caching Helpers
    private func getCachedCategories(applicationId: String) -> [Category]? {
        let key = "cache_categories_\(applicationId)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([Category].self, from: data)
    }
    
    private func saveCategoriesToCache(_ categories: [Category], applicationId: String) {
        let key = "cache_categories_\(applicationId)"
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func getCachedSubcategories(applicationId: String, categoryId: String) -> [Subcategory]? {
        let key = "cache_subcategories_\(applicationId)_\(categoryId)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([Subcategory].self, from: data)
    }
    
    private func saveSubcategoriesToCache(_ subcategories: [Subcategory], applicationId: String, categoryId: String) {
        let key = "cache_subcategories_\(applicationId)_\(categoryId)"
        if let data = try? JSONEncoder().encode(subcategories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // MARK: - API Calls
    func getCategories(applicationId: String) async throws -> [Category] {
        guard let url = URL(string: baseURL + "getcategory?applicationid=\(applicationId)") else {
            throw AppError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw AppError.badRequest((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            
            let categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
            if categoryResponse.status {
                // Save to cache on success
                saveCategoriesToCache(categoryResponse.data, applicationId: applicationId)
                return categoryResponse.data
            } else {
                throw AppError.serverError(categoryResponse.message)
            }
        } catch {
            // Fallback to cache on any error (No internet, timeout, etc.)
            if let cached = getCachedCategories(applicationId: applicationId) {
                return cached
            }
            throw handleNetworkError(error)
        }
    }
    
    func getSubcategories(applicationId: String, categoryId: String) async throws -> [Subcategory] {
        guard let url = URL(string: baseURL + "getsubcategory?applicationid=\(applicationId)&categoryid=\(categoryId)") else {
            throw AppError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw AppError.badRequest((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            
            let subcategoryResponse = try JSONDecoder().decode(SubcategoryResponse.self, from: data)
            if subcategoryResponse.status {
                // Save to cache on success
                saveSubcategoriesToCache(subcategoryResponse.data, applicationId: applicationId, categoryId: categoryId)
                return subcategoryResponse.data
            } else {
                throw AppError.serverError(subcategoryResponse.message)
            }
        } catch {
            // Fallback to cache on any error
            if let cached = getCachedSubcategories(applicationId: applicationId, categoryId: categoryId) {
                return cached
            }
            throw handleNetworkError(error)
        }
    }
}
