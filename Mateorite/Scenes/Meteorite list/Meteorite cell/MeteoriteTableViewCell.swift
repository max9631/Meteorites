//
//  MeteoriteTableViewCell.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import UIKit

class MeteoriteTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(with meteorite: Meteorite) {
        title.text = meteorite.name
    }
}
