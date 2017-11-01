//
//  Electrickettle_Blue.swift
//  OzneriFamily
//
//  Created by ZGY on 2017/7/17.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/7/17  下午4:54
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

import UIKit

class Electrickettle_Blue: OznerBaseDevice {
    
    private(set)  var settingInfo:(isHot:Int,temp:Int,tds:Int,orderFunction:Int,orderSec:Int,orderTemp:Int,hotPattern:Int,hotTemp:Int,hotTime:Int) = (0,0,0,0,0,0,0,0,0) {
        
        didSet {
            
            if settingInfo != oldValue {
                self.delegate?.OznerDeviceSensorUpdate!(identifier: self.deviceInfo.deviceID)
            }
            
        }
        
    }
    
    override func OznerBaseIORecvData(recvData: Data) {
        
        switch UInt8(recvData[0]) {
            
            case 0x21:
                let isHot = recvData.subInt(starIndex: 1, count: 1)
                let temp = recvData.subInt(starIndex: 2, count: 1)
                let tds = recvData.subInt(starIndex: 3, count: 2)
                
                let orderFunction = recvData.subInt(starIndex: 5, count: 1)
                let orderSec = recvData.subInt(starIndex: 6, count: 2)
                let orderTemp = recvData.subInt(starIndex: 8, count: 1)

                let hotPattern = recvData.subInt(starIndex: 9, count: 1)
                let hotTemp = recvData.subInt(starIndex: 10, count: 1)
                let hotTime = recvData.subInt(starIndex: 11, count: 2)

//                let isHot = UInt8(recvData[1])
//                let temp = UInt8(recvData[2])
//                let tds = recvData.subInt(starIndex: 3, count: 2)
//                
//                let orderFunction = UInt8( recvData[5])
//                let orderSec = recvData.subInt(starIndex: 7, count: 2)
//                let orderTemp = UInt8( recvData[9])
//                let hotPattern = UInt8( recvData[10])
//                let hotTemp = UInt8( recvData[11])
//                let hotTime = recvData.subInt(starIndex: 12, count: 2)
                
//                settingInfo = (Int(isHot),Int(temp),tds,Int(orderFunction),orderSec,Int(orderTemp),Int(hotPattern),Int(hotTemp),hotTime)
                settingInfo = (isHot,temp,tds,orderFunction,orderSec,orderTemp,hotPattern,hotTemp,hotTime)
                
                break
//            case 0x33:
//                break
            default:
                break
            
        }
        
        
    }
    
//    private func calcSum(data:Data)->UInt8{
//        var sum = 0
//        for item in data {
//            sum+=Int(item)
//        }
//        return UInt8(sum%256)
//    }
    
    
    override func repeatFunc() {
        
        requestInfo()
        
    }
    
    
    func setSetting(_ setInfo:(hotTemp:Int,hotTime:Int,boilTemp:Int,hotFunction:Int,orderFunction:Int,orderSec:Int)) -> Bool{
        
        var data = Data.init(bytes: [0x33])
        data.append(UInt8(setInfo.hotTemp))
        data.append(OznerTools.dataFromInt16(number: UInt16(setInfo.hotTime)))
        data.append(UInt8(setInfo.boilTemp))
        data.append(UInt8(setInfo.hotFunction))
        data.append(UInt8(setInfo.orderFunction))
        data.append(OznerTools.dataFromInt16(number: UInt16(setInfo.orderSec)))
//        let data = Data.init(bytes: [0x33,UInt8(setInfo.hotTemp),UInt8(setInfo.hotTime),UInt8(setInfo.boilTemp),UInt8(setInfo.hotFunction),UInt8(setInfo.orderFunction),UInt8(setInfo.orderSec)])
        self.SendDataToDevice(sendData: data) { (error) in
            print("---------------")
        }
        sleep(UInt32(0.3))
        
        return true
        
    }
    
    func setHotFunction(_ function:Int) -> Bool{
        
        let data = Data.init(bytes: [0x34,UInt8(function)])
        
        self.SendDataToDevice(sendData: data) { (error) in
            
        }
        sleep(UInt32(0.3))
        
        return true
        
    }
    
    fileprivate func requestInfo() {
        
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20]), CallBack: nil)
        
    }
    
    override func describe() -> String {
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(settingInfo)\nOTA进度:\(currenLength)/\(sumLength)"
    }
    
    override var description: String {
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(settingInfo)\nOTA进度:\(currenLength)/\(sumLength)"
    }
    
    
    //OTA
    func twoCupClearUpgrade() {
        
        let data = Data.init(bytes: [0xC2])
        
        self.SendDataToDevice(sendData: data) { (error) in
            if error != nil {
                
                print("OTA失败")
                
            }
        }
        
        sleep(2)
        
    }
    
    var sumLength:Int = 0
    var currenLength:Int = 0
    
    func startOTA() {
        
        sleep(1)

        let filePath = Bundle.main.path(forResource: "ble", ofType: "bin")
//        let filePath = "/Users/macpro-hz/Desktop/workSpace/个人项目/ATAnimatons/ATAnimatons/GYLineView/ble.bin"
        
        if filePath == nil {
            appDelegate.window?.noticeOnlyText("请检查文件是否存在")
            return
        }
        
        let data = NSData(contentsOfFile: filePath!)!
        CheckSum(filePath!)
        var size = data.length
        
        if size > 127 * 1024 {
            print("文件过大")
            appDelegate.window?.noticeOnlyText("OTA失败 文件过大!")
            return
        }
        
        if (size % 256) != 0 {
            size = (size/256) * 256 + 256
        }
        
        
        var readBuffer:[UInt8] = [UInt8].init(repeating: 0xff, count: size)
        
        memset(&readBuffer, 0xff, size)
        memcpy(&readBuffer, data.bytes, data.length)
        
        let data123 = Data.init(bytes: readBuffer)
        
        sumLength = data123.count
        
        for  i in 0 ... size/16 {
            
            var sendData = Data.init(bytes: [0xC1])
            Thread.sleep(forTimeInterval: 0.1)
            print(i)
            //固件包位置
            sendData.append(OznerTools.dataFromInt(number: CLongLong(i), length: 2))
            
            //固件包大小
//            sendData.append(Data.init(bytes: [0x10]))
            sendData.append(data123.subData(starIndex: i * 16, count: 16))
            
            currenLength = i * 16
            
            if self.connectStatus != .Connected {
                currenLength = 0
                appDelegate.window?.noticeOnlyText("OTA失败 设备断开连接!")
                return
            }
            
            self.SendDataToDevice(sendData: sendData, CallBack: { (error) in
                print("============")
            })
            
//            更新UI界面
            updateSensor()
        }
        sleep(2)
        getBin()
        
    }
    
    func updateSensor() {
        
        self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
    }
    
    func getBin() {
        
        let filePath = Bundle.main.path(forResource: "ble", ofType: "bin")
        
        var sendData = Data.init(bytes: [0xC3])
        
        let data = NSData(contentsOfFile: filePath!)
        
        //0xC3
        let sum = data?.length
        
        if sum == nil {
            
            print("OTA失败 sum")
            return
        }
        sendData.append(OznerTools.dataFromInt(number: CLongLong(sum!), length: 4))
        
        sendData.append(OznerTools.dataFromInt(number: CLongLong(CheckSum), length: 4))
        
        self.SendDataToDevice(sendData: sendData, CallBack: nil)
        sleep(60)
        appDelegate.window?.noticeOnlyText("OTA成功!")
    }
    
    private var CheckSum:Int = 0
    func CheckSum(_ path:String) {
        
        let data = NSData(contentsOfFile: path)
        
        var size = (data?.length)!
        
        if size > 127 * 1024 {
            print("文件过大")
            return
        }
        
        if (size % 256) != 0 {
            size = (size/256) * 256 + 256
        }
        
        let inputStream = InputStream(fileAtPath: path)
        
        var readBuffer:[UInt8] = [UInt8].init(repeating: 0xff, count: size)
        
        memset(&readBuffer, 0xff, size)
        memcpy(&readBuffer, data?.bytes, (data?.length)!)

//        let allData = NSData.init(bytes: readBuffer, length: readBuffer.count)
        
        var temp:Int = 0
        let len = size/4 - 1
        
        for i in 0...len {
   
            temp = temp + Int(Helper.getBigHost(&readBuffer, index: Int32(i * 4)))
        }
        var tempMask = CLongLong(0x1FFFFFFFF);
        tempMask -= CLongLong(0x100000000)
        
        CheckSum = Int(CLongLong(temp) & tempMask)
        print(CheckSum)
        print(CheckSum & 0x7fffffff)
        inputStream?.close()// 1464111506 TwoCup//2146531471
        print(OznerTools.dataFromInt(number: CLongLong(CheckSum), length: 4))
        
    }
    
}

public func !=<A, B, C, D, E,F,G,H,I>(lhs: (A, B, C, D, E,F,G,H,I), rhs: (A, B, C, D, E,F,G,H,I)) -> Bool where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable,F : Equatable, G : Equatable, H : Equatable , I : Equatable{
    
    return lhs.0 != rhs.0 && lhs.1 != rhs.1 && lhs.2 != rhs.2 && lhs.3 != rhs.3 && lhs.4 != rhs.4 && lhs.5 != rhs.5 && lhs.6 != rhs.6 && lhs.7 != rhs.7 && lhs.8 != rhs.8
    
}
