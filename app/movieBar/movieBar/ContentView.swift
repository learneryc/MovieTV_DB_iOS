//
//  ContentView.swift
//  movieBar
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    var body: some View {
        TabView(selection: $selection){
            SearchView().tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }.tag(2)
            
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }.tag(1)
            
            WatchlistView().tabItem {
                Label("WatchList", systemImage: "heart")
            }.tag(3)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
