//
//  WaterPurifier_Blue.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/7.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class WaterPurifier_Blue: OznerBaseDevice {
    
    //对外只读，对内可读写
    private(set) var WaterSettingInfo:(rtc:Date,Ozone_WorkTime:Int,Ozone_Interval:Int,waterDate:Date)=(Date(timeIntervalSince1970: 0),0,0,Date(timeIntervalSince1970: 0)){
        didSet{
            if WaterSettingInfo != oldValue {
                self.delegate?.OznerDeviceRecordUpdate?(identifier: self.deviceInfo.deviceID)
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var WaterInfo:(TDS1:Int,TDS2:Int,TDS1_RAW:Int,TDS2_RAW:Int,TDS_Temperature:Int,waterml:CLongLong)=(0,0,0,0,0,0){
        didSet{
            if WaterInfo != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var FilterInfo:(Filter_A_Time:Int,Filter_B_Time:Int,Filter_C_Time:Int,Filter_A_Percentage:Int,Filter_B_Percentage:Int,Filter_C_Percentage:Int)=(0,0,0,0,0,0){
        didSet{
            if FilterInfo != oldValue {
                self.delegate?.OznerDevicefilterUpdate?(identifier: self.deviceInfo.deviceID)
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    
    
    private(set) var TwoInfo:(hottempSet:Int,isPower:Int,openPowerTime:Int,closePowerTime:Int,isHot:Int,startHotTime:Int,endHotTime:Int,isCold:Int) = (40,0,0,0,0,0,0,0){
        
        didSet{
            if TwoInfo != oldValue {
             
                self.delegate?.OznerDeviceSensorUpdate!(identifier: self.deviceInfo.deviceID)
                
            }
        }
        
    }
    
    func setHotTemp(_ temp:Int) -> Bool {
        
        if temp == TwoInfo.hottempSet {
            return true
        }
        
        var data = Data.init(bytes: [0x41,UInt8(temp),UInt8(TwoInfo.isPower),UInt8(TwoInfo.openPowerTime),UInt8(TwoInfo.closePowerTime),UInt8(TwoInfo.isHot),UInt8(TwoInfo.startHotTime),UInt8(TwoInfo.endHotTime),UInt8(TwoInfo.isCold)])
        let tmpByte = calcSum(data: data)
        data.append(tmpByte)
        self.SendDataToDevice(sendData: data) { (error) in
   
        }
        sleep(UInt32(0.3))
        
        return true
    }
    
    func addWaterDays(days:Int) -> Bool {
        let curWaterDate = WaterSettingInfo.waterDate
        if curWaterDate.timeIntervalSince1970==0 {//没有获取到水值信息
            requestWaterInfo()
            return false
        }
        var stopDate=NSDate()
        if (curWaterDate.timeIntervalSince(stopDate as Date)>0) {
            stopDate=curWaterDate as NSDate
        }
        stopDate = stopDate.addingDays(days) as NSDate
        let dataBytes:[UInt8] = [
            0x40,UInt8(NSDate().year()-2000),
            UInt8(NSDate().month()),
            UInt8(NSDate().day()),
            UInt8(NSDate().hour()),
            UInt8(NSDate().minute()),
            UInt8(NSDate().second()),UInt8(WaterSettingInfo.Ozone_Interval),
            UInt8(WaterSettingInfo.Ozone_WorkTime),
            UInt8(0),
            UInt8(stopDate.year()-2000),
            UInt8(stopDate.month()),
            UInt8(stopDate.day()),
            UInt8(stopDate.hour()),
            UInt8(stopDate.minute()),
            UInt8(stopDate.second()),0x88,
            0x16
        ]
        var data = Data.init(bytes: dataBytes)
        let tmpByte = calcSum(data: data)
        data.append(tmpByte)
        self.SendDataToDevice(sendData: data) { (error) in}
        sleep(UInt32(0.3))
        requestWaterInfo()
        sleep(UInt32(0.3))
        let tmpCurWaterDate = WaterSettingInfo.waterDate as NSDate
        
        if tmpCurWaterDate.month()==stopDate.month()&&tmpCurWaterDate.year()==stopDate.year() {
            return true
        }else{
            return false
        }
        
    }
    override func OznerBaseIORecvData(recvData: Data) {
        switch UInt8(recvData[0]) {
        case 0x21://opCode_respone_setting
            if recvData.count>8 {
                let tmpStarDate=NSDate(year: Int(recvData[1])+2000, month: Int(recvData[2]), day: Int(recvData[3]), hour: Int(recvData[4]), minute: Int(recvData[5]), second: Int(recvData[6])) as Date
                let tmpWaterDate=NSDate(year: Int(recvData[9])+2000, month: Int(recvData[10]), day: Int(recvData[11]), hour: Int(recvData[12]), minute: Int(recvData[13]), second: Int(recvData[14])) as Date
                WaterSettingInfo=(tmpStarDate,Int(recvData[8]),Int(recvData[7]),tmpWaterDate)
            }
        case 0x22://opCode_respone_water
            WaterInfo=(recvData.subInt(starIndex: 1, count: 2),recvData.subInt(starIndex: 3, count: 2),recvData.subInt(starIndex: 5, count: 2),recvData.subInt(starIndex: 7, count: 2),recvData.subInt(starIndex: 9, count: 2),CLongLong(recvData.subInt(starIndex: 11, count: 4)))
        case 0x23://opCode_respone_filter
            let A_Time = recvData.subInt(starIndex: 1, count: 4)
            let B_Time = recvData.subInt(starIndex: 5, count: 4)
            let C_Time = recvData.subInt(starIndex: 9, count: 4)
            FilterInfo=(A_Time,B_Time,C_Time,Int(recvData[13]),Int(recvData[14]),Int(recvData[15]))
        case 0x25:
            let hottempSet = recvData.subInt(starIndex: 1, count: 1)
            let isPower = recvData.subInt(starIndex: 2, count: 1)
            let openPowerTime = recvData.subInt(starIndex: 3, count: 1)
            let closePowerTime = recvData.subInt(starIndex: 4, count: 1)
            let isHot = recvData.subInt(starIndex: 5, count: 1)
            let startHotTime = recvData.subInt(starIndex: 6, count: 1)
            let endHotTime = recvData.subInt(starIndex: 7, count: 1)
            let isCold  = recvData.subInt(starIndex: 8, count: 1)
            
            TwoInfo = (hottempSet,isPower,openPowerTime,closePowerTime,isHot,startHotTime,endHotTime,isCold)
            
            break
        default:
            break
        }
    }
    
    override func doWillInit(){}
    override func repeatFunc() {
        
        if Int(arc4random()%2)==0 {
            requestFilterInfo()
            requestSettingInfo()
        }else{
            requestWaterInfo()
            requestSetting()
        }
        
    }
    
    private func calcSum(data:Data)->UInt8{
        var sum = 0
        for item in data {
            sum+=Int(item)
        }
        return UInt8(sum%256)
    }
    private func requestSettingInfo(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0x20,UInt8(1)]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20,UInt8(1),tmpBytes]), CallBack: nil)
    }
    private func requestWaterInfo(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0x20,UInt8(2)]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20,UInt8(2),tmpBytes]), CallBack: nil)
    }
    private func requestFilterInfo(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0x20,UInt8(3)]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20,UInt8(3),tmpBytes]), CallBack: nil)
    }
    private func requestSetting(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0x20,UInt8(5)]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20,UInt8(5),tmpBytes]), CallBack: nil)
    }
    /*!
     滤芯历史信息
     */
    private func requestFilterHisInfo(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0x20,UInt8(3)]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20,UInt8(3),tmpBytes]), CallBack: nil)
    }
    private func updateSetting(interval:Int,worktime:Int,reset:Bool){
        var data = Data.init(bytes: [
            0x40,
            UInt8(NSDate().year()-2000),
            UInt8(NSDate().month()),
            UInt8(NSDate().day()),
            UInt8(NSDate().hour()),
            UInt8(NSDate().minute()),
            UInt8(NSDate().second()),
            UInt8(interval),
            UInt8(worktime),
            UInt8(reset.hashValue)
            ])
        let tmpByte = calcSum(data: data)
        data.append(tmpByte)
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    func reset(){
        let tmpBytes = calcSum(data: Data.init(bytes: [0xa0]))
        self.SendDataToDevice(sendData: Data.init(bytes: [0xa0,tmpBytes]), CallBack: nil)
    }
    
    //重置滤芯时间
    func resetFilter(){
        if WaterSettingInfo.Ozone_Interval>0&&WaterSettingInfo.Ozone_WorkTime>0 {
            self.updateSetting(interval: WaterSettingInfo.Ozone_Interval, worktime: WaterSettingInfo.Ozone_WorkTime, reset: true)
        }
    }
    //返回是否允许滤芯重置
    func isEnableFilterReset()->Bool
    {
        return true
    }
    override func describe() -> String {
        return "name:\(self.settings.name!)\nconnectStatus:\(self.connectStatus)\nTDS1:\(self.WaterInfo.TDS1),TDS2:\(self.WaterInfo.TDS2),TDS_Temperature:\(self.WaterInfo.TDS_Temperature)\nrtc:\(self.WaterSettingInfo.rtc),Ozone_Interval:\(self.WaterSettingInfo.Ozone_Interval),Ozone_WorkTime:\(self.WaterSettingInfo.Ozone_WorkTime),waterDate:\(self.WaterSettingInfo.waterDate)\nFilterA:\(self.FilterInfo.Filter_A_Percentage),FilterB:\(self.FilterInfo.Filter_B_Percentage),FilterC:\(self.FilterInfo.Filter_C_Percentage)\n"
    }
    
    //OTA
    func loadBinFile() {
        
        
        
    }
}

public func !=<A, B, C, D, E,F,G,H>(lhs: (A, B, C, D, E,F,G,H), rhs: (A, B, C, D, E,F,G,H)) -> Bool where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable,F : Equatable, G : Equatable, H : Equatable {
    
    return lhs.0 != rhs.0 && lhs.1 != rhs.1 && lhs.2 != rhs.2 && lhs.3 != rhs.3 && lhs.4 != rhs.4 && lhs.5 != rhs.5 && lhs.6 != rhs.6 && lhs.7 != rhs.7
    
}
