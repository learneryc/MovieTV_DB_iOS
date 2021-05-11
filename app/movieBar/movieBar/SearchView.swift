//
//  SearchView.swift
//  movieBar
//

import SwiftUI

struct SearchView: View {
    @State var text: String = ""
    @ObservedObject var searchData: SearchData = SearchData()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $text, searchData: self.searchData)
                
                if self.text.count>=3 && searchData.searchItemsReady {
                    if searchData.searchItems.count>0 {
                        ScrollView {
                            ForEach(searchData.searchItems) { item in
                                NavigationLink(destination: DetailView(detailData: DetailData(itemID: item.itemID, type: item.type, imgPath: item.posterPath))) {
                                    SearchCard(item: item)
                                    
                                }.padding(3)
                            }
                        }.padding(.horizontal)
                    } else {
                        Text("No Results").font(.title).foregroundColor(.gray).padding()
                    }
                }
                Spacer()
            }.navigationBarTitle("Search")
        }
        
    }
}

struct SearchCard: View {
    var item: SearchItem
    
    var body: some View {
            RemoteImage(url: item.backdropPath)
                .aspectRatio(contentMode: .fill)
                .frame(height:180)
                .cornerRadius(10)
                .overlay(
                    VStack {
                        HStack {
                            Text((item.type=="movie" ? "MOVIE(" : "TV(") + item.date + ")")
                                .foregroundColor(.white).fontWeight(.bold)
                            HStack{
                                Spacer()
                                Image(systemName: "star.fill").foregroundColor(.red)
                                Text(item.rating).foregroundColor(.white).fontWeight(.bold)
                            }
                        }
                        Spacer()
                        HStack {
                            Text(item.name).font(.title3).foregroundColor(.white).fontWeight(.bold)
                            Spacer()
                        }
                    }.padding())
        
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    @ObservedObject var searchData: SearchData

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        @ObservedObject var searchData: SearchData
        let debouncer = Debouncer(delay: 0.5)

        init(text: Binding<String>, searchData: SearchData) {
            _text = text
            self.searchData = searchData
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.text = searchText
            if (self.text.count >= 3) {
                self.searchData.searchItemsReady = false
                self.debouncer.run(action: {
                    self.searchData.search(query: self.text)
                })
            }
        }
        
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.text = ""
            searchBar.endEditing(true)
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, searchData: searchData)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Movies, TVs..."
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
