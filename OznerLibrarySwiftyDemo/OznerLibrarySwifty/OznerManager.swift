//
//  OznerManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//配对成功失败代理
protocol OznerPairDelegate {
     func OznerPairFailured(error:Error) -> Void
     func OznerPairSucceed(devices:[String:(type:String,instance:Int)]) -> Void
}
//主要是暴露给外部调用的方法或代理，单例模式
class OznerManager: NSObject {
    private static var _instance: OznerManager! = nil
    static var instance: OznerManager! {
        get {
            if _instance == nil {
                _instance = OznerManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
   
    //当前设备
    var currentDevice:OznerBaseDevice?=nil{
        didSet{
            if oldValue?.identifier != currentDevice?.identifier {
                oldValue?.isCurrentDevice=false
                oldValue?.delegate=nil
                currentDevice?.isCurrentDevice=true
            }
            
        }
    }
    var owner:String!
    
    //设置账户信息
    func setOwner(Owner:String,UserToken:String) {//Owner：数据库名称,userToken：ayla会用到
        owner=Owner
        OznerDeviceManager.instance.setOwner(Owner: Owner, UserToken: UserToken)
        //初始化第一个设备为当前设备
        let devices = getAllDevices()
        if (devices?.count)!>0 {
            currentDevice=devices?[0]
        }
        
        
    }
    
    //增删改查设备方法
    func saveDevice(device:OznerBaseDevice) {
        OznerDeviceManager.instance.saveDevice(device: device)
        switch true {
        case device.isKind(of: Tap.classForCoder())||device.isKind(of: Cup.classForCoder()):
            device.doWillInit()//保存设置到设备、如定时检测，灯带颜色等
        default:
            break
        }
    }
    func deleteDevice(device:OznerBaseDevice) {
        OznerDeviceManager.instance.deleteDevice(device: device)
        OznerManager.instance.currentDevice=nil
    }
    func getDevice(identifier:String) -> OznerBaseDevice? {
        return OznerDeviceManager.instance.getDevice(identifier: identifier)
    }
    func getAllDevices() -> [OznerBaseDevice]! {
        return OznerDeviceManager.instance.getAllDevices()
    }
    
    func createDevice(identifier:String,type:String,setting:String?) -> OznerBaseDevice {
        return OznerDeviceManager.instance.createDevice(identifier: identifier, type: type, setting: setting)
    }
    //配对操作
    //开始配对
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {
        OznerIOManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate,ssid: ssid,password: password)
    }
    //取消配对
    func canclePair() {
        OznerIOManager.instance.canclePair()
    }
    //获取当前连接的无线网名称
    func getCurrentSsidName() -> String {
        
        return OznerEasyLink.instance.getSsid()
    }
}
