//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import UIKit
import Combine

class MovieViewController: UIViewController {
    var viewModel = MovieViewModel()
    var cancelables: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.viewDidLoad()
        binding()
    }
    
    func binding() {
        viewModel.output.movies
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { result in
               print(result)
            }
            .store(in: &cancelables)
        
        viewModel.output.alertMessage?
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { result in
               print(result)
            }
            .store(in: &cancelables)
    }
}
