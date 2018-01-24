//
//  OznerMxChipManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科库管理中心
public class OznerMxChipManager: NSObject {

    private var IODics=[String:OZMxChipIO]()
    private static var _instance: OznerMxChipManager! = nil    
   public static var instance: OznerMxChipManager! {
        get {
            if _instance == nil {
                
                _instance = OznerMxChipManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    //开始配对
   
    private var pairTimer:Timer?
    private let pairOutTime=60//配网超时时间
  public  var PairDelegate:OznerPairDelegate!
   public var haveSuccessed = false
   public func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {
        //初始化
        let weakself=self
        haveSuccessed=false
        PairDelegate=pairDelegate
        
        //加个是否连上Wi-Fi判断
        if OznerManager.instance.wifiReachability.currentReachabilityStatus() != NetworkStatus.ReachableViaWiFi {
            PairDelegate.OznerPairFailured(error: NSError(domain: "手机请连接上Wi-Fi网络再进行配网！！！", code: 1, userInfo: nil))
            return
        }
        //加个是否连上Wi-Fi判断
        if ssid==nil||ssid=="" {
            PairDelegate.OznerPairFailured(error: NSError(domain: "Wi-Fi名称不能为空", code: 1, userInfo: nil))
            return
        }
        
        //配网超时
        pairTimer?.invalidate()
        pairTimer=Timer.scheduledTimer(timeInterval: TimeInterval(pairOutTime), target: self, selector: #selector(pairFailed), userInfo: nil, repeats: false)
        //1.0、2.0同时配网
        let myCustomQueue = DispatchQueue.main
        myCustomQueue.async {//2.0配网            
            OznerEasyLink_V2.instance.starPair(deviceClass: deviceClass,password: password, outTime: weakself.pairOutTime, successBlock: { (deviceinfo) in
                print("2.0配网成功")
                weakself.pairSuccess(deviceInfo: deviceinfo)
            }, failedBlock: { (error) in
                print("2.0配网失败:"+error.localizedDescription)
            })
        }
        myCustomQueue.async{//1.0配网
            OznerEasyLink_V1.instance.starPair(deviceClass: deviceClass, ssid: ssid, password: password, timeOut: weakself.pairOutTime, successBlock: { (deviceinfo) in
                print("1.0配网成功")
                weakself.pairSuccess(deviceInfo: deviceinfo)

            }, failedBlock: { (error) in
                print("1.0配网失败"+error.localizedDescription)
            })
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
            self.PairDelegate.OznerPairFailured(error: NSError(domain: "未找到设备，配对超时", code: 2, userInfo: nil))
        }
    }
    //取消配对
   public func canclePair() {
        pairTimer?.invalidate()
        pairTimer = nil
        OznerEasyLink_V1.instance.canclePair()
        OznerEasyLink_V2.instance.canclePair()
    }
       
    //获取已配对的设备IO，或者设备重新连接调用
   public func getIO(deviceinfo:OznerDeviceInfo) -> OZMxChipIO? {
        if let tmpIO = IODics[deviceinfo.deviceID] {
            return tmpIO
        }else{
            IODics[deviceinfo.deviceID] = OZMxChipIO(deviceinfo: deviceinfo)
            return IODics[deviceinfo.deviceID]
        }
    }
    //删除设备时解除绑定的IO
   public func deleteIO(identifier:String) {
        if let tmpIO = IODics[identifier] {
            tmpIO.destroySelf()
            IODics.removeValue(forKey: identifier)
        }
    }
    
  public  func foundDeviceIsExist(mac:String) -> Bool {//判断设备是否已存在
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
