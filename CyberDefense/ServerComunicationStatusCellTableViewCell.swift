//
//  ServerComunicationStatusCellTableViewCell.swift
//  CyberDefense
//
//  Created by Victor Tavares on 22/03/19.
//  Copyright © 2019 Victor Semedo. All rights reserved.
//

import UIKit

class ServerComunicationStatusCellTableViewCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
