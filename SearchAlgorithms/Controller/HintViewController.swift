//
//  HintViewController.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 29/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import UIKit

class HintViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.instance.hints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hint", for: indexPath) as! HintTableViewCell
        
        let hint = Model.instance.hints[indexPath.row]
        
        cell.icon.image = hint.hintIcon
        cell.title.text = hint.hintTitle
        cell.hintDescription.text = hint.hintDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
}
