//
//  OznerManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//配对成功失败代理
public protocol OznerPairDelegate {
     func OznerPairFailured(error:Error) -> Void
     func OznerPairSucceed(deviceInfo:OznerDeviceInfo) -> Void
}
//主要是暴露给外部调用的方法或代理，单例模式
public class OznerManager: NSObject {
    private static var _instance: OznerManager! = nil
   public static var instance: OznerManager! {
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
   public var currentDevice:OznerBaseDevice?=nil{
        didSet{
            if oldValue?.deviceInfo.deviceID != currentDevice?.deviceInfo.deviceID {
                print(currentDevice?.deviceInfo.des() ?? "")
                oldValue?.isCurrentDevice=false
                oldValue?.delegate=nil
                currentDevice?.isCurrentDevice=true
            }
            
        }
    }
    
    //wifi判断
   public var wifiReachability:Reachability!
  public  var owner:String!
    
    //设置账户信息
   public func setOwner(Owner:String,UserToken:String) {
        //初始化
        //监测Wi-Fi连接状态
        wifiReachability = Reachability.forLocalWiFi()
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        wifiReachability.reachableOnWWAN = false
        wifiReachability.startNotifier()
        //在需要的地方开启Wi-Fi变化监听

//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(reachabilityChanged),
//            name: NSNotification.Name.reachabilityChanged,
//            object: nil
//        )
        
       
        //Owner：数据库名称,userToken：ayla会用到
        owner=Owner
        OznerDeviceManager.instance.setOwner(Owner: Owner, UserToken: UserToken)
        //初始化第一个设备为当前设备
        let devices = getAllDevices()
        
        if (devices?.count)!>0 {
            currentDevice=devices?[0]
            print(currentDevice?.deviceInfo ?? "")
        }
    }
    
    //增删改查设备方法
  public  func saveDevice(device:OznerBaseDevice) {
        OznerDeviceManager.instance.saveDevice(device: device)
//        switch true {
//        case device.isKind(of: Tap.classForCoder())||device.isKind(of: Cup.classForCoder()):
//            device.doWillInit()//保存设置到设备、如定时检测，灯带颜色等
//        default:
//            break
//        }
    }
  public  func deleteDevice(device:OznerBaseDevice) {
        OznerDeviceManager.instance.deleteDevice(device: device)
        let devices = OznerDeviceManager.instance.getAllDevices()        
        OznerManager.instance.currentDevice = (devices?.count)!>0 ? devices?[0]:nil
    }
  public  func getDevice(identifier:String) -> OznerBaseDevice? {
        return OznerDeviceManager.instance.getDevice(identifier: identifier)
    }
   public func getAllDevices() -> [OznerBaseDevice]! {
        return OznerDeviceManager.instance.getAllDevices()
    }
    
   public func createDevice(scanDeviceInfo:OznerDeviceInfo,setting:String?) -> OznerBaseDevice {
        return OznerDeviceManager.instance.createDevice(scanDeviceInfo: scanDeviceInfo, setting: setting)
    }
    //配对操作
    //开始配对
   public func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {
        OznerIOManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate,ssid: ssid,password: password)
    }
    //取消配对
   public func canclePair() {
        OznerIOManager.instance.canclePair()
    }
    //获取当前连接的无线网名称
   public func fetchCurrentSSID(handler:((String?)->Void)!) {
        handler(EASYLINK.ssidForConnectedNetwork())
    }
    
    
    
    
//    func reachabilityChanged(notification: NSNotification) {
//        if wifiReachability.isReachableViaWiFi() || wifiReachability.isReachableViaWWAN() {
//            print("Service avalaible!!!")
//        } else {
//            print("No service avalaible!!!")
//        }
//    }
    //蓝牙判断
    
}
