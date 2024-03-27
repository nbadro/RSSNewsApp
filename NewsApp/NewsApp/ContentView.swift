import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @State private var feedURL: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Enter RSS feed URL", text: $feedURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.footnote)
                    .padding()
                Button(action: {
                    viewModel.fetchRSSFeeds(feedURL: feedURL)
                }) {
                    Text("Fetch")
                }.disabled(feedURL.isEmpty)
                    .padding()
                    .frame(height: 30)
                    .foregroundColor(feedURL.isEmpty ? .gray : Color(.systemTeal))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(feedURL.isEmpty ? .gray : Color(.systemTeal))
                    )
                    .padding(.leading)
                    .alert(isPresented: $viewModel.showingErrorAlert) {
                        Alert(title: Text("Invalid URL"), message: Text("Please enter URL again"), dismissButton: .default(Text("OK")))
                    }
                
                rssItemsList
                
            }.navigationBarTitle("News Feed")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: FavoritesView(favorites: viewModel.favoriteItems)) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(.systemTeal))
                        }
                    }
                }
        }
    }
    
    private var rssItemsList: some View {
        List {
            ForEach(viewModel.rssItems) { item in
                NavigationLink(destination: RSSFeedItemDetailView(item: item)) {
                    RSSFeedView(item: item).contextMenu {
                        Button(action: {
                            viewModel.toggleFavoriteStatus(for: item)
                        }) {
                            if item.isFavorite {
                                Label("Unfavorite", systemImage: "star.fill")
                            } else {
                                Label("Favorite", systemImage: "star").foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .onDelete(perform: removeRSSItem)
        }
    }
    
    func removeRSSItem(at offsets: IndexSet) {
        viewModel.rssItems.remove(atOffsets: offsets)
    }
}

struct RSSFeedItemDetailView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            RSSFeedView(item: item)
            if let websiteURL = URL(string: item.link ?? ""){
                Button("Open website") {
                    UIApplication.shared.open(websiteURL)
                }
                .padding()
                .frame(height: 30)
                .foregroundColor(Color(.systemTeal))
                .cornerRadius(10)
                Spacer()
            }
        }.padding()
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct RSSFeedView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            if let rssFeedImageURL = item.rssFeedImageURL {
                AsyncImage(url: rssFeedImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
            }
            Text(item.title ?? "No title")
                .font(.headline)
            
            Text(item.description ?? "No description")
                .font(.subheadline)
                .foregroundColor(.gray)
        }.padding()
    }
}

struct FavoritesView: View {
    var favorites: [FeedItem]
    
    var body: some View {
        List {
            ForEach(favorites) { item in
                NavigationLink(destination: RSSFeedItemDetailView(item: item)) {
                    VStack {
                        Text(item.title ?? "No title")
                            .font(.headline)
                        
                        Text(item.description ?? "No description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Favorites")
    }
}

struct FeedItem: Identifiable {
    let id = UUID()
    let guid: String
    let title: String?
    let description: String?
    let link: String?
    let pubDate: Date?
    let rssFeedImageURL: URL?
    var isFavorite: Bool = false
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
