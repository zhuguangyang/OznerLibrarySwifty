//
//  OznerCupRecords.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/5.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
enum CupRecordType {
    case day
    case weak
    case month
}


class OznerCupRecords: NSObject {

    var identifier:String!
    
    required init(Identifier:String) {
        identifier=Identifier
    }
    
    func getRecord(type:CupRecordType) -> [Int:(Temperature:Int,Volume:Int,TDS:Int)] {
        var tmpData = [Int:(Temperature:Int,Volume:Int,TDS:Int)]()
        
        let allData = OznerDeviceRecordHelper.instance.getRecords(Identifier: identifier)
        for item in allData {
            switch type {
            case .day://0...23
                if (item.date as NSDate).day()==NSDate().day() {
                    let tmpItem = tmpData[(item.date as NSDate).hour()] ?? (0,0,0)
                    
                    
                    tmpData[(item.date as NSDate).hour()]=(max(tmpItem.Temperature, item.temperat),tmpItem.Volume+item.volum,max(tmpItem.TDS, item.tds))
                }
            case .weak://0...6
                if ((item.date as NSDate).isEarlierThan(Date()))&&((item.date as NSDate).daysEarlierThan(Date())<=NSDate().weekday()) {
                    let tmpItem = tmpData[(item.date as NSDate).weekday()] ?? (0,0,0)
                    tmpData[(item.date as NSDate).weekday()]=(max(tmpItem.Temperature, item.temperat),tmpItem.Volume+item.volum,max(tmpItem.TDS, item.tds))
                }
                
                break
            case .month://1...31
                if (item.date as NSDate).month()==NSDate().month() {
                    let tmpItem = tmpData[(item.date as NSDate).day()] ?? (0,0,0)
                    tmpData[(item.date as NSDate).day()]=(max(tmpItem.Temperature, item.temperat),tmpItem.Volume+item.volum,max(tmpItem.TDS, item.tds))
                }
            }
        }
        
        return tmpData
    }
    func saveRecord(date:Date,Temperature:Int,Volume:Int,TDS:Int){
        OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: identifier, Tdate: date, Tds: TDS, Temperature: Temperature, Volume: Volume, Updated: false)
    }
}
