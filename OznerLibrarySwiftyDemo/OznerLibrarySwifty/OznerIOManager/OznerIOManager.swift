//
//  OznerIOManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科，Ayla，蓝牙等io管理中心
public class OznerIOManager: NSObject {

    private static var _instance: OznerIOManager! = nil
    public static var instance: OznerIOManager! {
        get {
            if _instance == nil {
                _instance = OznerIOManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    //获取已配对的设备IO，或者设备重新连接调用
   public func getIO(deviceinfo:OznerDeviceInfo) -> OznerBaseIO? {
        let ioType=ProductInfo.getIOTypeFromProductID(productID: deviceinfo.productID)
        switch ioType {
        case .Ayla:
            return OznerAylaManager.instance.getIO(deviceinfo: deviceinfo)
        case .MxChip:
            return OznerMxChipManager.instance.getIO(deviceinfo: deviceinfo)
        case .Blue:
            return nil
        case .BlueMxChip:
            return nil
        case .AylaMxChip:
            return nil
        }
    }
    //搜索新设备的IO进行配对
    private var currentPairDeviceClass:OZDeviceClass?=nil
 public   func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {//开始配对
        //以后需要解决Ayla和庆科的区别，目前只有庆科配对
        currentPairDeviceClass=deviceClass
        switch deviceClass.ioType {
        case .Blue://蓝牙配对
            break
        case .MxChip://Wifi配对，目前只有庆科，以后要解决庆科和Ayla区别问题
            OznerMxChipManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate,ssid: ssid,password: password)
        case .Ayla:
            OznerAylaManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate)
        case .AylaMxChip:
            break
        case .BlueMxChip:
            break
        }
    }
   public func canclePair() {//取消配对
        //以后需要解决Ayla和庆科的区别，目前只有庆科配对
        
        if currentPairDeviceClass != nil {
            switch (currentPairDeviceClass?.ioType)! {
            case .Blue:
                break
            case .MxChip:
                OznerMxChipManager.instance.canclePair()
            case .Ayla:
                OznerAylaManager.instance.canclePair()
            case .AylaMxChip:
                break
            case .BlueMxChip:
                break

            }
            currentPairDeviceClass=nil
        }
        
    }
    //删除设备时解除绑定的IO
   public func deleteIO(identifier:String) {
        OznerMxChipManager.instance.deleteIO(identifier: identifier)
        OznerAylaManager.instance.deleteIO(identifier: identifier)
        
    }
}
