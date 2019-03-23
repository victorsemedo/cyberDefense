//
//  FirstViewController.swift
//  CyberDefense
//
//  Created by Victor Tavares on 22/03/19.
//  Copyright © 2019 Victor Semedo. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    let serverURLs = ["https://ec2-100-26-89-97.compute-1.amazonaws.com/", "https://parsify-format.p.rapidapi.com/"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

extension FirstViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ServerStatusCell", for: indexPath) as? ServerComunicationStatusCellTableViewCell {
            let url = serverURLs[indexPath.row]
            cell.urlLabel.text = url
            CyberDefenseApi.shared.validateServerSecurity(url: url) { (safe) in
                cell.statusLabel.text = safe ? "Segura" : "insegura"
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
}
