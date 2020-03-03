//
//  User.swift
//  asuTask
//
//  Created by 金澤武士 on 2020/02/03.
//  Copyright © 2020 tk. All rights reserved.
//

//Userのタスク完了数とLevelを管理するクラス

import Foundation
import RealmSwift


class User: Object {
    @objc dynamic var id:String = "0"
    @objc dynamic var doneTask: Int = 1
    @objc dynamic var level: Int = 1
    @objc dynamic var status: String = "モンスターのたまご"
    
    override static func primaryKey() -> String? {
         return "id"
     }
}




