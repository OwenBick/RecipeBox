//
//  InstructionCell.swift
//  RecipeProject
//
//  Created by Owen Bick on 11/9/20.
//

import UIKit

class InstructionCell: UITableViewCell {

    @IBOutlet var instructionTitle: UILabel!
    @IBOutlet weak var instructionId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        instructionId.layer.masksToBounds = true
        instructionId.layer.cornerRadius = 15
    }
}
