//
//  ShopListTableViewCell.swift
//  AndreyArtur
//
//  Created by Andrey Gomes on 14/09/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ShopListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var ivProduct: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
