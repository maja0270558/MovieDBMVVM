//
//  MovieViewController.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import UIKit

class MovieViewController: UIViewController {
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
            .sink { result in
                self.sectionSnapshot.deleteAll()
                self.sectionSnapshot.append(result)
                self.dataSource.apply(self.sectionSnapshot, to: "Root", animatingDifferences: true, completion: nil)
            }
            .store(in: &cancelables)
        
        viewModel.output.alertMessage?
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { _ in
            }
            .store(in: &cancelables)
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<String, MovieList.Movie> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MovieList.Movie> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.indentationLevel = 2
            cell.contentConfiguration = content
        }
            
        return UICollectionViewDiffableDataSource<String, MovieList.Movie>(
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
