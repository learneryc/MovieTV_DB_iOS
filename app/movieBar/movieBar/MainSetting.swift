//
//  MainSetting.swift
//  movieBar
//

import Foundation

class MainSetting {
    static var url="http://localhost:8080/"
}

struct MediaItem: Identifiable {
    var id = UUID()
    
    var itemID: String
    var name: String
    var date: String
    var imgPath: String
}
