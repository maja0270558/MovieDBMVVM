//
//  MovieDetailViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import UIKit

class MovieDetailViewController: UIViewController {

    let viewModel: MovieDetailViewModel

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

    }

    
}
