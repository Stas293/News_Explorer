
import Foundation

import Foundation
import Combine

class ArticleListViewModel: ObservableObject {
    
    enum SortBy: String {
        case relevancy
        case publishedAt
        case popularity
    }
    
    @Published var articles: [Article] = []
    @Published var searchText: String = ""
    @Published var sortBy: SortBy = .publishedAt
    @Published var fromDate: Date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    @Published var toDate: Date = Date()
    
    private let newsService = NewsService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        fetchArticles()
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.fetchArticles()
            }
            .store(in: &cancellables)
        
        $sortBy
            .removeDuplicates()
            .sink { [weak self] sortBy in
                self?.fetchArticles()
            }
            .store(in: &cancellables)
    }
    
    private func fetchArticles() {
        if searchText.isEmpty {
            newsService.fetchArticles(sorting: sortBy,
                                      from: fromDate,
                                      to: toDate) { articles, error in
                if let articles = articles {
                    DispatchQueue.main.async {
                        self.articles = articles
                    }
                }
            }
        } else {
            newsService.fetchArticles(sorting: sortBy,
                                      searchText: searchText,
                                      from: fromDate,
                                      to: toDate) { articles, error in
                if let articles = articles {
                    DispatchQueue.main.async {
                        self.articles = articles
                    }
                }
            }
        }
    }
    
    var filteredArticles: [Article] {
        fetchArticles()
        return articles
    }
}
