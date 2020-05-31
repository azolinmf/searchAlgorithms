//
//  SecondViewController.swift
//  SearchAlgorithms
//
//  Created by Maria Fernanda Azolin on 24/05/20.
//  Copyright © 2020 Apple Developer Academy. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var linkedinButton: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                guard let url = URL(string: "https://en.wikipedia.org/wiki/A*_search_algorithm") else { return }
                UIApplication.shared.open(url)
            } else if indexPath.row == 1 {
                guard let url = URL(string: "https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm") else { return }
                UIApplication.shared.open(url)
            } else if indexPath.row == 2 {
                guard let url = URL(string: "https://en.wikipedia.org/wiki/Breadth-first_search") else { return }
                UIApplication.shared.open(url)
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .black
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = .black
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .clear
    }
    
    
    @IBAction func didPressGithubButton(_ sender: Any) {
        guard let url = URL(string: "https://github.com/azolinmf") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func didPressLinkedinButton(_ sender: Any) {
        guard let url = URL(string: "https://www.linkedin.com/in/maria-fernanda-azolin/") else { return }
        UIApplication.shared.open(url)

    }
    
    
}

