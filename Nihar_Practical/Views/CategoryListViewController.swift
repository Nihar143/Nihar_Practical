import UIKit

class CategoryListViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var viewModel: CategoryListViewModel!
    var categoryTitle: String = ""
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = categoryTitle
        setupUI()
        setupViewModel()
        viewModel.fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if case .favorites = viewModel.mode {
            viewModel.fetchItems()
        }
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 115
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .systemGray
        tableView.refreshControl = refreshControl
        
        if case .favorites = viewModel.mode {
            // No search for favorites tab
        } else {
            setupSearchController()
        }
        
        retryButton.isHidden = true
        messageLabel.isHidden = true
        
        messageLabel.textAlignment = .center
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LanguageManager.shared.getStaticString(for: "Search categories...")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.search(query: query)
    }
    
    @objc private func handleRefresh() {
        // Clear search when refreshing
        searchController.searchBar.text = ""
        viewModel.fetchItems()
    }
    
    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.updateUI(for: state)
        }
    }
    
    private func updateUI(for state: ViewState) {
        switch state {
        case .loading:
            if !refreshControl.isRefreshing {
                loadingIndicator.startAnimating()
                tableView.isHidden = true
            }
            messageLabel.isHidden = true
            retryButton.isHidden = true
        case .loaded:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = false
            messageLabel.isHidden = true
            retryButton.isHidden = true
            
            if navigationItem.searchController == nil {
                if case .favorites = viewModel.mode {
                    // Do nothing
                } else {
                    navigationItem.searchController = searchController
                }
            }
            
            tableView.reloadData()
        case .empty:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = LanguageManager.shared.getStaticString(for: "No items found.")
            retryButton.isHidden = true
            
            // Only hide search bar if the base list is empty (not because of a search query)
            let query = searchController.searchBar.text ?? ""
            if query.isEmpty {
                navigationItem.searchController = nil
            }
            
        case .error(let errorMessage):
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = errorMessage
            retryButton.isHidden = false
            navigationItem.searchController = nil
        }
    }
    
    @IBAction func retryTapped(_ sender: UIButton) {
        viewModel.fetchItems()
    }
}

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item.displayName, imageUrl: item.displayImageUrl)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        
        switch viewModel.mode {
        case .category(let appId):
            // Navigate to Subcategories
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CategoryListViewController") as? CategoryListViewController {
                vc.categoryTitle = item.displayName
                vc.viewModel = CategoryListViewModel(mode: .subcategory(applicationId: appId, categoryId: item.id))
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        case .subcategory, .favorites:
            // Navigate to Detail View Controller from Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                detailVC.item = item
                if let subcategory = item as? Subcategory {
                    detailVC.htmlDescription = LanguageManager.shared.getLocalizedDescription(from: subcategory.language)
                } else if let favoriteTip = item as? FavoriteTip {
                    detailVC.htmlDescription = favoriteTip.htmlDescription
                }
                
                if let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
                    detailVC.preloadedImage = cell.categoryImageView.image
                }
                
                detailVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}
