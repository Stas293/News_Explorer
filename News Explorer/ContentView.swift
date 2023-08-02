
import SwiftUI

struct ArticleListView: View {
    @StateObject var viewModel = ArticleListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                HStack {
                    DatePicker("From", selection: $viewModel.fromDate, displayedComponents: [.date])
                    DatePicker("To", selection: $viewModel.toDate, displayedComponents: [.date])
                }
                .padding(.horizontal)
                Picker("Sort By", selection: $viewModel.sortBy) {
                    Text("Published At").tag(ArticleListViewModel.SortBy.publishedAt)
                    Text("Relevancy").tag(ArticleListViewModel.SortBy.relevancy)
                    Text("Popularity").tag(ArticleListViewModel.SortBy.popularity)
                }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                List {
                    ForEach(viewModel.filteredArticles, id: \.title) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRowView(article: article, description: article.description ?? "")
                        }
                    }
                }
            }
                    .navigationTitle("News")
        }
    }
}

struct ArticleRowView: View {
    let article: Article
    let description: String

    var body: some View {
        HStack {
            if let urlToImage = article.urlToImage {
                AsyncImage(url: URL(string: urlToImage)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "photo")
                            .foregroundColor(.gray)
                }
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .padding(.trailing)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                        .font(.headline)
                        .lineLimit(2)
                Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                Spacer()
            }
        }
    }
}

struct ArticleDetailView: View {
    let article: Article
    @State private var showFullDescription = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let urlToImage = article.urlToImage {
                    AsyncImage(url: URL(string: urlToImage)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "photo")
                                .foregroundColor(.gray)
                    }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .padding(.bottom)
                }
                Text(article.title )
                        .font(.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom)
                Text(article.description ?? "")
                        .font(.body)
                        .padding(.bottom)
                Button("Read More") {
                    UIApplication.shared.open(URL(string: article.url )!)

                }
                        .foregroundColor(.blue)
                        .padding(.bottom)
                Text(article.content ?? "")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(showFullDescription ? 1 : 0)
                        .padding(.bottom)
                        .onAppear {
                            withAnimation {
                                showFullDescription = true
                            }
                        }
                HStack {
                    Spacer()
                    Text("\(article.source.name ?? "") - \(article.publishedAt ?? "") - \(article.author ?? "Unknown Author")")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                }
            }
                    .padding()
        }
        .navigationTitle(article.title )
    }


}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            TextField("Search", text: $text)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            Spacer()
        }
                .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleListView()
    }
}
