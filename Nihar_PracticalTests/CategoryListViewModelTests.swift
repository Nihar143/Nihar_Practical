import XCTest
@testable import Nihar_Practical

// MARK: - Mock Network Service
class MockNetworkService: NetworkServiceType {
    var shouldReturnError = false
    var returnedCategories: [Category] = []
    
    func getCategories(applicationId: String) async throws -> [Category] {
        if shouldReturnError {
            throw AppError.serverError("Mock Error")
        }
        return returnedCategories
    }
    
    func getSubcategories(applicationId: String, categoryId: String) async throws -> [Subcategory] {
        if shouldReturnError {
            throw AppError.serverError("Mock Error")
        }
        return []
    }
}

// MARK: - Unit Tests
final class CategoryListViewModelTests: XCTestCase {

    // 1. Model Decoding Test
    func testModelDecodingFromJSON() throws {
        let json = """
        {
            "id": "1",
            "applicationid": "19",
            "category_name": "Face Wrinkles",
            "image": "https://example.com/image.jpg",
            "language": []
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let category = try decoder.decode(Category.self, from: json)
        
        XCTAssertEqual(category.id, "1")
        XCTAssertEqual(category.applicationId, "19")
        XCTAssertEqual(category.categoryName, "Face Wrinkles")
        XCTAssertEqual(category.image, "https://example.com/image.jpg")
    }

    // 2. ViewModel Success Case
    func testViewModelFetchSuccess() {
        // Arrange
        let mockService = MockNetworkService()
        mockService.returnedCategories = [
            Category(id: "1", applicationId: "19", categoryName: "Test Category", image: "", audioFile: nil, language: [])
        ]
        
        let viewModel = CategoryListViewModel(mode: .category(applicationId: "19"), networkService: mockService)
        
        let expectation = self.expectation(description: "ViewModel should trigger loaded state")
        
        viewModel.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // Act
        viewModel.fetchItems()
        
        // Assert
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.displayName, "Test Category")
    }
    
    // 3. ViewModel Failure Case
    func testViewModelFetchFailure() {
        // Arrange
        let mockService = MockNetworkService()
        mockService.shouldReturnError = true
        
        let viewModel = CategoryListViewModel(mode: .category(applicationId: "19"), networkService: mockService)
        
        let expectation = self.expectation(description: "ViewModel should trigger error state")
        
        viewModel.onStateChange = { state in
            if case .error(let message) = state {
                XCTAssertEqual(message, "Mock Error") // Matches our mock error description
                expectation.fulfill()
            }
        }
        
        // Act
        viewModel.fetchItems()
        
        // Assert
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(viewModel.items.isEmpty)
    }
}
