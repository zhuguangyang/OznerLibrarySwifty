//
//  WaterPurifier_Wifi.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/12.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class WaterPurifier_Wifi: OznerBaseDevice {
    
    //测试
    func testOTA()  {
        print("开始OTA")
        
        let OTAdata = Data.init(base64Encoded: "/bYABrD4kxAMOQAAKENvbWwgT25lKEhaQTA2LTM2MykpRDAxLUp1bi0xNC0yMDE3LTE3MjUzNi5iaW4AAAAAAAAAAAAAAAAAAAAAABDPAACfGVUAOTlkNzQ2YTAwMGM5N2EwYjUxYmE0YmM0NDZlNzA0ZGUAaHR0cDovL2FwaS5lYXN5bGluay5pby9yb21zLwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHE=")
        print(OTAdata!)
        self.SendDataToDevice(sendData: OTAdata!) { (error) in
            print("success")
        }
    }

    //测试
    func FCTest()  {
        print("开始OTA")
        let FCdata = self.MakeWoodyBytes(code: 0xfd, Opcode: 0x25, data: Data())
        self.SendDataToDevice(sendData: FCdata) { (error) in
            print("success")
        }
    }
    func setWaterTime(months:Int) {
        fcsensor02IsSuccess=false
        var stopDate=NSDate().addingMinutes(fcsensor01.remindWater) as NSDate
        stopDate = stopDate.addingMonths(months) as NSDate
        var data = Data.init(bytes: [
            0xFD,0x40,0x00,0x02])
        var macData=Helper.string(toHexData: self.deviceInfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased())
        if self.deviceInfo.wifiVersion==2 {
            macData=Helper.string(toHexData: self.deviceInfo.deviceMac.replacingOccurrences(of: ":", with: "").lowercased())
        }
        data.append(macData!)
        data.append(0x00)
        data.append(0x00)
        data.append(UInt8(stopDate.year()%256))
        data.append(UInt8(stopDate.year()/256))
        data.append(UInt8(stopDate.month()))
        data.append(UInt8(stopDate.day()))
        data.append(UInt8(stopDate.hour()))
        data.append(UInt8(stopDate.minute()))
        data.append(UInt8(stopDate.second()))
        //断网时间
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        //
        data.append("0123456".data(using: String.Encoding.utf8)!)//区域代码
        data.append(UInt8(0x00))//滤芯状态
        //最后保养时间
        data.append(UInt8(stopDate.year()%256))
        data.append(UInt8(stopDate.year()/256))
        data.append(UInt8(stopDate.month()))
        data.append(UInt8(stopDate.day()))
        
        //现在时间
        data.append(UInt8(NSDate().year()%256))
        data.append(UInt8(NSDate().year()/256))
        data.append(UInt8(NSDate().month()))
        data.append(UInt8(NSDate().day()))
        data.append(UInt8(NSDate().hour()))
        data.append(UInt8(NSDate().minute()))
        data.append(UInt8(NSDate().second()))
        //最后刷卡时间
        let tmplastCardDate = fcsensor01.lastCardDate as NSDate
        data.append(UInt8(tmplastCardDate.year()-2000))
        data.append(UInt8(tmplastCardDate.month()))
        data.append(UInt8(tmplastCardDate.day()))
        data.append(UInt8(tmplastCardDate.hour()))
        data.append(UInt8(tmplastCardDate.minute()))
        data.append(UInt8(tmplastCardDate.second()))
        //最后刷卡卡号
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        // 保留
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        data.append(0x01)
        
        
        let pbuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        
        for index in 0...(data.count-1)
        {
            
            pbuffer[index] = data[index]
            
        }
        
        let lastByte=Helper.crc8(pbuffer, inLen: UInt16(data.count))
        data.append(lastByte)

        self.SendDataToDevice(sendData: data) { (error) in}
        
    }
    private(set) var fcsensor01:(devicetype:String,deviceNB:String,mainboard:String,controlboard:String,mainboardNB:String,controlboardNB:String,inputTimes:Int,waterRate:Float,errorNB:Int,errorFlag:Int,RTCDate:Date,lastCardDate:Date,lastCardNB:Data,remindWater:Int)=("","","","","","",0,0.0,0,0,Date(),Date(),Data(),0){
        didSet{
            //if fcsensor != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            //}
        }
    }
    private(set) var fcsensor02IsSuccess:Bool=false{
        didSet{
            if fcsensor02IsSuccess != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    //添加个性字段
    //对外只读，对内可读写
    private(set) var sensor:(TDS_Before:Int,TDS_After:Int,Temperature:Float)=(0,0,0.0){
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
        let needData=self.MakeWoodyBytes(code: 0xfa, Opcode: 0x02, data: data)//GroupCode_AppToDevice 、Opcode_ChangeStatus
        self.SendDataToDevice(sendData: needData, CallBack: nil)
        reqeusetStatus()
    }
    
    //devicetype:String,deviceNB:String,mainboard:String,controlboard:String,mainboardNB:String,controlboardNB:String,inputTimes:Int,waterRate:Float,errorNB:Int,errorFlag:Int,RTCDate:Date,lastCardDate:Date,lastCardNB:Int,remindWater:Int
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

        let group = Int(recvData[0])
        let opCode = UInt8(recvData[3])
        if group == Int(0xFC)&&UInt8(recvData[3])==0x01
        {
            var tmpfcsensor01 = fcsensor01
            var range1 = recvData.index(recvData.startIndex, offsetBy: 12)
            var range2 = recvData.index(recvData.startIndex, offsetBy: 21)
            tmpfcsensor01.devicetype=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            
            range1 = recvData.index(recvData.startIndex, offsetBy: 22)
            range2 = recvData.index(recvData.startIndex, offsetBy: 37)
            tmpfcsensor01.deviceNB=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            
            range1 = recvData.index(recvData.startIndex, offsetBy: 38)
            range2 = recvData.index(recvData.startIndex, offsetBy: 59)
            tmpfcsensor01.mainboard=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            range1 = recvData.index(recvData.startIndex, offsetBy: 60)
            range2 = recvData.index(recvData.startIndex, offsetBy: 81)
            tmpfcsensor01.controlboard=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            range1 = recvData.index(recvData.startIndex, offsetBy: 82)
            range2 = recvData.index(recvData.startIndex, offsetBy: 97)
            tmpfcsensor01.mainboardNB=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            range1 = recvData.index(recvData.startIndex, offsetBy: 98)
            range2 = recvData.index(recvData.startIndex, offsetBy: 113)
            tmpfcsensor01.controlboardNB=recvData.subdata(in: Range(range1..<range2)).base64EncodedString()
            
            tmpfcsensor01.inputTimes=Int(recvData[114])+256*Int(recvData[115])+256*256*Int(recvData[116])+256*256*256*Int(recvData[117])
            tmpfcsensor01.waterRate=Float(recvData[122])
            tmpfcsensor01.errorNB=Int(recvData[123])
            tmpfcsensor01.errorFlag=Int(recvData[124])+256*Int(recvData[125])+256*256*Int(recvData[126])+256*256*256*Int(recvData[127])
            if Int(recvData[1])+256*Int(recvData[2])==160 {
                var pIndex = 128
                
                tmpfcsensor01.RTCDate=NSDate.init(year: 2000+Int(recvData[pIndex]), month: Int(recvData[pIndex+1]), day: Int(recvData[pIndex+2]), hour: Int(recvData[pIndex+3]), minute: Int(recvData[pIndex+4]), second: Int(recvData[pIndex+5])) as Date
                pIndex=pIndex+6
                tmpfcsensor01.lastCardDate=NSDate.init(year: 2000+Int(recvData[pIndex]), month: Int(recvData[pIndex+1]), day: Int(recvData[pIndex+2]), hour: Int(recvData[pIndex+3]), minute: Int(recvData[pIndex+4]), second: Int(recvData[pIndex+5])) as Date
                pIndex=pIndex+6
                range1 = recvData.index(recvData.startIndex, offsetBy: pIndex)
                range2 = recvData.index(recvData.startIndex, offsetBy: pIndex+3)
                tmpfcsensor01.lastCardNB=recvData.subdata(in: Range(range1..<range2))
                pIndex=pIndex+4
                tmpfcsensor01.remindWater=Int(recvData[pIndex])+256*Int(recvData[pIndex+1])+256*256*Int(recvData[pIndex+2])+256*256*256*Int(recvData[pIndex+3])
                
            }
            fcsensor01=tmpfcsensor01
        }
        if group == Int(0xFC)&&UInt8(recvData[3])==0x02
        {
            fcsensor02IsSuccess=true
        }
        if group == Int(0xFB) {
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
                tmpSensor.Temperature = Float(Int(recvData[10])+256*Int(recvData[11]))/10.0
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
        let needData=self.MakeWoodyBytes(code: 0xfa, Opcode: 0x01, data: Data())
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
        let needData=self.MakeWoodyBytes(code: 0xfa, Opcode: 0x01, data: Data())
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
        let len = 13+data.count
        var dataNeed = Data.init(bytes: [0xfa,UInt8(len%256),UInt8(len/256),0x1])
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
        return "设备名称:\(self.settings.name!)\n 连接状态:\(self.connectStatus)\n 净化前TDS:\(self.sensor.TDS_Before)\n 净化后TDS:\(self.sensor.TDS_After)\n 水温:\(self.sensor.Temperature)\n 电源:\(self.status.Power)\n 加热:\(self.status.Hot)\n 制冷:\(self.status.Cool)\n 剩余水值:\(self.fcsensor01.remindWater)\nRTC:\(self.fcsensor01.RTCDate)\n最后刷卡时间:\(self.fcsensor01.lastCardDate)\n最后刷卡卡号:\(self.fcsensor01.lastCardNB)\nFC01:\(self.fcsensor01)\n FC02:\(self.fcsensor02IsSuccess ? "收到":"")\n"
    }
    
}
