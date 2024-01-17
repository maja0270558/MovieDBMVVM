//
//  MovieCell.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import UIKit

class MovieCell: UICollectionViewCell {

    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!

    func configure(model: MovieList.Movie) {
        image.layer.cornerRadius = 8
        title.text = model.title
        overview.text = model.overview
        Current.imageProvider.loadImage(model.backdropPath ?? "", image)
    }

}
