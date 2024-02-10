//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import Dependencies
import UIKit
class MovieViewController: UIViewController {
    @Dependency(\.mainQueue) var queue
    
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
    var cancellables: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()
    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MovieCellViewModel>()

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
        configureNavigationBar()
        configureRefreshControl()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        viewModel.input.loadMovie()
    }
    
    func binding() {
        viewModel.output.$movies
            .receive(on: queue)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.sectionSnapshot.deleteAll()
                self.sectionSnapshot.append(result)
                self.dataSource.apply(
                    self.sectionSnapshot,
                    to: MovieListSection.list,
                    animatingDifferences: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.alertMessage
            .compactMap { $0 }
            .receive(on: queue)
            .sink { [weak self] alertMessage in
                guard let self = self else { return }
                self.showAlert(alertMessage: alertMessage)
            }
            .store(in: &cancellables)
        
        viewModel.output.$isLoading
            .filter { !$0 }
            .receive(on: queue)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: &cancellables)
    }
    
    fileprivate func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Now playing"
        extendedLayoutIncludesOpaqueBars = true
    }
    
    fileprivate func setupLayout() {
        view.addSubview(collectionView)
        collectionView.autoLayout.fillSuperview()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    fileprivate func configureRefreshControl() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(
            self, action:
            #selector(handleRefreshControl),
            for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        viewModel.input.reload()
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<MovieListSection, MovieCellViewModel> {
        let nib = UINib(nibName: "MovieCell", bundle: nil)
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, MovieCellViewModel>.init(cellNib: nib) { cell, _, item in
            cell.configure(model: item)
        }
            
        return UICollectionViewDiffableDataSource<MovieListSection, MovieCellViewModel>(
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

extension MovieViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath)
    {
        if indexPath.row == sectionSnapshot.items.count - 1,
           viewModel.output.isLoading == false
        {
            viewModel.input.loadMovie()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        let vm = MovieDetailViewModel(movieId: selectedItem.id)
        let vc = MovieDetailViewController(viewModel: vm)
        self.show(vc, sender: self)
    }
}
