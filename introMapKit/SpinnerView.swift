//
//  SpinnerView.swift
//  introMapKit
//
//  Created by Ios Dev on 25/07/2018.
//  Copyright © 2018 avchugunov. All rights reserved.
//

import Foundation
import UIKit

class SpinnerView {
    class func displaySpinner(onView view: UIView) -> UIView {
        let spinnerView = UIView(frame: view.frame)
        spinnerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        spinnerView.center = view.center
        let AI = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerView.addSubview(AI)
        AI.center = spinnerView.center
        AI.startAnimating()
        AI.hidesWhenStopped = true
        view.addSubview(spinnerView)
        
        return spinnerView
    }
    
    class func removeSpinnerView(spinner: UIView) {
        spinner.removeFromSuperview()
    }
}
