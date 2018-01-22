//
//  OznerDeviceRecordHelper.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/4.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
import SQLite
public class OznerDeviceRecordHelper: NSObject {
    private static var _instance: OznerDeviceRecordHelper! = nil
   public static var instance: OznerDeviceRecordHelper! {
        get {
            if _instance == nil {
                _instance = OznerDeviceRecordHelper(dbName: OznerManager.instance.owner)
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    private let date = Expression<Date>("date")
    private let tds = Expression<Int>("tds")
    private let temperature = Expression<Int>("temperature")
    private let volume = Expression<Int>("volume")
    private let updated = Expression<Bool>("updated")

    private var db:Connection?
  public  required init(dbName:String) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!+"/OznerLibrary"+dbName+".sqlite3"
        db = try? Connection(path)
    }

   public func addRecordToSQL(Identifier:String,Tdate:Date,Tds:Int,Temperature:Int,Volume:Int,Updated:Bool)  {
        //判断表是否存在,不存在就创建
        let _=try? db!.run(Table(Identifier).create(ifNotExists: true){
            t in
            t.column(date, primaryKey: true)
            t.column(tds)
            t.column(temperature)
            t.column(volume)
            t.column(updated)
        })
        let _=try? db!.run(Table(Identifier).insert(or: .replace, date <- Tdate, tds <- Tds, temperature <- Temperature,volume <- Volume, updated <- Updated))
    }
   public func getRecords(Identifier:String)->[(date:Date,tds:Int,temperat:Int,volum:Int,ipdated:Bool)]  {
        //判断表是否存在,不存在就创建
        let _=try? db!.run(Table(Identifier).create(ifNotExists: true){
            t in
            t.column(date, primaryKey: true)
            t.column(tds)
            t.column(temperature)
            t.column(volume)
            t.column(updated)
        })
        var deviceRecords=[(date:Date,tds:Int,temperat:Int,volum:Int,ipdated:Bool)]()
        for record in try! db!.prepare(Table(Identifier)) {
            let tmpDate = record[date] as NSDate
            let monthAgoDate = NSDate().addingMonths(-1)//一个月以前的日期
            
            if tmpDate.isEarlierThan(monthAgoDate) {
                let alice = Table(Identifier).filter(date == tmpDate as Date)
                do {//删除一个月前的数据
                    try db!.run(alice.delete())
                } catch {
                }
            }else{
                deviceRecords.append((record[date],record[tds],record[temperature],record[volume],record[updated]))
            }
            
            
        }
        return deviceRecords
    }

    
}
