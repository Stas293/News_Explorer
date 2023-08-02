
import Foundation

struct Article: Codable {
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let author: String?
    let source: Source
    let publishedAt: String?
    let content: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decode(String.self, forKey: .url)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.source = try container.decode(Source.self, forKey: .source)
        self.publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        self.content = try deleteSpecialCharacters(text: container.decodeIfPresent(String.self, forKey: .content))
    }
}

func deleteSpecialCharacters(text: String?) -> String? {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
    return text?.filter {
        okayChars.contains($0)
    }
}

struct Source: Codable {
    let id: String?
    let name: String?
}

struct ArticleResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

