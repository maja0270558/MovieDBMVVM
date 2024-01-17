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
        title.text = model.title
        overview.text = model.overview
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
