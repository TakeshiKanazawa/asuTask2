//
//  levelUpModalViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2020/01/27.
//  Copyright © 2020 tk. All rights reserved.
//

import UIKit
import RealmSwift

class LevelUpModalForDetailViewController: UIViewController {
    
  var userStatus : Results<User>!
    
    //現在のステータスイメージ画像
    @IBOutlet weak var StatusIconImage: UIImageView!
    //現在のユーザステータス表示用ラベル
    @IBOutlet weak var userStatusLabel: UILabel!
    //現在のユーザレベル表示用ラベル
    @IBOutlet weak var userLebelLabel: UILabel!
    //画面閉じるボタン
    @IBAction func closeActionButton(_ sender: Any) {

        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    //dismiss(animated: true, completion:nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Userクラスから値の取り出し
        do {
            let realm = try Realm()
            userStatus = realm.objects(User.self)
        }catch{
            print("RealmからTodaysTaskのデータを読み込めませんでした")
        }
        //画面をグレーにする
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        //RealmオブジェクトuserStatusから値の取り出し
        let status = userStatus?.first?.status
        let level = userStatus?.first!.level
             
        userStatusLabel.text = status
        userLebelLabel.text = "\(level!)"
       
//        //ステータス名と画像名を同じにしてsetする
        
        let myImage = UIImage(named:"\(status!)")
        StatusIconImage.image = myImage
    }
}
