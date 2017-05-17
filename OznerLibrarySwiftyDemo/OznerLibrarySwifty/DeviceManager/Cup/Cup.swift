//
//  Cup.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/3.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

//水杯设置共用字段，作用，本地保存和发送到设备
let remindEnableOfCupSetting = "remindEnableOfCupSetting"//"0","1"
let remindStartOfCupSetting = "remindStartOfCupSetting"
let remindEndOfCupSetting = "remindEndOfCupSetting"
let remindIntervalOfCupSetting = "remindIntervalOfCupSetting"
let haloColorOfCupSetting = "haloColorOfCupSetting"
let haloModeOfCupSetting = "haloModeOfCupSetting"
let haloSpeedOfCupSetting = "haloSpeedOfCupSetting"
let haloConterOfCupSetting = "haloConterOfCupSetting"
let beepModeOfCupSetting = "beepModeOfCupSetting"

class Cup: OznerBaseDevice {

    //添加个性字段
    //对外只读，对内可读写
    private(set) var sensor:(Battery:Int,Temperature:Int,Volume:Int,TDS:Int)=(0,0,0,0){
        didSet{
            if sensor != oldValue {
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    private(set) var platInfo:(Platform:String,Firmware:NSDate)=("",NSDate()){
        didSet{
            if platInfo != oldValue {
                //self.delegate?.OznerDeviceSensorUpdate?(identifier: self.identifier)
            }
        }
    }
    private(set) var records:OznerCupRecords!{//day:tds
        didSet{
            if records != oldValue {
                self.delegate?.OznerDeviceRecordUpdate?(identifier: self.deviceInfo.deviceID)
            }
        }
    }
    required init(deviceinfo: OznerDeviceInfo, Settings settings: String?) {
        super.init(deviceinfo: deviceinfo, Settings: settings)
        records=OznerCupRecords(Identifier: deviceinfo.deviceID)//初始化水杯记录
        //饮水量记录
        var tmpVolume = 0
        for item in records.getRecord(type: CupRecordType.day) {
            tmpVolume+=item.value.Volume
        }
        sensor.Volume=tmpVolume
        
    }
    override func OznerBaseIORecvData(recvData: Data) {
        switch UInt8(recvData[0]) {
        case 0x82://opCode_ReadInfoRet
            _=recvData.base64EncodedString()
            _=String(bytes: recvData[1...3], encoding: String.Encoding.ascii)
            _=NSDate(year: Int(recvData[1])+2000, month: Int(recvData[2]), day: Int(recvData[3]), hour: Int(recvData[4]), minute: Int(recvData[5]), second: Int(recvData[6])) as NSDate
        case 0xA2://opCode_ReadSensorRet
            var tmpBattery=Int(recvData[3])+16*16*Int(recvData[4])
            tmpBattery=tmpBattery==65535 ? 0:tmpBattery
            tmpBattery = tmpBattery>3000 ? Int(100*(Double(tmpBattery)-3000.0)/(4200.0-3000.0)):0
            tmpBattery=min(100, tmpBattery)
            let temperat = Int(recvData[7])+16*16*Int(recvData[8])
            //let weight = Int(recvData[11])+16*16*Int(recvData[12])
            let tds = Int(recvData[15])+16*16*Int(recvData[16])
            sensor=(tmpBattery,temperat,sensor.Volume,tds)
        case 0xA4://opCode_ReadRecordRet
            let tmpDate=NSDate(year: Int(recvData[1])+2000, month: Int(recvData[2]), day: Int(recvData[3]), hour: Int(recvData[4]), minute: Int(recvData[5]), second: Int(recvData[6])) as NSDate
            let tmpTDS = Int(recvData[17])+256*Int(recvData[18])
            let tmpTemperature = Int(recvData[15])+256*Int(recvData[16])
            let tmpVolume = Int(recvData[9])+256*Int(recvData[10])
            if tmpVolume>0 {
                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: tmpDate as Date, Tds: tmpTDS, Temperature: tmpTemperature, Volume: tmpVolume, Updated: false)
                sensor.Volume=sensor.Volume+tmpVolume
                self.delegate?.OznerDeviceRecordUpdate?(identifier: self.deviceInfo.deviceID)
            }
            
        default:
            break
        }
    }
    override func doWillInit() {
        sendTime()
        sendReadInfo()
        sendSetting()
        self.SendDataToDevice(sendData: Data.init(bytes: [0x21])) { (error) in}//opCode_Foreground
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
    private func sendReadInfo()  {
        let data = Data.init(bytes: [
            0x82])
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    private func sendSetting()  {
        var data = Data.init(bytes: [
            0x11])
        if self.settings.GetValue(key: remindEnableOfCupSetting, defaultValue: "1")=="1"
        {
            let remindStart = CLongLong(self.settings.GetValue(key: remindStartOfCupSetting, defaultValue: "\(9*3600)"))
            let remindEnd = CLongLong(self.settings.GetValue(key: remindEndOfCupSetting, defaultValue: "\(9*3600)"))
            data.append(OznerTools.dataFromInt(number: remindStart!, length: 4))
            data.append(OznerTools.dataFromInt(number: remindEnd!, length: 4))
        }else{
            data.append(OznerTools.dataFromInt(number: 0, length: 4))
            data.append(OznerTools.dataFromInt(number: 0, length: 4))
        }
        data.append(UInt8(self.settings.GetValue(key: remindIntervalOfCupSetting, defaultValue: "15"))!)
        
        let haloColor = CLongLong(self.settings.GetValue(key: haloColorOfCupSetting, defaultValue: "4278255360"))
        
        data.append(OznerTools.dataFromInt(number: haloColor!, length: 4))
        data.append(UInt8(self.settings.GetValue(key: haloModeOfCupSetting, defaultValue: "\(0x3)"))!)
        data.append(UInt8(self.settings.GetValue(key: haloSpeedOfCupSetting, defaultValue: "\(0x80)"))!)
        data.append(UInt8(self.settings.GetValue(key: haloConterOfCupSetting, defaultValue: "\(15)"))!)
        data.append(UInt8(self.settings.GetValue(key: beepModeOfCupSetting, defaultValue: "\(0x80)"))!)
        data.append(0)
        data.append(0)
        self.SendDataToDevice(sendData: data) { (error) in}
    }
    override func repeatFunc() {
        if NSDate().second()%2==0 {
            self.SendDataToDevice(sendData: Data.init(bytes: [0x14])) { (error) in}//opCode_ReadTapRecord
        }else{
            self.SendDataToDevice(sendData: Data.init(bytes: [0x12])) { (error) in}//opCode_ReadSensor
        }
    }
    override func describe() -> String {
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(self.sensor)\n"
    }
}
