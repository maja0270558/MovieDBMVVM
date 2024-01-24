//
//  MovieCell.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import UIKit
import Dependencies

struct MovieCellViewModel: Equatable, Hashable {
    var uuid = UUID()
    var title: String
    var image: String
    var overview: String
}

class MovieCell: UICollectionViewCell {

    @Dependency(\.imageFetcher) var imageLoader
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!

    func configure(model: MovieCellViewModel) {
        image.layer.cornerRadius = 8
        title.text = model.title
        overview.text = model.overview
        imageLoader.loadImage(model.image, image)
    }

}
