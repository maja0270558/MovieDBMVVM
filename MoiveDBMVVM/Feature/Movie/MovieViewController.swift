//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import UIKit

class MovieViewController: UIViewController {
    let segmented = UISegmentedControl()
    let tableView = UITableView()
    var viewModel = MovieViewModel()
    var cancelables: Set<AnyCancellable> = .init()
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.viewDidLoad()
        binding()
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(segmented)
        segmented.backgroundColor = .black
        tableView.backgroundColor = .black
        
        segmented.autoLayout.pinTopToSafeArea()
        segmented.autoLayout.pinHorizontalEdgesToSuperView()
        segmented.autoLayout.equalHeight(constant: 60)
        tableView.autoLayout.fillSuperview()
        
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
