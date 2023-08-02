
import Foundation

class NewsService {
    let apiKey: String
    let baseUrl = "https://newsapi.org/v2/everything"
    let sources = ["abc-news", "al-jazeera-english", "associated-press", "axios", "bloomberg", "business-insider",
                   "cbc-news", "cbs-news", "cnbc", "fortune", "independent", "mashable", "nbc-news", "newsweek",
                   "politico", "reuters", "the-guardian-uk", "the-hill", "the-huffington-post", "the-latest-news",
                   "the-telegraph", "time", "usa-today"]
    
    init() {
        self.apiKey = loadApiKeyFromConfigFile()!
    }

    func fetchArticles(
            sorting: ArticleListViewModel.SortBy? = nil,
            searchText: String? = nil,
            from: Date? = nil,
            to: Date? = nil,
            completion: @escaping ([Article]?, Error?) -> Void
    ) {
        var queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "sources", value: sources.joined(separator: ","))
        ]

        if let sortBy = sorting {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy.rawValue))
        }

        if let searchText = searchText {
            let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            queryItems.append(URLQueryItem(name: "q", value: encodedSearchText))
        }

        if let fromDate = from, let toDate = to {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            let fromDateStr = dateFormatter.string(from: fromDate)
            let toDateStr = dateFormatter.string(from: toDate)
            queryItems.append(URLQueryItem(name: "from", value: fromDateStr))
            queryItems.append(URLQueryItem(name: "to", value: toDateStr))
        }

        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }

        fetchArticles(url: url, completion: completion)
    }

    private func fetchArticles(url: URL, completion: @escaping ([Article]?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            let articles = try? decoder.decode(ArticleResponse.self, from: data).articles
            completion(articles, nil)
        }
        task.resume()
    }
}

func loadApiKeyFromConfigFile() -> String? {
        guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let configDictionary = NSDictionary(contentsOfFile: configPath),
              let apiKey = configDictionary["API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }
