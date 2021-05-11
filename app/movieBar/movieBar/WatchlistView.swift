//
//  WatchlistView.swift
//  movieBar
//

import SwiftUI

struct WatchlistView: View {
    @ObservedObject var watchlistData: WatchlistData = WatchlistData()
    let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    var body: some View {
        
        NavigationView {
            if watchlistData.watchlistItems.count == 0 {
                Text("Watchlist is empty").font(.title).foregroundColor(.gray)
                    .onAppear {
                    watchlistData.getWatchlist()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(watchlistData.watchlistItems) { item in
                            NavigationLink(destination: DetailView(detailData: DetailData(itemID: item.itemID, type: item.type, imgPath: item.imgPath))) {
                                
                                if item.imgPath == "N/A" {
                                    Image("movie_placeholder").resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    //KFImage(URL(string: item.imgPath)).resizable()
                                    watchlistRemoteImage(url: item.imgPath)
                                        .aspectRatio(contentMode: .fit)
                                        
                                }
                                
                            }.contextMenu(menuItems: {
                                Button {
                                    Storage.removeItem(item: [item.itemID, item.type, item.imgPath])
                                    watchlistData.getWatchlist()
                                } label: {
                                    Label("Remove from watchList", systemImage:"bookmark.fill")
                                }
                                
                            })
                            .onDrag({
                                watchlistData.curItem = item
                                return NSItemProvider(contentsOf: URL(string: item.itemID))!
                            })
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: item, watchlistData: watchlistData))
                            .highPriorityGesture(DragGesture.init())
                           
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitle("Watchlist")
                .onAppear {
                    watchlistData.getWatchlist()
                }
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    var item: StorageItem
    var watchlistData: WatchlistData
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        let fromIndex = watchlistData.watchlistItems.firstIndex {(item) -> Bool in
            return item.itemID==watchlistData.curItem?.itemID && item.type==watchlistData.curItem?.type
        } ?? 0
        
        let toIndex = watchlistData.watchlistItems.firstIndex {(item) -> Bool in
            return item.itemID==self.item.itemID && item.type==self.item.type
        } ?? 0
        
        if fromIndex != toIndex {
            let fromItem = watchlistData.watchlistItems[fromIndex]
            watchlistData.watchlistItems[fromIndex] = watchlistData.watchlistItems[toIndex]
            watchlistData.watchlistItems[toIndex] = fromItem
            Storage.swapItems(from: fromIndex, to: toIndex)
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView(watchlistData: WatchlistData())
    }
}
