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
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(settingInfo)\n"
    }
    
    override var description: String {
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(settingInfo)\n"
    }

}

public func !=<A, B, C, D, E,F,G,H,I>(lhs: (A, B, C, D, E,F,G,H,I), rhs: (A, B, C, D, E,F,G,H,I)) -> Bool where A : Equatable, B : Equatable, C : Equatable, D : Equatable, E : Equatable,F : Equatable, G : Equatable, H : Equatable , I : Equatable{
    
    return lhs.0 != rhs.0 && lhs.1 != rhs.1 && lhs.2 != rhs.2 && lhs.3 != rhs.3 && lhs.4 != rhs.4 && lhs.5 != rhs.5 && lhs.6 != rhs.6 && lhs.7 != rhs.7 && lhs.8 != rhs.8
    
}
