//
//  RemoteImage.swift
//  movieBar
//

import SwiftUI

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader

    var body: some View {
        if loader.state == LoadState.success {
            selectImage()
                .resizable()
        }
        
    }

    init(url: String) {
        _loader = StateObject(wrappedValue: Loader(url: url))
    }

    private func selectImage() -> Image {
        if let image = UIImage(data: loader.data) {
            return Image(uiImage: image)
        } else {
            return Image("movie_placeholder")
        }
    }
}

struct watchlistRemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader

    var body: some View {
        selectImage()
            .resizable()

    }

    init(url: String) {
        _loader = StateObject(wrappedValue: Loader(url: url))
    }

    private func selectImage() -> Image {
        if let image = UIImage(data: loader.data) {
            return Image(uiImage: image)
        } else {
            return Image("movie_placeholder")
        }
    }
}
