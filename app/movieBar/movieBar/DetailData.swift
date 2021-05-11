//
//  DetailData.swift
//  movieBar
//

import Foundation
import SwiftyJSON
import Alamofire

class DetailData: ObservableObject {
    var url=MainSetting.url
    
    var itemID: String
    var type: String
    var imgPath: String
    
    @Published var videoPath: String="tzkWB85ULJY"
    @Published var videoReady: Bool=false
    @Published var mediaDetail: MediaDetail
    @Published var mediaDetailReady: Bool=false
    @Published var castDetail: [CastDetail]=[]
    @Published var castDetailReady: Bool=false
    @Published var reviews: [Review]=[]
    @Published var reviewsReady: Bool=false
    @Published var recommend: [Recommend]=[]
    @Published var recommendReady: Bool=false
    
    
    init (itemID: String, type: String, imgPath: String) {
        self.itemID = itemID
        self.type = type
        self.imgPath = imgPath
        
        self.mediaDetail = MediaDetail(name:"", date:"", genres:"", rating:"", description:"")
        self.getVideos()
        self.getMediaDetail()
        self.getCastDetail()
        self.getReviews()
        self.getRecommend()
    }
    
    func getVideos() {
        AF.request(self.url+"api/"+type+"/video/"+itemID, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    self.videoPath = JSON(value)["results"]["id"].stringValue
                    self.videoReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getMediaDetail() {
        AF.request(self.url+"api/"+type+"/detail/"+itemID, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    let results = JSON(value)["results"]
                    //let genreArr = results["genres"].arrayValue
                    var genres = ""
                    for g in results["genres"].arrayValue {
                        genres += g["name"].stringValue+", "
                    }
                    genres = genres=="" ? "N/A" : String(genres.dropLast(2))
                    
                    self.mediaDetail = MediaDetail (
                        name: results["name"].stringValue,
                        date: results["release_date"]=="N/A" ? "N/A" : String(results["release_date"].stringValue.prefix(4)),
                        genres: genres,
                        rating: results["vote_average"].stringValue == "N/A" ? "0.0/5.0" : String(format: "%.1f", results["vote_average"].doubleValue/2)+"/5.0",
                        description: results["overview"].stringValue )
                    self.mediaDetailReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getCastDetail() {
        AF.request(self.url+"api/"+type+"/cast/"+itemID, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    let results = JSON(value)["results"]
                    for c in results.arrayValue {
                        let cast = CastDetail(name: c["name"].stringValue, pic: c["profile_path"].stringValue)
                        self.castDetail.append(cast)
                        if (self.castDetail.count == 10) {
                            break
                        }
                    }
                    self.castDetailReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func getReviews() {
        AF.request(self.url+"api/"+type+"/review/"+itemID, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    let results = JSON(value)["results"]
                    for c in results.arrayValue {
                        let review = Review(author: c["author"].stringValue,
                                            date: c["created_at"].stringValue=="N/A" ? "N/A" : self.formatDate(str: c["created_at"].stringValue),
                                            rating: c["rating"].stringValue == "N/A" ? "0.0/5.0" : String(format: "%.1f", c["rating"].doubleValue/2)+"/5.0",
                                            content: c["content"].stringValue)
                        self.reviews.append(review)
                        if (self.reviews.count == 3) {
                            break
                        }
                    }
                    self.reviewsReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
    
    func formatDate(str: String)-> String {
        /*let months: JSON = ["01": "Jan", "02": "Feb", "03": "Mar",
                            "04": "Apr", "05": "May", "06":"Jun",
                            "07": "Jul", "08": "Aug", "09": "Sep",
                            "10": "Oct", "11": "Nov", "12": "Dec"]
        
        let arr = str.components(separatedBy: "-")
        let year = arr[0]
        let month = months[arr[1]].stringValue
        let day = arr[2].prefix(2)
        
        let date = month+" "+day+", "+year
        return date*/
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateObj = dateFormatter.date(from: String(str.prefix(10)))

        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: dateObj!)
    }
    
    func getRecommend() {
        AF.request(self.url+"api/"+type+"/recommend/"+itemID, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
                case .success(let value):
                    let results = JSON(value)["results"]
                    for r in results.arrayValue {
                        let rec = Recommend(itemID: r["id"].stringValue, imgPath: r["poster_path"].stringValue)
                        self.recommend.append(rec)
                    }
                    self.recommendReady = true
                case .failure(let error):
                    print(error)// do something with the error
            }
        }
    }
}

struct MediaDetail {
    var id = UUID()
    
    var name: String
    var date: String
    var genres: String
    var rating: String
    var description: String
}

struct CastDetail: Identifiable {
    var id = UUID()
    
    var name: String
    var pic: String
}

struct Review: Identifiable {
    var id = UUID()
    
    var author: String
    var date: String
    var rating: String
    var content: String
}

struct Recommend: Identifiable {
    var id = UUID()
    
    var itemID: String
    var imgPath: String
}
