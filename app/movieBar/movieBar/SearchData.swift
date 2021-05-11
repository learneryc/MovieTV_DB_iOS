//
//  SearchData.swift
//  movieBar
//

import Foundation
import SwiftyJSON
import Alamofire

class SearchData: ObservableObject {
    @Published var searchItems: [SearchItem]=[]
    @Published var searchItemsReady: Bool=false
    
    var url=MainSetting.url
    
    func search(query: String) {
        let queryURL = (url+"search/"+query).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        AF.request(queryURL, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    let results = JSON(value)["results"].arrayValue
                    self.searchItems = []
                    for res in results {
                        let item = SearchItem(itemID: res["id"].stringValue,
                                              name: res["name"].stringValue,
                                              type: res["media_type"].stringValue,
                                              rating: res["vote_average"].stringValue == "N/A" ? "N/A" : String(format: "%.1f", res["vote_average"].doubleValue/2),
                                              date: res["release_date"].stringValue == "N/A" ? "N/A" : String(res["release_date"].stringValue.prefix(4)),
                                              backdropPath: res["backdrop_path"].stringValue,
                                              posterPath: res["poster_path"].stringValue)
                        if (item.backdropPath != "N/A") {
                            self.searchItems.append(item)
                        }
                        
                    }
                    
                    self.searchItemsReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
        
    }
    
}

struct SearchItem: Identifiable {
    var id = UUID()
    
    var itemID: String
    var name: String
    var type: String
    var rating: String
    var date: String
    var backdropPath: String
    var posterPath: String
}
