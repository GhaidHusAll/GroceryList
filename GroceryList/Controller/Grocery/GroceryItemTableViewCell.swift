//
//  TableViewCell.swift
//  GroceryList
//
//  Created by administrator on 11/11/2021.
//

import UIKit
import SDWebImage
class GroceryItemTableViewCell: UITableViewCell {

   
    
    @IBOutlet weak var userNamelbl: UILabel!
    @IBOutlet weak var itmeNamelbl: UILabel!
    @IBOutlet weak var ItemiamgeView: UIImageView!
    func setImageAvater(){
           
           ItemiamgeView.layer.cornerRadius =  ItemiamgeView.frame.size.height / 2
        
           ItemiamgeView.clipsToBounds = true
           ItemiamgeView.layer.borderWidth = 1.0
           ItemiamgeView.layer.borderColor = UIColor.black.cgColor
           
       }
    func setCellValues(ItemName:String,UserName:String , url: String){
        setImageAvater()
        userNamelbl.text = UserName
        itmeNamelbl.text = ItemName
        if  let url = URL(string: url) {
                       self.ItemiamgeView.sd_setImage(with: url, completed: nil)
                   }
    }
    
}
