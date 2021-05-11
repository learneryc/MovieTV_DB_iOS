//
//  HomeView.swift
//  movieBar
//

import SwiftUI
import SwiftyJSON

struct HomeView: View {
    
    @State private var category: String="movie"
    @State var isShowing: Bool=false
    @State var message: String=""
    
    @ObservedObject var data = HomeData()
    
    var body: some View {
        
        if data.nowPlayingMoviesReady && data.trendingTVShowsReady
        && data.topRatedMoviesReady && data.topRatedTVShowsReady
        && data.popularMoviesReady && data.popularTVShowsReady {
            
            NavigationView {
                HomeContentView(category: category, data: data, isShowing: $isShowing, message: $message)
                .toolbar {
                    Button(category=="movie" ? "TV shows" : "Movies") {
                        category = category=="movie" ? "tv" : "movie"
                    }
                }
                .navigationBarTitle("USC Films")
            }

        } else {
            ProgressView("Fetching Data...").progressViewStyle(CircularProgressViewStyle())
        }
    }
}

struct HomeContentView: View {
    var category: String
    var data: HomeData
    @Binding var isShowing: Bool
    @Binding var message: String
    
    var body: some View {
        ScrollView {
            if category=="movie" {
                VStack(alignment: .leading) {
                    Text("Now Playing").font(.title2).bold()
                    HomeCarouselView(items: data.nowPlayingMovies, category: category)
                    HomeCards(items: data.topRatedMovies, title: "Top Rated", type: category, isShowing: $isShowing, message: $message)
                    HomeCards(items: data.popularMovies, title: "Popular", type: category, isShowing: $isShowing, message: $message)
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Trending").font(.title2).bold()
                    HomeCarouselView(items: data.trendingTVShows, category: category)
                    HomeCards(items: data.topRatedTVShows, title: "Top Rated", type: category, isShowing: $isShowing, message: $message)
                    HomeCards(items: data.popularTVShows, title: "Popular", type: category, isShowing: $isShowing, message: $message)
                }
            }
            
            VStack {
                /*Button(action: {
                    openURL(URL(string: "https://www.themoviedb.org/")!)
                }) {
                        Text("Powered by TMDB").font(.caption).foregroundColor(.secondary)
                    }*/
                Link(destination: URL(string: "https://www.themoviedb.org/")!) {
                    Text("Powered by TMDB").font(.caption).foregroundColor(.secondary)
                }
                Text("Developed by Yuchu Liu").font(.caption).foregroundColor(.secondary)
            }.padding(.bottom)
            
            
        }.padding(.horizontal)
        .toast(isShowing: self.$isShowing, text: Text(self.message))
        
    }
    
}

struct HomeCards: View {
    var items: [MediaItem]
    var title: String
    var type: String
    
    @Binding var isShowing: Bool
    @Binding var message: String
    
    @State var inWatchlist: [Bool] = Array(repeating: false, count: 30)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title2).bold()
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 30) {
                    ForEach(0..<items.count) { i in
                        NavigationLink(destination: DetailView(detailData: DetailData(itemID: items[i].itemID, type: type, imgPath: items[i].imgPath))) {
                            VStack {
                                if items[i].imgPath == "N/A" {
                                    Image("movie_placeholder").resizable()
                                        .clipped().frame(width:100, height:150)
                                        .cornerRadius(10)
                                } else {
                                    RemoteImage(url: items[i].imgPath)
                                        .clipped().frame(width:100, height:150)
                                        .cornerRadius(10)
                                }
                                
                                Text(items[i].name)
                                    .font(.caption).fontWeight(.heavy)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                
                                Text("("+items[i].date+")")
                                    .font(.caption).bold()
                                    .foregroundColor(.secondary)
                            }
                        
                        }.buttonStyle(PlainButtonStyle())
                        .frame(width:100)
                        .background(Color.white)
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .contextMenu(menuItems: {
                            
                            Button {
                                let item = items[i]
                                self.message = item.name+" was "
                                self.message += inWatchlist[i] ? "removed from Watchlist" : "added to Watchlist"
                                self.isShowing = true
                                if inWatchlist[i] {
                                    Storage.removeItem(item: [item.itemID, type, item.imgPath])
                                } else {
                                    Storage.storeItem(item: [item.itemID, type, item.imgPath])
                                }
                                inWatchlist[i].toggle()
                                if self.isShowing {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                          withAnimation {
                                            self.isShowing = false
                                          }
                                        }
                                }
                                
                            } label: {
                                if inWatchlist[i] {
                                    Label("Remove from watchList", systemImage:"bookmark.fill")
                                } else {
                                    Label("Add to watchList", systemImage:"bookmark")
                                }
                            }
                            
                            let link = "https://www.themoviedb.org/"+type+"/"+items[i].itemID
                            let fbLink =  ("https://www.facebook.com/sharer/sharer.php?u="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            
                            let twLink = ("https://twitter.com/intent/tweet?text=Check out this link: &hashtags=CSCI571USCFilms&url="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            
                            Link(destination: URL(string: fbLink)!, label: {Label("Share on Facebook", image: "facebook")})
                            
                            Link(destination: URL(string: twLink)!, label: {Label("Share on Twitter", image: "twitter")})
                           
                            
                            
                        })
                    }
                }.padding(.bottom)
            }.onAppear {
                for i in 0..<items.count {
                    inWatchlist[i] = Storage.inList(item: [items[i].itemID, type, items[i].imgPath])
                }
            }
        }
    }
}

struct HomeCarouselView: View {
    var items: [MediaItem]
    var category: String
    
    var body: some View {
        GeometryReader { geometry in
            ImageCarouselView(numberOfImages: items.count) {
                ForEach(items) { item in
                    NavigationLink(destination: DetailView(detailData: DetailData(itemID: item.itemID, type: category, imgPath: item.imgPath))) {
                        ZStack {
                            if item.imgPath == "N/A" {
                                Image("movie_placeholder").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width,//358
                                           height: 300)
                                    .clipped()
                                    .blur(radius: 50, opaque: true)
                                Image("movie_placeholder").resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                RemoteImage(url: item.imgPath)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width,//358
                                           height: 300)
                                    .clipped()
                                    .blur(radius: 50, opaque: true)
                                RemoteImage(url: item.imgPath)
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                        }
                    }
                }
            }
        }.frame(height: 300, alignment: .center)
        
    }
}

struct ImageCarouselView<Content: View>: View {
    private var numberOfImages: Int
    private var content: Content

    @State private var currentIndex: Int = 0
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    init(numberOfImages: Int, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
            .animation(.spring())
            .onReceive(self.timer) { _ in
                
                self.currentIndex = (self.currentIndex + 1) % self.numberOfImages
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
