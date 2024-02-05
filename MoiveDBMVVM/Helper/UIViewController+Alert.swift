//
//  UIViewController+alert.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/24.
//

import Foundation
import UIKit

extension UIViewController {
    @discardableResult
    func showAlert(alertMessage: String) -> UIViewController? {
        let controller = UIViewController()
        controller.view.backgroundColor = .white
        
        let image = {
            let image = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
            image.tintColor = .darkGray
            return image
        }()
        
        let message = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 12)
            label.text = alertMessage
            label.textAlignment = .center
            return label
        }()
        
        let stackView = {
            let stack = UIStackView()
            stack.spacing = 4
            stack.axis = .horizontal
            stack.addArrangedSubview(image)
            stack.addArrangedSubview(message)
            return stack
        }()
     
        image.autoLayout.equalWidth(constant: 30)
        image.autoLayout.equalHeight(constant: 30)
        
        controller.view.addSubview(stackView)
        stackView.autoLayout.centerVertically()
        stackView.autoLayout.centerHorizontally()
        
        if let sheetPresentationController = controller.sheetPresentationController {
            sheetPresentationController.largestUndimmedDetentIdentifier = .medium
            sheetPresentationController.detents = [
                .custom(resolver: { _ in
                    200
                })
            ]
        }
        self.present(controller, animated: true)
        return controller
    }
}
