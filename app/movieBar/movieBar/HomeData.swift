//
//  HomeData.swift
//  movieBar
//

import Foundation
import SwiftyJSON
import Alamofire

class HomeData: ObservableObject {
    var url=MainSetting.url
    
    @Published var nowPlayingMovies: [MediaItem]=[]
    @Published var trendingTVShows: [MediaItem]=[]
    @Published var nowPlayingMoviesReady: Bool=false
    @Published var trendingTVShowsReady: Bool=false
    
    @Published var topRatedMovies: [MediaItem]=[]
    @Published var topRatedTVShows: [MediaItem]=[]
    @Published var topRatedMoviesReady: Bool=false
    @Published var topRatedTVShowsReady: Bool=false
    
    @Published var popularMovies: [MediaItem]=[]
    @Published var popularTVShows: [MediaItem]=[]
    @Published var popularMoviesReady: Bool=false
    @Published var popularTVShowsReady: Bool=false
    
    init() {
        getNowPlayingMovies()
        getTrendingTVShows()
        getTopRatedMovies()
        getTopRatedTVShows()
        getPopularMovies()
        getPopularTVShows()
    }
    
    func transformData(results: JSON)-> [MediaItem] {
        var itemArr: [MediaItem]=[]
        for res in results["results"].arrayValue {
            let item = MediaItem(
                itemID: res["id"].stringValue,
                name: res["name"].stringValue,
                date: res["release_date"].stringValue=="N/A" ? "N/A" : String(res["release_date"].stringValue.prefix(4)),
                imgPath: res["poster_path"].stringValue
            )
            itemArr.append(item)
        }
        return itemArr
    }
    
    func getNowPlayingMovies() {
        AF.request(self.url+"api/movie/nowPlaying", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.nowPlayingMovies = self.transformData(results: JSON(value))
                    self.nowPlayingMoviesReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getTrendingTVShows() {
        AF.request(self.url+"api/tv/trending", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.trendingTVShows = self.transformData(results: JSON(value))
                    self.trendingTVShowsReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getTopRatedMovies() {
        AF.request(self.url+"api/movie/top", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.topRatedMovies = self.transformData(results: JSON(value))
                    self.topRatedMoviesReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getTopRatedTVShows() {
        AF.request(self.url+"api/tv/top", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.topRatedTVShows = self.transformData(results: JSON(value))
                    self.topRatedTVShowsReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getPopularMovies() {
        AF.request(self.url+"api/movie/popular", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.popularMovies = self.transformData(results: JSON(value))
                    self.popularMoviesReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getPopularTVShows() {
        AF.request(self.url+"api/tv/popular", encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.popularTVShows = self.transformData(results: JSON(value))
                    self.popularTVShowsReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
}
