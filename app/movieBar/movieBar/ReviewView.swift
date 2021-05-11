//
//  ReviewView.swift
//  movieBar
//

import SwiftUI

struct ReviewView: View {
    var review: Review
    var title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(title).font(.title).bold()
                    Spacer()
                }
                
                Text("By "+review.author+" on "+review.date).foregroundColor(.secondary)
                    .padding(.vertical, 1)
                
                HStack{
                    Image(systemName: "star.fill").foregroundColor(.red)
                    Text(review.rating)
                    Spacer()
                }
                
                Divider()
                
                Text(review.content).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
            
            
        }.padding(.horizontal)
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(review: Review(author: "Jane", date: "Apr 30, 2021",
                                  rating: "4.3/5.0", content: "As pure popcorn entertainment and the culmination of the Monsterverse saga, 'Godzilla vs. Kong' delivers the goods in an unexpectedly big way. This film is essential viewing for those who might like to watch a lizard punch an ape. - Jake Watt Read Jake's full article... https://www.maketheswitch.com.au/article/review-godzilla-vs-kong-hugely-entertaining"),
                   title: "Raya and the last dragon")
    }
}
