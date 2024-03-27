import Combine
import FeedKit
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var rssItems: [FeedItem] = []
    @Published var favoriteItems: [FeedItem] = []
    @Published var showingErrorAlert = false
    
    func fetchRSSFeeds(feedURL: String) {
        guard let url = URL(string: feedURL) else {
            print("Invalid RSS feed URL")
            return
        }
        
        FeedParser(URL: url).parseAsync { result in
            switch result {
            case .success(let feed):
                DispatchQueue.main.async {
                    self.parseFeed(feed)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    private func parseFeed(_ feed: Feed) {
        switch feed {
        case .rss(let rssFeed):
            rssItems = rssFeed.items?.compactMap { item in
                FeedItem(
                    guid: item.guid?.value ?? UUID().uuidString,
                    title: item.title,
                    description: item.description,
                    link: item.link,
                    pubDate: item.pubDate,
                    rssFeedImageURL: URL(string: rssFeed.image?.url ?? "")
                )
            } ?? []
        default:
            print("Unsupported feed format")
        }
    }
    
    private func handleError(_ error: Error) {
        showingErrorAlert = true
        print("Error parsing RSS feed: \(error)")
    }
    
    func toggleFavoriteStatus(for item: FeedItem) {
        withAnimation {
            if let index = favoriteItems.firstIndex(where: { $0.id == item.id }) {
                favoriteItems.remove(at: index)
            } else {
                favoriteItems.append(item)
            }
        }
        
        if let index = rssItems.firstIndex(where: { $0.id == item.id }) {
            rssItems[index].isFavorite.toggle()
        }
    }
}
