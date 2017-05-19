//
//  WaterPurifier_Wifi.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/12.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class WaterPurifier_Wifi: OznerBaseDevice {
    //添加个性字段
    //对外只读，对内可读写
    private(set) var sensor:(TDS_Before:Int,TDS_After:Int)=(0,0){
        didSet{
            if sensor != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var status:(Power:Bool,Cool:Bool,Hot:Bool,Sterilization:Bool)=(false,false,false,false){
        didSet{
            if status != oldValue {
                self.delegate?.OznerDeviceStatusUpdate!(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    
    func setPower(Power:Bool,callBack:((_ error:Error?)->Void)) {
        setStatus(data: Data.init(bytes: [UInt8(status.Hot.hashValue),UInt8(status.Cool.hashValue),UInt8(Power.hashValue),UInt8(status.Sterilization.hashValue)]))
    }
    func setCool(Cool:Bool,callBack:((_ error:Error?)->Void)) {
        setStatus(data: Data.init(bytes: [UInt8(status.Hot.hashValue),UInt8(Cool.hashValue),UInt8(status.Power.hashValue),UInt8(status.Sterilization.hashValue)]))
    }
    func setHot(Hot:Bool,callBack:((_ error:Error?)->Void)) {
        setStatus(data: Data.init(bytes: [UInt8(Hot.hashValue),UInt8(status.Cool.hashValue),UInt8(status.Power.hashValue),UInt8(status.Sterilization.hashValue)]))
    }
    func setSterilization(Sterilization:Bool,callBack:((_ error:Error?)->Void)) {
       setStatus(data: Data.init(bytes: [UInt8(status.Hot.hashValue),UInt8(status.Cool.hashValue),UInt8(status.Power.hashValue),UInt8(Sterilization.hashValue)]))
    }
    private func setStatus(data:Data) {
        let needData=self.MakeWoodyBytes(code: 0xFA, Opcode: 0x02, data: data)//GroupCode_AppToDevice 、Opcode_ChangeStatus
        self.SendDataToDevice(sendData: needData, CallBack: nil)
        reqeusetStatus()
    }
    
    
    override func OznerBaseIORecvData(recvData: Data) {
        //解析数据并更新个性字段
        requestCount=0
        if self.connectStatus != .Connected
        {
            self.connectStatus = .Connected
        }
        if (recvData.count < 10 )
        {
            return
        }

        let group = UInt8(recvData[0])
        let opCode = UInt8(recvData[3])
        if group == 0xFB {
            var tmpStatus = status
            var tmpSensor = sensor
            switch opCode {
            case 0x01://Opcode_RespondStatus
                tmpStatus.Hot = Int(recvData[12])==1
                tmpStatus.Cool = Int(recvData[13])==1
                tmpStatus.Power = Int(recvData[14])==1
                tmpStatus.Sterilization = Int(recvData[15])==1
                let tds1 = (Int(recvData[16])<0 || Int(recvData[16])==65535) ? 0:Int(recvData[16])
                let tds2 = (Int(recvData[18])<0 || Int(recvData[18])==65535) ? 0:Int(recvData[18])
                tmpSensor.TDS_Before = max(tds1, tds2)
                tmpSensor.TDS_After = min(tds1, tds2)
            case 0x03://Opcode_DeviceInfo
                break
            default:
                break
            }
            status = tmpStatus
            sensor = tmpSensor
        }
    }
    override func doWillInit() {
        let needData=self.MakeWoodyBytes(code: 0xFA, Opcode: 0x01, data: Data())
        self.SendDataToDevice(sendData: needData, CallBack: nil)
    }
    var requestCount = 0//请求三次没反应代表机器断网
    override func repeatFunc() {
        if NSDate().second()%2==0 {
            requestCount+=1
            if requestCount>=3 {
                self.connectStatus = .Disconnect
            }
            self.reqeusetStatus()
        }
    }
    func reqeusetStatus() {
        let needData=self.MakeWoodyBytes(code: 0xFA, Opcode: 0x01, data: Data())
        self.SendDataToDevice(sendData: needData, CallBack: nil)
    }
    
    //data数据处理
    private func MakeWoodyBytes(code:UInt8,Opcode:UInt8,data:Data)->Data
    {
        let len = 13+data.count
        var dataNeed = Data.init(bytes: [code,UInt8(len%256),UInt8(len/256),Opcode])
        var macData=Helper.string(toHexData: self.deviceInfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased())
        if self.deviceInfo.wifiVersion==2 {
            macData=Helper.string(toHexData: self.deviceInfo.deviceMac.replacingOccurrences(of: ":", with: "").lowercased())
        }
        
        dataNeed.append(macData!)
        dataNeed.insert(UInt8(0), at: 10)
        dataNeed.insert(UInt8(0), at: 11)
        dataNeed.append(data)
        
        let pbuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len-1)
        
        for index in 0...(len-2)
        {
            
            pbuffer[index] = dataNeed[index]
            
        }
        
        let lastByte=Helper.crc8(pbuffer, inLen: UInt16(len-1))
        dataNeed.append(lastByte)
        return dataNeed
    }
    private func reqesutProperty(data:Data)
    {
        let len = 14+data.count
        var dataNeed = Data.init(bytes: [0xfb,UInt8(len%256),UInt8(len/256),0x1])
        var macData=Helper.string(toHexData: self.deviceInfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased())
        if self.deviceInfo.wifiVersion==2 {
            macData=Helper.string(toHexData: self.deviceInfo.deviceMac.replacingOccurrences(of: ":", with: "").lowercased())
        }
        dataNeed.append(macData!)
        dataNeed.insert(UInt8(0), at: 10)
        dataNeed.insert(UInt8(0), at: 11)
        dataNeed.insert(UInt8(data.count), at: 12)
        dataNeed.append(data)
        self.SendDataToDevice(sendData: dataNeed, CallBack: nil)
    }
    override func describe() -> String {
        return "设备名称:\(self.settings.name!)\n 连接状态:\(self.connectStatus)\n 净化前TDS:\(self.sensor.TDS_Before)\n 净化后TDS:\(self.sensor.TDS_After)\n 电源:\(self.status.Power)\n 加热:\(self.status.Hot)\n 制冷:\(self.status.Cool)\n"
    }
}
