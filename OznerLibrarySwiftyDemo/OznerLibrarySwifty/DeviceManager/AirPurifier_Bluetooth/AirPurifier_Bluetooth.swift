//
//  AirPurifier_Bluetooth.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

class AirPurifier_Bluetooth: OznerBaseDevice {

    //添加个性字段
    //对外只读，对内可读写
    private(set) var sensor:(Temperature:Int,Humidity:Int,PM25:Int,Power:Bool,Speed:Int)=(0,0,0,false,0){
        didSet{
            if sensor != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var filterStatus:(starDate:Date,stopDate:Date,workTime:Int,maxWorkTime:Int) = (Date(timeIntervalSince1970: 0),Date(timeIntervalSince1970: 0),-1,-1){
        didSet{
            if filterStatus != oldValue &&
                filterStatus.starDate != Date(timeIntervalSince1970: 0) &&
                    filterStatus.workTime != -1{
                self.delegate?.OznerDevicefilterUpdate?(identifier: self.deviceInfo.deviceID)
            }
           
        }
    }
    func setPower(power:Bool,callBack:((_ error:Error?)->Void)) {
        let tmpData=Data.init(bytes: [UInt8(power.hashValue),UInt8(sensor.Speed)])
        self.SendDataToDevice(sendData: makePacket(code: 0x10, data: tmpData), CallBack: nil)
    }
    func setSpeed(speed:Int,callBack:((_ error:Error?)->Void)) {
        let tmpData=Data.init(bytes: [UInt8(sensor.Power.hashValue),UInt8(speed)])
        self.SendDataToDevice(sendData: makePacket(code: 0x10, data: tmpData), CallBack: nil)
    }
    override func OznerBaseIORecvData(recvData: Data) {
        //解析数据并更新个性字段
        switch UInt8(recvData[0]) {
        case 0x21://statussensor
            var tmpSpeed = sensor.Speed
            if recvData.count>18 {
                tmpSpeed=Int(recvData[18])
                sensor=(sensor.Temperature,sensor.Humidity,sensor.PM25,Int(recvData[1])==1,tmpSpeed)
                let tmpStarDate=NSDate(year: Int(recvData[8])+2000, month: Int(recvData[9]), day: Int(recvData[10]), hour: Int(recvData[11]), minute: Int(recvData[12]), second: Int(recvData[13])) as Date
                filterStatus=(tmpStarDate,filterStatus.stopDate,Int(recvData[14]),filterStatus.maxWorkTime)
            }
                
        case 0x22://sensor
            sensor=(Int(recvData[1]),Int(recvData[2]),Int(recvData[3])+256*Int(recvData[4]),sensor.Power,sensor.Speed)
        case 0x23://filter
            let tmpStopDate=NSDate(year: Int(recvData[7])+2000, month: Int(recvData[8]), day: Int(recvData[9]), hour: Int(recvData[10]), minute: Int(recvData[11]), second: Int(recvData[12])) as Date
            filterStatus=(filterStatus.starDate,tmpStopDate,filterStatus.workTime,Int(recvData[14]))
            break
        case 0x24://a2dp
            break
        default:
            break
        }
        
    }
    override func doWillInit() {
        self.sendTime()
        self.requestFilter()
        self.requestSensor()
        self.requestStatus()
    }
    override func repeatFunc() {
        NSDate().second()%2==0 ? self.requestSensor():self.requestStatus()
    }
    
    
    
    private func sendTime()  {
        let tmpData = Data.init(bytes: [
            UInt8(NSDate().year()-2000),
            UInt8(NSDate().month()),
            UInt8(NSDate().day()),
            UInt8(NSDate().hour()),
            UInt8(NSDate().minute()),
            UInt8(NSDate().second())])
        let data=self.makePacket(code: 0x40, data: tmpData)
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    private func requestFilter() {
        let tmpData = Data.init(bytes: [3])
        let data=self.makePacket(code: 0x20, data: tmpData)
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    private func requestStatus() {
        let tmpData = Data.init(bytes: [1])
        let data=self.makePacket(code: 0x20, data: tmpData)
        self.SendDataToDevice(sendData: data) { (error) in }
    }
    private func requestSensor() {
        let tmpData = Data.init(bytes: [2])
        let data=self.makePacket(code: 0x20, data: tmpData)
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    //data数据处理
    private func makePacket(code:UInt8,data:Data)->Data
    {
        var dataNeed = Data.init(bytes: [code])
        dataNeed.append(data)
        var checksum=0
        for i in 0..<dataNeed.count {
            checksum = checksum+Int(dataNeed[i])
        }
        dataNeed.append(UInt8(checksum%256))
        return dataNeed
    }
    override func describe() -> String {
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(self.sensor)\n filterStatus:\(self.filterStatus)\n"
    }
}
