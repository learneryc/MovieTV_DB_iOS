//
//  WatchlistData.swift
//  movieBar
//

import Foundation

class WatchlistData: ObservableObject {
    @Published var watchlistItems: [StorageItem] = []
    @Published var curItem: StorageItem?
    
    init() {
        self.getWatchlist()
    }
    
    func getWatchlist() {
        let items = Storage.getItems()
        watchlistItems = []
        for item in items {
            let watchlistItem = StorageItem(itemID: item[0], type: item[1], imgPath: item[2])
            self.watchlistItems.append(watchlistItem)
        }
    }
}
