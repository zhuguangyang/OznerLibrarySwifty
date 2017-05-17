//
//  Tap.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/3.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
let TapCheckKey1 = "TapCheckKey1"
let TapCheckKey2 = "TapCheckKey2"
class Tap: OznerBaseDevice {
    
    //添加个性字段
    //对外只读，对内可读写
    private(set) var sensor:(TDS:Int,Battery:Int)=(0,0){
        didSet{
            if sensor != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var monthRecords:[Int:Int]=[Int:Int](){//day:tds
        didSet{
            if monthRecords != oldValue {
                self.delegate?.OznerDeviceRecordUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    override func OznerBaseIORecvData(recvData: Data) {
        switch UInt8(recvData[0]) {
        case 0xA2://opCode_ReadSensorRet
            let tmpBattery = Int(recvData[3])+256*Int(recvData[4])
            var bateary = 100
            for item in 21...30 {
                if tmpBattery<item*100 {
                    bateary=[0,3,7,15,16,17,30,50,70,90][item-21]
                    break
                }
            }
            let tmpTDS = Int(recvData[15])+256*Int(recvData[16])
            sensor=(tmpTDS,bateary)
        case 0xA8://opCode_ReadMACRet
            if recvData.count>=6 {
                
                self.deviceInfo.deviceMac=String(format: "%02X:%02X:%02X:%02X:%02X:%02X", recvData[5],recvData[4],recvData[3],recvData[2],recvData[1],recvData[0])
            }
            break
        case 0xA7://opCode_ReadTapRecordRet
            let tmpDate=NSDate(year: Int(recvData[1])+2000, month: Int(recvData[2]), day: Int(recvData[3]), hour: Int(recvData[4]), minute: Int(recvData[5]), second: Int(recvData[6])) as NSDate
            let tmpTDS = Int(recvData[7])+16*16*Int(recvData[8])
            
            OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: tmpDate as Date, Tds: tmpTDS, Temperature: 0, Volume: 0, Updated: false)
            if tmpDate.year()==NSDate().year()&&tmpDate.month()==NSDate().month() {
                let tmpLastTDS = monthRecords[tmpDate.day()] ?? 0
                if tmpTDS>tmpLastTDS {
                    monthRecords[tmpDate.day()]=tmpTDS
                }
                
            }
            
        default:
            break
        }
    }
    override func doWillInit() {
        //初始化本地月数据记录
        let tmpMonth=OznerDeviceRecordHelper.instance.getRecords(Identifier: self.deviceInfo.deviceID)
        var tmpmonth = [Int:Int]()
        for item in tmpMonth {
            if (item.date as NSDate).year()==NSDate().year()&&(item.date as NSDate).month()==NSDate().month() {
                let tmpLastTDS = tmpmonth[(item.date as NSDate).day()] ?? 0
                tmpmonth[(item.date as NSDate).day()]=max(item.tds, tmpLastTDS)
            }
        }
        monthRecords=tmpmonth
        self.sendTime()
        self.sendSetting()
        self.SendDataToDevice(sendData: Data.init(bytes: [0x21])) { (error) in}//opCode_Foreground
        self.SendDataToDevice(sendData: Data.init(bytes: [0x18])) { (error) in}//opCode_ReadMAC
        
    }
    
    override func repeatFunc() {
        if NSDate().second()%2==0 {
            self.SendDataToDevice(sendData: Data.init(bytes: [0x17])) { (error) in}//opCode_ReadTapRecord
        }else{
            self.SendDataToDevice(sendData: Data.init(bytes: [0x12])) { (error) in}//opCode_ReadSensor
        }
        
    }
    
    private func sendTime()  {
        let data = Data.init(bytes: [
            0xF0,
            UInt8(NSDate().year()-2000),
            UInt8(NSDate().month()),
            UInt8(NSDate().day()),
            UInt8(NSDate().hour()),
            UInt8(NSDate().minute()),
            UInt8(NSDate().second())])
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    private func sendSetting()  {
        let check1=Int(self.settings.GetValue(key: TapCheckKey1, defaultValue: "\(Int(8*3600))"))
        let check2=Int(self.settings.GetValue(key: TapCheckKey2, defaultValue: "\(Int(8*3600))"))
        
        let data = Data.init(bytes: [
            0x10,
            UInt8(check1!/3600),
            UInt8(check1!%3600/60),
            UInt8(check1!%60),
            UInt8(check2!/3600),
            UInt8(check2!%3600/60),
            UInt8(check2!%60),
            UInt8(check1!/3600),
            UInt8(check1!%3600/60),
            UInt8(check1!%60),
            UInt8(check2!/3600),
            UInt8(check2!%3600/60),
            UInt8(check2!%60)])
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    override func describe() -> String {
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(self.sensor)\n"
    }
}
