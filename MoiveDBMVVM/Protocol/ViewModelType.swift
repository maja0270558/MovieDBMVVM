//
//  ViewModelType.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/15.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}
