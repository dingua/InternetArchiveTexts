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
    func addLoadingView()
    func removeLoadingView()
}

extension IALoadingViewProtocol where Self: UIViewController {
    func addLoadingView() {
        if let activityIndicatorView = activityIndicatorView {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addConstraint(NSLayoutConstraint(item: activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item:  activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: 0))
        }
    }
    
    func removeLoadingView() {
        if let activityIndicatorView = activityIndicatorView {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }
    
}