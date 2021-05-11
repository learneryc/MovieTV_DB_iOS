//
//  Storage.swift
//  movieBar
//

import Foundation

class Storage {
    static var key = "watchlist"
    
    static func storeItem(item: [String]){
        let defaults = UserDefaults.standard
        var items = self.getItems()
        items.append(item)
        defaults.set(items, forKey: self.key)
    }
    
    static func removeItem(item: [String]){
        let defaults = UserDefaults.standard
        var items = self.getItems()
        for i in 0..<items.count {
            if items[i][0]==item[0] && items[i][1]==item[1] {
                items.remove(at: i)
                break
            }
        }
        
        defaults.set(items, forKey: self.key)
    }
    
    static func clearall() {
        let defaults = UserDefaults.standard
        defaults.set([], forKey: self.key)
    }
    
    static func getItems()-> [[String]] {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: self.key) as? [[String]] ?? [[String]]()
    }
    
    static func inList(item: [String])-> Bool {
        let items = self.getItems()
        for i in items {
            if i[0]==item[0] && i[1]==item[1] {
                return true
            }
        }
        return false
    }
    
    static func swapItems(from: Int, to: Int) {
        let defaults = UserDefaults.standard
        var items = self.getItems()
        let tmp = items[to]
        items[to] = items[from]
        items[from] = tmp
        
        defaults.set(items, forKey: self.key)
    }
}

struct StorageItem:Identifiable, Codable {
    var id = UUID()
    
    var itemID: String
    var type: String
    var imgPath: String
}
