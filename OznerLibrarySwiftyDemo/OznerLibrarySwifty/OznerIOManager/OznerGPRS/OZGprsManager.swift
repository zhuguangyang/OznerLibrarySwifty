//
//  OZGprsManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by ZGY on 2017/9/25.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/9/25  上午10:04
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

import UIKit

class OZGprsManager: NSObject {

    private var IODics=[String:OZGprsIO]()
    private static var _instance: OZGprsManager! = nil
    static var instance: OZGprsManager! {
        get {
            if _instance == nil {
                
                _instance = OZGprsManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    //开始配对
    
    private var pairTimer:Timer?
    private let pairOutTime=10//配网超时时间
    var PairDelegate:OznerPairDelegate!
    var haveSuccessed = false

    //SSID 为 Type pwd为Mac地址
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {
        //初始化
        haveSuccessed=false
        PairDelegate=pairDelegate
        
        //配网超时
        pairTimer?.invalidate()
        pairTimer=Timer.scheduledTimer(timeInterval: TimeInterval(pairOutTime), target: self, selector: #selector(pairFailed), userInfo: nil, repeats: false)
        //1.0、2.0同时配网
        let myCustomQueue = DispatchQueue.main
        myCustomQueue.async { //GPRS配网
            let deviceInfo = OznerDeviceInfo(deviceID: password!, deviceMac: password!, deviceType: ssid!, productID: "GPRS", wifiVersion: 3)
            
            if self.foundDeviceIsExist(mac: password!) {
                self.pairFailed()
            } else {
                self.pairSuccess(deviceInfo: deviceInfo)
            }
        }
    }
    
    private func pairSuccess(deviceInfo:OznerDeviceInfo) {
        print(deviceInfo)
        if !haveSuccessed {
            haveSuccessed=true
            canclePair()
            DispatchQueue.main.async {
                self.PairDelegate?.OznerPairSucceed(deviceInfo: deviceInfo)
            }
        }
    }
    @objc private func pairFailed() {
        canclePair()
        DispatchQueue.main.async {
            self.PairDelegate.OznerPairFailured(error: NSError(domain: "此设备已配对", code: 3, userInfo: nil))
        }
    }
    //取消配对
    func canclePair() {
        pairTimer?.invalidate()
        pairTimer = nil
        //此处可执行接触订阅
    }
    
    //获取已配对的设备IO，或者设备重新连接调用
    func getIO(deviceinfo:OznerDeviceInfo) -> OZGprsIO? {
        if let tmpIO = IODics[deviceinfo.deviceID] {
            return tmpIO
        }else{
            IODics[deviceinfo.deviceID] = OZGprsIO(deviceinfo: deviceinfo)
            return IODics[deviceinfo.deviceID]
        }
    }
    //删除设备时解除绑定的IO
    func deleteIO(identifier:String) {
        if let tmpIO = IODics[identifier] {
            tmpIO.destroySelf()
            IODics.removeValue(forKey: identifier)
        }
    }
    
    func foundDeviceIsExist(mac:String) -> Bool {//判断设备是否已存在
        var isExist = false
        for (_,value) in IODics {
            if value.deviceInfo.deviceMac==mac {
                isExist=true
                break
            }
        }
        return isExist
    }
    
    
}
