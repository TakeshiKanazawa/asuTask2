//
//  todaysTaskRealmObject.swift
//  asuTask
//
//  Created by 金澤武士 on 2020/02/02.
//  Copyright © 2020 tk. All rights reserved.
//

import Foundation
import RealmSwift

//Listにしたいもの

 //入力されたタスクを入れる変数
 var editText = String()

class TodaysTask: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var timeForDetail: String = ""
    @objc dynamic var priority: String = ""
    @objc dynamic var id: String = ""
    
}

//Listの定義
class TaskList: Object {
    let list = List<TodaysTask>()
}
