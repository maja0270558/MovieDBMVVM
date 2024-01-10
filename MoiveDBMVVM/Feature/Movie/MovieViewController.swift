//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import UIKit

enum MovieListCategory: Int, CaseIterable {
    case popular
    case upcomming
    case nowPlaying
    
    var title: String {
        switch self {
        case .popular:
            return "Popular"
        case .upcomming:
            return "Upcomming"
        case .nowPlaying:
            return "Now playing"
        }
    }
}

class MovieViewController: UIViewController {
    let initCategory: MovieListCategory = .popular
    
    let segmented: UISegmentedControl = {
        let segmented = UISegmentedControl(items: MovieListCategory.allCases.map { $0.title })
        segmented.backgroundColor = .white
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        return tableView
    }()
    
    var viewModel: MovieViewModel!
    var cancelables: Set<AnyCancellable> = .init()
    
    init(viewModel: MovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.loadMovie(category: initCategory)
        binding()
    }
 
    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(segmented)
        segmented.autoLayout.pinTopToSafeArea()
        segmented.autoLayout.pinHorizontalEdgesToSuperView()
        segmented.autoLayout.equalHeight(constant: 40)
        tableView.autoLayout.fillSuperview()
    }
    
    func binding() {
        segmented.publisher(for: \.selectedSegmentIndex)
            .compactMap { MovieListCategory(rawValue: $0) }
            .sink { [weak self] cate in
                guard let self = self else { return }
                self.viewModel.input.switchSegement(category: cate)
            }
            .store(in: &cancelables)
        
        viewModel.output.movies
            .receive(on: DispatchQueue.main)
            .sink { result in
                print(result)
            }
            .store(in: &cancelables)
        
        viewModel.output.alertMessage?
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { _ in
            }
            .store(in: &cancelables)
    }
}
