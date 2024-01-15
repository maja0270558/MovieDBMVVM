//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import UIKit

class MovieViewController: UIViewController {
    
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
        viewModel.input.loadMovie()
        binding()
    }
 
    func setupLayout() {
        view.addSubview(tableView)
        tableView.autoLayout.fillSuperview()
    }
    
    func binding() {
      
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
//    
//    func makeDataSource() -> UITableViewDiffableDataSource<<#SectionIdentifierType: Hashable & Sendable#>, <#ItemIdentifierType: Hashable & Sendable#>> {
//        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
//            
//        }
//    }
}
