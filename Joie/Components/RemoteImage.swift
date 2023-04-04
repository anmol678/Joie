//
//  RemoteImage.swift
//  Joie
//
//  Created by Anmol Jain on 4/3/23.
//

import SwiftUI
import Combine

struct RemoteImage: View {
    @StateObject private var imageLoader = ImageLoader()

    let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            imageLoader.load(url: url)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    func load(url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
            }
    }

    deinit {
        cancellable?.cancel()
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: URL(string: "https://www.ycombinator.com/packs/static/ycdc/ycombinator-logo-ee6c80faf1d1ce2491d8.png")!)
    }
}
