//
//  OznerDataManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/23.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
import SQLite

class OznerDataManager: NSObject {
    private static var _instance: OznerDataManager! = nil
    static var instance: OznerDataManager! {
        get {
            if _instance == nil {
                _instance = OznerDataManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    private let deviceID = Expression<String>("deviceID")
    private let deviceMac = Expression<String>("deviceMac")
    private let deviceType = Expression<String>("deviceType")
    private let productID = Expression<String>("productID")
    private let wifiVersion = Expression<Int>("wifiVersion")
    
    private let setting = Expression<String?>("setting")
    
    private let deviceTable = Table("deviceTable")
    
    private var db:Connection?
    func setSQL(dbName:String) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!+"/OznerLibrary2"+dbName+".sqlite3"
        db = try? Connection(path)
        //判断表是否存在,不存在就创建
        let _=try? db!.run(deviceTable.create(ifNotExists: true){
            t in
            t.column(deviceID, primaryKey: true)
            t.column(deviceMac)
            t.column(deviceType)
            t.column(productID)
            t.column(wifiVersion)
            t.column(setting)
        })
        
    }
    func addDeviceToSQL(device:OznerBaseDevice)  {
        let _=try? db!.run(deviceTable.insert(or: .replace, deviceID <- device.deviceInfo.deviceID, deviceMac <- device.deviceInfo.deviceMac, deviceType <- device.deviceInfo.deviceType, productID <- device.deviceInfo.productID, wifiVersion <- device.deviceInfo.wifiVersion, setting <- device.settings.toJsonString()))
    }
    func deleteDeviceFromSQL(Identifier:String)  {
        let alice = deviceTable.filter(deviceID == Identifier)
        do {
            if try db!.run(alice.delete()) > 0 {
                print("deleted \(Identifier) success")
            } else {
                print("\(Identifier) not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
        
    }
    func updateDeviceToSQL(device:OznerBaseDevice)  {
        let alice = deviceTable.filter(deviceID == device.deviceInfo.deviceID)
        do {
            if try db!.run(alice.update(deviceID <- device.deviceInfo.deviceID, deviceMac <- device.deviceInfo.deviceMac, deviceType <- device.deviceInfo.deviceType, productID <- device.deviceInfo.productID, wifiVersion <- device.deviceInfo.wifiVersion, setting <- device.settings.toJsonString())) > 0 {
                print("updated alice")
            } else {
                print("alice not found")
            }
        } catch {
            print("update failed: \(error)")
        }
    }
    func getADeviceFromSQL(Identifier:String)->OznerBaseDevice?  {
        var tmpdevice:OznerBaseDevice?
        for dev in try! db!.prepare(deviceTable) {
            if Identifier == dev[deviceID] {
                let deviceinfo=OznerDeviceInfo(deviceID: dev[deviceID], deviceMac: dev[deviceMac], deviceType: dev[deviceType], productID: dev[productID], wifiVersion: dev[wifiVersion])
                tmpdevice = OznerBaseDevice(deviceinfo: deviceinfo, Settings: dev[setting]!)
                break
            }
            
            
        }
        return tmpdevice
    }
    func getAllDevicesFromSQL() -> [String:OznerBaseDevice] {
        var tmpDevices = [String:OznerBaseDevice]()
        
        for dev in try! db!.prepare(deviceTable) {
            let deviceinfo=OznerDeviceInfo(deviceID: dev[deviceID], deviceMac: dev[deviceMac], deviceType: dev[deviceType], productID: dev[productID], wifiVersion: dev[wifiVersion])
            tmpDevices[deviceinfo.deviceID]=createDevice(deviceInfo: deviceinfo, setting: dev[setting])
        }
        return tmpDevices
    }
    func createDevice(deviceInfo:OznerDeviceInfo,setting:String?) -> OznerBaseDevice {
        let  deviceClass = ProductInfo.getDeviceClassFromProductID(productID: deviceInfo.productID)
        var tmpdev:OznerBaseDevice!
        switch  deviceClass{
        case .Cup:
            tmpdev=Cup(deviceinfo: deviceInfo, Settings: setting)
        case .TwoCup:
            tmpdev = TwoCup(deviceinfo: deviceInfo, Settings: setting)
        case .Tap,.TDSPan:
            tmpdev = Tap(deviceinfo: deviceInfo, Settings: setting)
        case .WaterPurifier_Wifi:
            tmpdev = WaterPurifier_Wifi(deviceinfo: deviceInfo, Settings: setting)
        case .WaterPurifier_Blue:
            tmpdev = WaterPurifier_Blue(deviceinfo: deviceInfo, Settings: setting)
        case .WaterReplenish:
            tmpdev = WaterReplenish(deviceinfo: deviceInfo, Settings: setting)
        case .AirPurifier_Blue:
            tmpdev = AirPurifier_Blue(deviceinfo: deviceInfo, Settings: setting)
        case .AirPurifier_Wifi:
            tmpdev = AirPurifier_Wifi(deviceinfo: deviceInfo, Settings: setting)
        case .Electrickettle_Blue:
            tmpdev = Electrickettle_Blue(deviceinfo: deviceInfo, Settings: setting)
        case .WashDush_Wifi:
            tmpdev = WashDush_Wifi(deviceinfo: deviceInfo, Settings: setting)
        }
        return tmpdev
    }
}
