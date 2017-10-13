//
//  UIView+LayoutHelper.swift
//  SegmentedControl
//
//  Created by Николай Кагала on 14/03/2017.
//  Copyright © 2017 Николай Кагала. All rights reserved.
//

import UIKit

extension UIView {
    
    enum Orientation: String {
        case vertical = "V:"
        case horizontal = "H:"
        
        var opposed: Orientation {
            switch self {
            case .vertical: return .horizontal
            case .horizontal: return .vertical
            }
        }
    }
    
    func bindEdgesToSuperview(padding: CGFloat = 0.0) {
        bindEdgesToSuperview(padding: padding, orientation: .vertical)
        bindEdgesToSuperview(padding: padding, orientation: .horizontal)
    }
    
    func bindEdgesToSuperview(padding: CGFloat = 0.0, orientation: Orientation) {
        let format = "\(orientation.rawValue)|-padding-[self]-padding-|"
        superview!.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: format, options: .directionLeadingToTrailing, metrics: ["padding": padding], views: ["self": self])
        )
    }
    
    static func bindViewsSuccessively(views: [UIView], inSuperview superview: UIView, padding: CGFloat = 12.0, orientation: Orientation = .horizontal) {
        let metrics = ["padding": padding]
        for (index, view) in views.enumerated() {
            view.bindEdgesToSuperview(orientation: orientation.opposed)
            let format: String
            var viewsDict = ["view": view]
            if index == 0 {
                format = "\(orientation.rawValue)|-padding-[view]"
            } else if index == views.count - 1 {
                viewsDict["previous"] = views[index - 1]
                format = "\(orientation.rawValue)[previous]-padding-[view]-padding-|"
            } else {
                format = "\(orientation.rawValue)[previous]-padding-[view]"
                viewsDict["previous"] = views[index - 1]
            }
            superview.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: format,
                                               options: .directionLeadingToTrailing,
                                               metrics: metrics,
                                               views: viewsDict)
            )
        }
        superview.layoutIfNeeded()
    }
}
