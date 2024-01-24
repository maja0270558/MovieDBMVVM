//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import UIKit

class MovieViewController: UIViewController {
    enum MovieListSection: Int {
        case list
    }
    
    let collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    var viewModel: MovieViewModel!
    var cancelables: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()
    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MovieList.Movie>()

    init(viewModel: MovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        viewModel.input.loadMovie()
        binding()
    }
 
    func setupLayout() {
        view.addSubview(collectionView)
        collectionView.autoLayout.fillSuperview()
        collectionView.dataSource = dataSource
    }
    
    func binding() {
        viewModel.output.movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.sectionSnapshot.deleteAll()
                self.sectionSnapshot.append(result)
                self.dataSource.apply(
                    self.sectionSnapshot,
                    to: MovieListSection.list,
                    animatingDifferences: true,
                    completion: nil)
            }
            .store(in: &cancelables)
        
        viewModel.output.alertMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alertMessage in
                guard let self = self else { return }
                let alertController = UIViewController()
                let message = UILabel()
                message.text = alertMessage
                alertController.view.addSubview(message)
                message.autoLayout.fillSuperview()
                if let sheet = alertController.sheetPresentationController {
                    sheet.detents = [.medium()]
                }
                self.present(alertController, animated: true)
            }
            .store(in: &cancelables)
    }
    
    func configureRefreshControl() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(
            self, action:
            #selector(handleRefreshControl),
            for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        viewModel.input.reload()
        collectionView.refreshControl?.endRefreshing()
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<MovieListSection, MovieList.Movie> {
        let nib = UINib(nibName: "MovieCell", bundle: nil)
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, MovieList.Movie>.init(cellNib: nib) { cell, _, item in
            cell.configure(model: item)
        }
            
        return UICollectionViewDiffableDataSource<MovieListSection, MovieList.Movie>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item)
                return cell
            })
    }
}
