//
//  FriendsListTableViewCell.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit

class FriendsListTableViewCell: UITableViewCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImageVIew: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageVIew.layer.borderColor = #colorLiteral(red: 0.9932343364, green: 0.1820248067, blue: 0.4938643575, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = .clear
        self.tintColor = .clear
    }
    
}
