//
//  TomorrowsViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/10/12.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import RealmSwift

class TomorrowsViewController: UIViewController {
    //DB用テストコード！
    
    //ここから
    var todoItem: Results<TodaysTask>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 永続化されているデータを取りだす
        do{
            let realm = try Realm()
            todoItem = realm.objects(TodaysTask.self)
            
        }catch{

        }
        
        //ここまで

    }
    



}
