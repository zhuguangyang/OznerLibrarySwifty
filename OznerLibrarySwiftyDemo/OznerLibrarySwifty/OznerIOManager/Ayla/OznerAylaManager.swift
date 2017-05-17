//
//  OznerAylaManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//Ayla库管理中心
class OznerAylaManager: NSObject {

    private static var _instance: OznerAylaManager! = nil
    static var instance: OznerAylaManager! {
        get {
            if _instance == nil {
                _instance = OznerAylaManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    //获取已配对的设备IO，或者设备重新连接调用
    func getIO(deviceinfo:OznerDeviceInfo) -> OZAylaIO? {
        return nil
    }
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?) {//开始配对
        
    }
    func canclePair() {//取消配对
        
    }
    //删除设备时解除绑定的IO
    func deleteIO(identifier:String) {
        
    }
}
