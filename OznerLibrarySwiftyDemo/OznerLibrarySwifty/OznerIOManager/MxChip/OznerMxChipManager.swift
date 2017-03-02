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
        OznerEasyLink.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate, ssid: ssid, password: password)
    }
    //取消配对
    func canclePair() {
        OznerEasyLink.instance.canclePair()
    }
       
    //获取已配对的设备IO，或者设备重新连接调用
    func getIO(identifier:String,type:String) -> OZMxChipIO? {
        if let tmpIO = IODics[identifier] {
            return tmpIO
        }else{
            var chanelStr = identifier.replacingOccurrences(of: ":", with: "").lowercased()
            chanelStr=type+"/"+chanelStr
            IODics[identifier] = OZMxChipIO(identifier: chanelStr)
            return IODics[identifier]
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
