//
//  VariableTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class VariableTableViewCell: UITableViewCell {

    @IBOutlet weak var variableName: UILabel!
    @IBOutlet weak var onoff: UISwitch!
    public var variable:String?
    public var parent:ScoreSettingsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if let sender = sender as? UISwitch {
            parent?.switchChanged(variableName: self.variable!, isOn: sender.isOn)
        }
    }
    
}
