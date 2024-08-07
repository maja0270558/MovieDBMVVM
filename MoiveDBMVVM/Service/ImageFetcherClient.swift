//
//  ImageProvider.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import UIKit
import Nuke
import NukeExtensions

public struct ImageFetcherClient {
    var loadImage: @MainActor (String, UIImageView) -> Void
}

extension ImageFetcherClient {
    static let live: Self = .init { url, imageView in
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
            transition: .fadeIn(duration: 0.33)
        )
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(url)")
        let request = ImageRequest(url: url)
        NukeExtensions.loadImage(with: request, options: options, into: imageView)
    }
    
    static let fake: Self = .init { url, imageView in
        imageView.image = UIImage()
    }
}
