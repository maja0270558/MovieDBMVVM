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
        viewModel.output.$title
            .receive(on: queue)
            .sink { [weak self] value in
                self?.titleLabel.text = value
            }
            .store(in: &cancellables)
        
        viewModel.output.$image
            .receive(on: queue)
            .sink { [weak self] value in
                self?.imageLoader.loadImage(value ?? "", self!.image)
            }
            .store(in: &cancellables)
        
        viewModel.output.$overview
            .receive(on: queue)
            .sink { [weak self] value in
                self?.overview.text = value
            }
            .store(in: &cancellables)
    }

    
}
