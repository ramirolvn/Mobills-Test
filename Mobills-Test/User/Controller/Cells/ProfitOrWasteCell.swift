//
//  ProfitOrWasteCell.swift
//  Mobills-Test
//
//  Created by Ramiro Lima Vale Neto on 23/04/19.
//  Copyright © 2019 Kyle Lee. All rights reserved.
//

import UIKit

class ProfitOrWasteCell: UITableViewCell {
    @IBOutlet weak var valorLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var recvieveOrPaidLB: UILabel!
    @IBOutlet weak var checkBox: CheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
