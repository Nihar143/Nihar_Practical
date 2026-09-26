import Foundation

// MARK: - Category Response
struct CategoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [Category]
}

// MARK: - Category
struct Category: Codable {
    let id: String
    let applicationId: String
    let categoryName: String
    let image: String
    let audioFile: String?
    let language: [Language]

    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "applicationid"
        case categoryName = "category_name"
        case image
        case audioFile = "audio_file"
        case language
    }
}

// MARK: - Language
struct Language: Codable {
    let languageName: String
    let name: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case languageName = "language_name"
        case name
        case description
    }
}

// MARK: - Subcategory Response
struct SubcategoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [Subcategory]
}

// MARK: - Subcategory
struct Subcategory: Codable {
    let id: String
    let applicationId: String
    let categoryId: String
    let subcategoryName: String
    let image: String
    let language: [Language]
    
    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "applicationid"
        case categoryId = "categoryid"
        case subcategoryName = "subcategory_name"
        case image
        case language
    }
}

// MARK: - Display Protocol
protocol ListDisplayable {
    var id: String { get }
    var displayName: String { get }
    var displayImageUrl: String { get }
    var languages: [Language] { get }
}

extension Category: ListDisplayable {
    var displayName: String {
        return LanguageManager.shared.getLocalizedName(from: language, fallback: categoryName)
    }
    var displayImageUrl: String { return image }
    var languages: [Language] { return language }
}

extension Subcategory: ListDisplayable {
    var displayName: String {
        return LanguageManager.shared.getLocalizedName(from: language, fallback: subcategoryName)
    }
    var displayImageUrl: String { return image }
    var languages: [Language] { return language }
}
