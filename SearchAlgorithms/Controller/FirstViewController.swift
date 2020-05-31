//
//  FirstViewController.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 24/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import UIKit
import SpriteKit

class FirstViewController: UIViewController {

    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            scene = SKScene(fileNamed: "GameScene") as? GameScene
            scene.firstViewController = self
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        
    }

    func showSettingsPopUp() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

