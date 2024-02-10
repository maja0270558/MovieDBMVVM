//
//  MovieCell.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import Dependencies
import UIKit

class MovieCell: UICollectionViewCell {
    @Dependency(\.imageFetcher) var imageLoader
    @IBOutlet var overview: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var image: UIImageView!

    func configure(model: MovieCellViewModel) {
        image.layer.cornerRadius = 8
        title.text = model.title
        overview.text = model.overview
        imageLoader.loadImage(model.image, image)
    }
}
