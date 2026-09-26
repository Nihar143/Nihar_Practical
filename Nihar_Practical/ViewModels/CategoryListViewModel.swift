import Foundation

enum ViewState {
    case loading
    case loaded
    case empty
    case error(String)
}

enum ListMode {
    case category(applicationId: String)
    case subcategory(applicationId: String, categoryId: String)
    case favorites
}

class CategoryListViewModel {
    
    private var allItems: [ListDisplayable] = []
    var items: [ListDisplayable] = []
    let mode: ListMode
    let networkService: NetworkServiceType
    
    var onStateChange: ((ViewState) -> Void)?
    
    init(mode: ListMode, networkService: NetworkServiceType = NetworkManager.shared) {
        self.mode = mode
        self.networkService = networkService
    }
    
    func fetchItems() {
        onStateChange?(.loading)
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchedItems: [ListDisplayable]
                switch self.mode {
                case .category(let appId):
                    fetchedItems = try await self.networkService.getCategories(applicationId: appId)
                case .subcategory(let appId, let catId):
                    fetchedItems = try await self.networkService.getSubcategories(applicationId: appId, categoryId: catId)
                case .favorites:
                    fetchedItems = FavoritesManager.shared.getFavorites()
                }
                
                DispatchQueue.main.async {
                    self.allItems = fetchedItems
                    self.items = fetchedItems
                    if fetchedItems.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.loaded)
                    }
                }
            } catch let error as AppError {
                DispatchQueue.main.async {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            } catch {
                DispatchQueue.main.async {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }
        }
    }
    
    func search(query: String) {
        if query.isEmpty {
            items = allItems
        } else {
            items = allItems.filter { $0.displayName.lowercased().contains(query.lowercased()) }
        }
        
        if items.isEmpty {
            onStateChange?(.empty)
        } else {
            onStateChange?(.loaded)
        }
    }
}
