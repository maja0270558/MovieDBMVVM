//
//  MovieCell.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import UIKit
import Dependencies

class MovieCell: UICollectionViewCell {

    @Dependency(\.imageFetcher) var imageLoader
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!

    func configure(model: MovieList.Movie) {
        image.layer.cornerRadius = 8
        title.text = model.title
        overview.text = model.overview
        imageLoader.loadImage(model.backdropPath ?? "", image)
    }

}
