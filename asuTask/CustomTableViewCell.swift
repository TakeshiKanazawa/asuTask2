//
//  CustomTableViewCell.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/12/01.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
   

    @IBOutlet weak var checkButton: CheckBox!
    
    @IBOutlet weak var taskTextLabel: UILabel!
    
    @IBOutlet weak var taskNotificationImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

 
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCell(titleText: String ) {
        taskTextLabel.text = titleText
     }
//セルの画像キャッシュされないようにする
    override func prepareForReuse() {
        super.prepareForReuse()

        //画像を初期化
        taskNotificationImage.image = nil
    }
}
