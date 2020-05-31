//
//  OnBoardingViewController.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 29/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func didPressReady(_ sender: Any) {
        Model.instance.notFirstLaunch = true
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBar") as? UITabBarController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
