//
//  OznerIOManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科，Ayla，蓝牙等io管理中心
class OznerIOManager: NSObject {

    private static var _instance: OznerIOManager! = nil
    static var instance: OznerIOManager! {
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
    func getIO(identifier:String,type:String) -> OznerBaseIO? {
        let typeAtt=(DeviceConfigManager.deviceTypeInfo[type]?.typeAttr)!
        switch typeAtt {
        case OZTypeAttribute.Ayla:
            return OznerAylaManager.instance.getIO(identifier: identifier)
        case OZTypeAttribute.MxChip:
            return OznerMxChipManager.instance.getIO(identifier: identifier, type: type)
        case OZTypeAttribute.Bluetooth:
            return OznerBluetoothManager.instance.getIO(identifier: identifier)
        }
    }
    //搜索新设备的IO进行配对
    private var currentPairDeviceClass:OZDeviceClass?=nil
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {//开始配对
        //以后需要解决Ayla和庆科的区别，目前只有庆科配对
        currentPairDeviceClass=deviceClass
        switch deviceClass {
        case OZDeviceClass.Cup,.Tap,.AirPurifier_Blue,.WaterPurifier_Blue,.WaterReplenish://蓝牙配对
            OznerBluetoothManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate)
        case .AirPurifier_Wifi,.WaterPurifier_Wifi://Wifi配对，目前只有庆科，以后要解决庆科和Ayla区别问题
            OznerMxChipManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate,ssid: ssid,password: password)
        //case Ayla:
        //OznerAylaManager.instance.starPair(deviceClass: deviceClass, pairDelegate: pairDelegate)
        }
    }
    func canclePair() {//取消配对
        //以后需要解决Ayla和庆科的区别，目前只有庆科配对
        if currentPairDeviceClass != nil {
            switch currentPairDeviceClass! {
            case OZDeviceClass.Cup,.Tap,.AirPurifier_Blue,.WaterPurifier_Blue,.WaterReplenish:
                OznerBluetoothManager.instance.canclePair()
            case .AirPurifier_Wifi,.WaterPurifier_Wifi:
                OznerMxChipManager.instance.canclePair()
//            case .Ayla:
//                OznerAylaManager.instance.canclePair()
            }
            currentPairDeviceClass=nil
        }
        
    }
    //删除设备时解除绑定的IO
    func deleteIO(identifier:String) {
        OznerBluetoothManager.instance.deleteIO(identifier: identifier)
        OznerMxChipManager.instance.deleteIO(identifier: identifier)
        OznerAylaManager.instance.deleteIO(identifier: identifier)
        
    }
}
