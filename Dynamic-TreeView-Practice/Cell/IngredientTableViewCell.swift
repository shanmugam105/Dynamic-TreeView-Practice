//
//  IngredientTableViewCell.swift
//  KJExpandableTableTree_Example
//
//  Created by Mac on 07/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkBoxLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configureView(state: CellState,
                       ingredient: String,
                       price: String,
                       spacing: Int,
                       type: CellType? = .CheckBox) {
        switch state {
        case .open:
            if type != .RadioButton {
                checkBox.image = #imageLiteral(resourceName: "selected_check")
            }else{
                checkBox.image = #imageLiteral(resourceName: "selected_radio")
            }
        case .close:
            if type != .RadioButton {
                checkBox.image = #imageLiteral(resourceName: "unselected_check")
            }else{
                checkBox.image = #imageLiteral(resourceName: "unselected_radio")
            }
        case .none: break
        }
        var leadingConstant: CGFloat = 0
        
        if spacing == 1 {
            priceLabel.isHidden = true
            checkBox.isHidden = true
            nameLabel.font = .systemFont(ofSize: 16)
        } else if spacing % 2 == 1 {
            priceLabel.isHidden = true
            checkBox.isHidden = true
            leadingConstant = CGFloat(15 * spacing) - 15
            nameLabel.font = .systemFont(ofSize: 16)
            // priceLabel.font = UIFont(name: Constants.OPEN_SANS_LIGHT, size: 16)
        } else {
            priceLabel.isHidden = false
            checkBox.isHidden = false
            leadingConstant = CGFloat(15 * spacing)
            nameLabel.font = .systemFont(ofSize: 16)
            priceLabel.font = .systemFont(ofSize: 16)
        }
        checkBox.image = checkBox.image?.withRenderingMode(.alwaysTemplate)
        checkBox.tintColor = .link
        nameLabel.text = ingredient.capitalized
        priceLabel.text = "$" + " " + price
        selectionStyle = .none
        checkBoxLeadingConstraint.constant = leadingConstant - 15
    }
}
