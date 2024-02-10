//
//  MovieCellViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import Foundation

struct MovieCellViewModel: Equatable, Hashable {
    var uuid = UUID()
    var title: String
    var image: String
    var overview: String
    var id: Int
}
