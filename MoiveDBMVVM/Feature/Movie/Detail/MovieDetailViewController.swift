//
//  MovieDetailViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import UIKit
import Dependencies
import Combine

class MovieDetailViewController: UIViewController {
    
    @Dependency(\.imageFetcher) var imageLoader
    @Dependency(\.mainQueue) var queue
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var language: UILabel!
    
    let viewModel: MovieDetailViewModel
    private(set) var cancellables: Set<AnyCancellable> = .init()
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.input.viewDidLoad()
    }
    
    func bind() {
        viewModel.output.$detail
            .receive(on: queue)
            .sink { [weak self] value in
                guard let self = self else { return }
                guard let detail = value else { return }
                self.releaseDate.text = detail.releaseDate
                self.popularity.text = "\(detail.popularity)"
                self.language.text = detail.originalLanguage
                self.titleLabel.text = detail.originalTitle
                self.imageLoader.loadImage(detail.backdropPath, self.image)
                self.overview.text = detail.overview
            }
            .store(in: &cancellables)
        
    }
}
