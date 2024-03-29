//
//  UIView+autolayout.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/3.
//

import Foundation
import UIKit

struct Layout {
    let element: UIView
    
    init(_ element: UIView) {
        self.element = element
    }
    
    @discardableResult func equalWidth(constant: CGFloat, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: element,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .width,
                                                 multiplier: multiplier,
                                                 constant: constant)

        safeSuperview().addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult func equalWidthWithSuperView(constant: CGFloat, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: element,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: safeSuperview(),
                                                 attribute: .width,
                                                 multiplier: multiplier,
                                                 constant: constant)
        
        safeSuperview().addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult func equalHeight(constant: CGFloat, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: element,
                                                 attribute: .height,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .height,
                                                 multiplier: multiplier,
                                                 constant: constant)
        
        safeSuperview().addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult func equalHeightWithSuperView(constant: CGFloat, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint(item: element,
                                                 attribute: .height,
                                                 relatedBy: .equal,
                                                 toItem: safeSuperview(),
                                                 attribute: .height,
                                                 multiplier: multiplier,
                                                 constant: constant)
        
        safeSuperview().addConstraint(widthConstraint)
        return widthConstraint
    }
    
    @discardableResult func pinHorizontalEdgesToSuperView(padding: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[view]-(padding)-|",
                                                         options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                         metrics: ["padding": padding],
                                                         views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func pinVerticalEdgesToSuperView(padding: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(padding)-[view]-(padding)-|",
                                                         options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                         metrics: ["padding": padding],
                                                         views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func centerVertically(_ multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerY,
                                            multiplier: multiplier, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func centerHorizontally(_ multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerX,
                                            multiplier: multiplier, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinLeadingToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .leading,
                                            multiplier: 1, constant: constant)
        
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTrailingToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .trailing,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    enum SafeAreaAnchor {
        case top
        case bottom
    }
    
    @discardableResult func pinTopToSafeArea(constant: CGFloat = 0,
                                             anchor: SafeAreaAnchor = .top) -> NSLayoutConstraint
    {
        let guide = safeSuperview().safeAreaLayoutGuide
        
        var equalTo: NSLayoutYAxisAnchor
        switch anchor {
        case .top:
            equalTo = guide.topAnchor
        case .bottom:
            equalTo = guide.bottomAnchor
        }
        
        let constraint = element.topAnchor.constraint(equalTo: equalTo, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTopToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTopToView(view: UIView, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pin(view: UIView,
                                constant: CGFloat,
                                from: NSLayoutConstraint.Attribute,
                                to: NSLayoutConstraint.Attribute) -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: from,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: to,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinBottomToSafeArea(constant: CGFloat = 0,
                                                anchor: SafeAreaAnchor = .bottom) -> NSLayoutConstraint
    {
        let guide = safeSuperview().safeAreaLayoutGuide
        var equalTo: NSLayoutYAxisAnchor
        switch anchor {
        case .top:
            equalTo = guide.topAnchor
        case .bottom:
            equalTo = guide.bottomAnchor
        }
        let constraint = element.bottomAnchor.constraint(equalTo: equalTo, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinBottomToViewTop(view: UIView, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }

    @discardableResult func pinBottomToView(view: UIView, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    func fillSuperview(padding: CGFloat = 0) {
        safeSuperview()
        pinHorizontalEdgesToSuperView(padding: padding)
        pinVerticalEdgesToSuperView(padding: padding)
    }
    
    @discardableResult private func safeSuperview() -> UIView {
        element.translatesAutoresizingMaskIntoConstraints = false
        guard let view = element.superview else {
            fatalError("You need to have a superview before you can add contraints")
        }
        return view
    }
}

extension UIView {
    var autoLayout: Layout {
        return Layout(self)
    }
}
