//
//  OznerMxChipManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科库管理中心
class OznerMxChipManager: NSObject {

    private var IODics=[String:OZMxChipIO]()
    private static var _instance: OznerMxChipManager! = nil    
    static var instance: OznerMxChipManager! {
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
   
    
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {
        //let weakSelf=self
        let myCustomQueue = DispatchQueue.main;
        myCustomQueue.async {//2.0配网
            print("开始2.0配网")
            OznerEasyLink_V2.instance.starPair(password: password, outTime: 90, successBlock: { (deviceinfo) in
                //weakSelf.deviceInfo=deviceinfo
                DispatchQueue.main.async {
                    print("\n配网成功\n\(deviceinfo)")
                    OznerEasyLink_V1.instance.canclePair()
                }
                
            }, failedBlock: { (error) in
                DispatchQueue.main.async {
                    print("配网失败:"+error.localizedDescription)
                }
                
            })
        }
        myCustomQueue.async{//1.0配网
            print("开始1.0配网")
            OznerEasyLink_V1.instance.starPair(deviceClass: deviceClass, ssid: ssid, password: password, timeOut: 90, successBlock: { (deviceinfo) in
                OznerEasyLink_V2.instance.canclePair()
                print(deviceinfo)
                pairDelegate?.OznerPairSucceed(deviceInfo: deviceinfo)
            }, failedBlock: { (error) in
                print(error)
            })
        }
    }
    //取消配对
    func canclePair() {
        OznerEasyLink_V1.instance.canclePair()
        OznerEasyLink_V2.instance.canclePair()
    }
       
    //获取已配对的设备IO，或者设备重新连接调用
    func getIO(deviceinfo:OznerDeviceInfo) -> OZMxChipIO? {
        if let tmpIO = IODics[deviceinfo.deviceID] {
            return tmpIO
        }else{
            IODics[deviceinfo.deviceID] = OZMxChipIO(deviceinfo: deviceinfo)
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
}
