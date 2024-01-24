//
//  ImageProvider.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import UIKit
import Nuke
import NukeExtensions

public struct ImageFetcher {
    var loadImage: @MainActor (String, UIImageView) -> Void
}

extension ImageFetcher {
    static let live: Self = .init { url, imageView in
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
            transition: .fadeIn(duration: 0.33)
        )
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(url)")
        let request = ImageRequest(url: url)
        NukeExtensions.loadImage(with: request, options: options, into: imageView)
    }
    
    static let mock: Self = .init { url, imageView in
        imageView.image = UIImage()
    }
}
