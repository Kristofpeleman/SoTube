//
//  SongTableViewCell.swift
//  
//
//  Created by VDAB Cursist on 11/05/17.
//
//

import UIKit

// Our TableViewCells will use this code
class SongTableViewCell: UITableViewCell {
    
    // They have Outlets for 3 labels
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
