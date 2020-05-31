//
//  SettingsViewController.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 25/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var algorithmSegmented: UISegmentedControl!
    @IBOutlet weak var heuristicsSegmented: UISegmentedControl!
    @IBOutlet weak var diagonalCostStepper: UIStepper!
    @IBOutlet weak var speedStepper: UIStepper!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var diagonalCostLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var heuristicsTitle: UILabel!
    @IBOutlet weak var diagonalTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayouts()
        
        speedLabel.text = String(Model.instance.speed)
        speedStepper.value = Model.instance.speed
        diagonalCostLabel.text = String(Model.instance.diagDost)
        diagonalCostStepper.value = Model.instance.diagDost
        
        setSegmenteds()
        
        hideSettings()
    }
    
    func hideSettings() {
        if Model.instance.algorithm == "A-star" {
            heuristicsSegmented.isEnabled = true
            heuristicsTitle.alpha = 1.0
        } else {
            heuristicsSegmented.isEnabled = false
            heuristicsTitle.alpha = 0.5
        }
        
        if Model.instance.algorithm == "A-star" || Model.instance.algorithm == "Dijkstra" {
            diagonalCostStepper.isEnabled = true
            diagonalCostStepper.alpha = 1.0
            diagonalCostLabel.alpha = 1.0
            diagonalTitle.alpha = 1.0
        } else {
            diagonalCostStepper.isEnabled = false
            diagonalCostStepper.alpha = 0.5
            diagonalCostLabel.alpha = 0.5
            diagonalTitle.alpha = 0.5
        }
        
    }
    
    func setSegmenteds() {
        if Model.instance.algorithm == "A-star" {
            algorithmSegmented.selectedSegmentIndex = 0
        } else if Model.instance.algorithm == "Dijkstra" {
            algorithmSegmented.selectedSegmentIndex = 1
        } else if Model.instance.algorithm == "BFS" {
            algorithmSegmented.selectedSegmentIndex = 2
        }
        
        if Model.instance.heuristics == "Euclidean" {
            heuristicsSegmented.selectedSegmentIndex = 0
        } else if Model.instance.heuristics == "Manhattan" {
            heuristicsSegmented.selectedSegmentIndex = 1
        }
    }
    
    func setLayouts() {
        cardView.layer.cornerRadius = 15.0
        speedStepper.layer.cornerRadius = 5.0
        diagonalCostStepper.layer.cornerRadius = 5.0
        heuristicsSegmented.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.3)
        heuristicsSegmented.selectedSegmentTintColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        
        algorithmSegmented.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.3)
        algorithmSegmented.selectedSegmentTintColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        
        diagonalCostStepper.value = 1.5
        diagonalCostStepper.stepValue = 0.5
        diagonalCostStepper.maximumValue = 3.0
        diagonalCostStepper.minimumValue = 0.5
        speedStepper.stepValue = 0.5
        speedStepper.maximumValue = 5.0
        speedStepper.minimumValue = 0.5
        
    }
    
    
    @IBAction func didPressSpeedStepper(_ sender: Any) {
        speedLabel.text = String(speedStepper.value)
        Model.instance.speed = speedStepper.value
    }
    

    @IBAction func didPressDiagonalStepper(_ sender: Any) {
        diagonalCostLabel.text = String(diagonalCostStepper.value)
        Model.instance.diagDost = diagonalCostStepper.value
    }
    
    
    @IBAction func didChangeAlgorithm(_ sender: Any) {
        
        if algorithmSegmented.selectedSegmentIndex == 0 {
            Model.instance.algorithm = "A-star"
        } else if algorithmSegmented.selectedSegmentIndex == 1 {
            Model.instance.algorithm = "Dijkstra"
        } else if algorithmSegmented.selectedSegmentIndex == 2 {
            Model.instance.algorithm = "BFS"
        }
        
        hideSettings()
    }
    
    @IBAction func didChangeHeuristics(_ sender: Any) {
        
        if heuristicsSegmented.selectedSegmentIndex == 0 {
            Model.instance.heuristics = "Euclidean"
        } else if heuristicsSegmented.selectedSegmentIndex == 1 {
            Model.instance.heuristics = "Manhattan"
        }
        
        hideSettings()
    }
    
    @IBAction func didPressOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
