//
//  DetailView.swift
//  movieBar
//

import SwiftUI
import youtube_ios_player_helper

struct DetailView: View {
    
    @ObservedObject var detailData: DetailData
    @State var inWatchlist: Bool = false
    @State var isShowing: Bool = false
    @State var message: String = ""
    
    var body: some View {
        if detailData.videoReady && detailData.mediaDetailReady && detailData.castDetailReady
            && detailData.reviewsReady && detailData.recommendReady {
            ScrollView {
                if detailData.videoPath != "tzkWB85ULJY" {
                    PlayerView(videoPath: NSMutableAttributedString(string: detailData.videoPath)).frame(height: 200)
                }
                
                VStack(alignment: .leading) {
                    Text(detailData.mediaDetail.name).font(.title).bold()
                    Text(detailData.mediaDetail.date+" | "+detailData.mediaDetail.genres).padding(.vertical, 5)
                    HStack{
                        Image(systemName: "star.fill").foregroundColor(.red)
                        Text(detailData.mediaDetail.rating)
                        Spacer()
                    }
                    LongText(detailData.mediaDetail.description).padding(.top, 5).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    
                    if detailData.castDetail.count>0 {
                        Text("Cast & Crew").font(.title2).bold().padding(.top, 15).padding(.bottom, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(detailData.castDetail) { cast in
                                    VStack {
                                        if cast.pic == "N/A" {
                                            Image("cast_placeholder").resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipShape(Circle())
                                                .frame(width: 90, height: 100)
                                        } else {
                                            RemoteImage(url: cast.pic)
                                                .aspectRatio(contentMode: .fill)
                                                .clipShape(Circle())
                                                .frame(width: 90, height: 100)
                                        }
                                        
                                        Text(cast.name).font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    if detailData.reviews.count>0 {
                        Text("Reviews").font(.title2).bold().padding(.top, 15)
                        ForEach(detailData.reviews) {review in
                            NavigationLink(
                                destination: ReviewView(review: review, title: detailData.mediaDetail.name)) {
                                ReviewItem(review: review).padding(.bottom, 1)
                            } .buttonStyle(PlainButtonStyle())
                            
                        }
                    }
                    
                    
                    if detailData.recommend.count>0 {
                        Text(detailData.type=="movie" ? "Recommended Movies" : "Recommended TV Shows").font(.title2).bold().padding(.top, 15)
                        
                        ScrollView(.horizontal, showsIndicators:false){
                            HStack{
                                ForEach(detailData.recommend){rec in
                                    NavigationLink(destination: DetailView(detailData: DetailData(itemID: rec.itemID, type: detailData.type, imgPath: rec.imgPath))) {
                                        
                                        if rec.imgPath != "N/A" {
                                            RemoteImage(url: rec.imgPath)
                                                .clipped()
                                                .frame(width: 100, height: 150).cornerRadius(10)
                                                .padding(.horizontal)
                                        } else {
                                            Image("movie_placeholder").resizable()
                                                .clipped()
                                                .frame(width: 100, height: 150).cornerRadius(10)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
                
            }.padding(.horizontal).padding(.bottom)
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            self.toggleWatchlist()
                            if self.isShowing {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                      withAnimation {
                                        self.isShowing = false
                                      }
                                    }
                            }
                        }) {
                            if inWatchlist {
                                Image(systemName: "bookmark.fill")
                            } else {
                                Image(systemName: "bookmark").foregroundColor(.black)
                            }
                            
                        }
                        
                        let link = "https://www.themoviedb.org/"+detailData.type+"/"+detailData.itemID
                        
                        let fbLink =  ("https://www.facebook.com/sharer/sharer.php?u="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                        
                        let twLink = ("https://twitter.com/intent/tweet?text=Check out this link: &hashtags=CSCI571USCFilms&url="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                        
                        Link(destination: URL(string: fbLink)!) {
                            Image("facebook").resizable().aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width:20, height:20)
                        }
                        
                        Link(destination: URL(string: twLink)!) {
                            Image("twitter").resizable().aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width:20, height:20)
                        }
                        /*Button(action: {
                            let shareLink = ("https://www.facebook.com/sharer/sharer.php?u="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            openURL(URL(string: shareLink)!)
                        }) {
                            Image("facebook").resizable().aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width:20, height:20)
                        }
                        
                        Button(action: {
                            let shareLink = ("https://twitter.com/intent/tweet?text=Check out this link: &hashtags=CSCI571USCFilms&url="+link).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            openURL(URL(string: shareLink)!)
                        }) {
                            Image("twitter").resizable().aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width:20, height:20)
                        }*/
                    })
                    .onAppear {
                        self.inWatchlist = Storage.inList(item: [detailData.itemID, detailData.type, detailData.imgPath])
            }
            .toast(isShowing: self.$isShowing, text: Text(self.message))
            
        } else {
            ProgressView("Fetching Data...").progressViewStyle(CircularProgressViewStyle())
        }
        
        
    }
    
    func toggleWatchlist () {
        self.message = detailData.mediaDetail.name+" was "
        self.message += inWatchlist ? "removed from Watchlist" : "added to Watchlist"
        self.isShowing = true
        if inWatchlist {
            Storage.removeItem(item: [detailData.itemID, detailData.type, detailData.imgPath])
        } else {
            Storage.storeItem(item: [detailData.itemID, detailData.type, detailData.imgPath])
        }
        self.inWatchlist.toggle()
    }
}

extension View {

    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}

struct PlayerView: UIViewRepresentable {
    @State var videoPath: NSMutableAttributedString

    func makeUIView(context: Context) -> UIView {
        let ytPlayer = YTPlayerView()
        debugPrint("!!!"+videoPath.string+"!!!")
        ytPlayer.load(withVideoId: videoPath.string, playerVars: ["playsinline": 1])
        return ytPlayer
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(detailData: DetailData(itemID: "527774", type:"movie", imgPath: "N/A"))
    }
}

struct LongText: View {

    /* Indicates whether the user want to see all the text or not. */
    @State private var expanded: Bool = false

    /* Indicates whether the text has been truncated in its display. */
    @State private var truncated: Bool = false

    private var text: String

    init(_ text: String) {
        self.text = text
    }

    private func determineTruncation(_ geometry: GeometryProxy) {
        // Calculate the bounding box we'd need to render the
        // text given the width from the GeometryReader.
        let total = self.text.boundingRect(
            with: CGSize(
                width: geometry.size.width,
                height: .greatestFiniteMagnitude
            ),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 15)],
            context: nil
        )

        if total.size.height > geometry.size.height {
            self.truncated = true
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(self.text)
                .font(.system(size: 15))
                .lineLimit(self.expanded ? nil : 3)
                // see https://swiftui-lab.com/geometryreader-to-the-rescue/,
                // and https://swiftui-lab.com/communicating-with-the-view-tree-part-1/
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        self.determineTruncation(geometry)
                    }
                })

            if self.truncated {
                self.toggleButton
            }
        }
    }

    var toggleButton: some View {
        HStack {
            Spacer()
            Button(action: { self.expanded.toggle() }) {
                Text(self.expanded ? "Show less" : "Show more..").foregroundColor(.secondary).fontWeight(.semibold)
            }
        }
    }

}

struct ReviewItem: View {
    var review: Review
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("A review by "+review.author).font(.headline).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Text("Written by "+review.author+" on "+review.date)
                    .font(.subheadline).foregroundColor(.secondary)
                HStack{
                    Image(systemName: "star.fill").foregroundColor(.red)
                    Text(review.rating)
                    Spacer()
                }.padding(.vertical, 3)
                Text(review.content).lineLimit(3).font(.subheadline)
            }.padding(10)
            
        }.overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
