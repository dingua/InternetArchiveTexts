//
//  IALoadingViewProtocol.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/1/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

protocol IALoadingViewProtocol {
    var activityIndicatorView: DGActivityIndicatorView? {get set}
    func addLoadingView(xOffset: CGFloat, yOffset: CGFloat)
    func removeLoadingView()
}

extension IALoadingViewProtocol where Self: UIViewController {
    func addLoadingView(xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        if let activityIndicatorView = activityIndicatorView {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addConstraint(NSLayoutConstraint(item: activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: xOffset))
            
            self.view.addConstraint(NSLayoutConstraint(item:  activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: yOffset))
        }
    }

    func removeLoadingView() {
        if let activityIndicatorView = activityIndicatorView {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }
    
}