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
    
    private(set) var WaterSettingInfo:(rtc:Date,Ozone_WorkTime:Int,Ozone_Interval:Int)=(Date(timeIntervalSince1970: 0),0,0){
        didSet{
            if WaterSettingInfo != oldValue {
                self.delegate?.OznerDeviceRecordUpdate?(identifier: self.identifier)
                
            }
        }
    }
    private(set) var WaterInfo:(TDS1:Int,TDS2:Int,TDS1_RAW:Int,TDS2_RAW:Int,TDS_Temperature:Int)=(0,0,0,0,0){
        didSet{
            if WaterInfo != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.identifier)
                
            }
        }
    }
    private(set) var FilterInfo:(Filter_A_Time:Int,Filter_B_Time:Int,Filter_C_Time:Int,Filter_A_Percentage:Int,Filter_B_Percentage:Int,Filter_C_Percentage:Int)=(0,0,0,0,0,0){
        didSet{
            if FilterInfo != oldValue {
                self.delegate?.OznerDevicefilterUpdate?(identifier: self.identifier)
                
            }
        }
    }
    override func OznerBaseIORecvData(recvData: Data) {
        switch UInt8(recvData[0]) {
        case 0x21://opCode_respone_setting
            if recvData.count>8 {
                let tmpStarDate=NSDate(year: Int(recvData[1])+2000, month: Int(recvData[2]), day: Int(recvData[3]), hour: Int(recvData[4]), minute: Int(recvData[5]), second: Int(recvData[6])) as Date
                WaterSettingInfo=(tmpStarDate,Int(recvData[8]),Int(recvData[7]))
            }
            
        case 0x22://opCode_respone_water
            WaterInfo=(Int(recvData[1]),Int(recvData[2]),Int(recvData[3]),Int(recvData[4]),Int(recvData[5]))
        case 0x23://opCode_respone_filter
            let A_Time = Int(recvData[1])+16*16*Int(recvData[2])+16*16*16*16*Int(recvData[3])+16*16*16*16*16*16*Int(recvData[4])
            let B_Time = Int(recvData[0])+16*16*Int(recvData[1])+16*16*16*16*Int(recvData[7])+16*16*16*16*16*16*Int(recvData[8])
            let C_Time = Int(recvData[9])+16*16*Int(recvData[10])+16*16*16*16*Int(recvData[11])+16*16*16*16*16*16*Int(recvData[12])
            FilterInfo=(A_Time,B_Time,C_Time,Int(recvData[13]),Int(recvData[14]),Int(recvData[15]))
        default:
            break
        }
    }
    override func doWillInit(){}
    override func repeatFunc() {
        NSDate().second()%2==0 ? requestFilterInfo():requestWaterInfo()
    }
    
    private func calcSum(data:Data)->UInt8{
        var sum = UInt8(0)
        for item in data {
            sum+=item
        }
        return sum
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
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n WaterInfo:\(self.WaterInfo)\n WaterSettingInfo:\(self.WaterSettingInfo)\n FilterInfo:\(self.FilterInfo)\n"
    }
}
