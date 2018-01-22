//
//  OznerDeviceManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//设备管理类，对所有设备的增删改查等操作

public class OznerDeviceManager: NSObject {

    private var devices:[String:OznerBaseDevice]!
    private static var _instance: OznerDeviceManager! = nil
    public static var instance: OznerDeviceManager! {
        get {
            if _instance == nil {
                _instance = OznerDeviceManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
   public var owner:String!
   public var userToken:String!//ayla用到
   public func setOwner(Owner:String,UserToken:String) {
        owner=Owner
        userToken=UserToken
        OznerDataManager.instance.setSQL(dbName: Owner)//设置数据库
        //取设备信息，加载设备
        devices=OznerDataManager.instance.getAllDevicesFromSQL()
    }
   public func saveDevice(device:OznerBaseDevice) {
        devices[device.deviceInfo.deviceID]=device
        OznerDataManager.instance.addDeviceToSQL(device: device)
    }
   public func deleteDevice(device:OznerBaseDevice) {
        devices.removeValue(forKey: device.deviceInfo.deviceID)
        OznerIOManager.instance.deleteIO(identifier: device.deviceInfo.deviceID)
        OznerDataManager.instance.deleteDeviceFromSQL(Identifier: device.deviceInfo.deviceID)
        
    }
   public func getDevice(identifier:String) -> OznerBaseDevice? {
        return devices[identifier]
    }
   public func getAllDevices() -> [OznerBaseDevice]! {
        var tmpArr = [OznerBaseDevice]()
        for (_,value) in devices {
            tmpArr.append(value)
        }
        return tmpArr
    }
   public func createDevice(scanDeviceInfo:OznerDeviceInfo,setting:String?) -> OznerBaseDevice {
        if let device=devices[scanDeviceInfo.deviceID] {
            return device
        }
        else{
            return OznerDataManager.instance.createDevice(deviceInfo: scanDeviceInfo, setting: setting)
        }
    }
}
