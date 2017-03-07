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
    private let identifier = Expression<String>("identifier")
    private let type = Expression<String>("type")
    private let setting = Expression<String?>("setting")
    private let deviceTable = Table("deviceTable")
    private var db:Connection?
    func setSQL(dbName:String) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!+"/OznerLibrary"+dbName+".sqlite3"
        db = try? Connection(path)
        //判断表是否存在,不存在就创建
        let _=try? db!.run(deviceTable.create(ifNotExists: true){
            t in
            t.column(identifier, primaryKey: true)
            t.column(type)
            t.column(setting)
        })
        
    }
    func addDeviceToSQL(device:OznerBaseDevice)  {
        let _=try? db!.run(deviceTable.insert(or: .replace, identifier <- device.identifier,  type <- device.type, setting <- device.settings.toJsonString()))
    }
    func deleteDeviceFromSQL(Identifier:String)  {
        let alice = deviceTable.filter(identifier == Identifier)
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
        let alice = deviceTable.filter(identifier == device.identifier)
        //let achieveData = NSKeyedArchiver.archivedDataWithRootObject(device)
        do {
            if try db!.run(alice.update(identifier <- device.identifier, type <- device.type, setting <- device.settings.toJsonString())) > 0 {
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
            if Identifier == dev[identifier] {
                tmpdevice = OznerBaseDevice(Identifier: dev[identifier], Type: dev[type], Settings: dev[setting]!)
                break
            }
            
            
        }
        return tmpdevice
    }
    func getAllDevicesFromSQL() -> [String:OznerBaseDevice] {
        var tmpDevices = [String:OznerBaseDevice]()
        
        for dev in try! db!.prepare(deviceTable) {
            tmpDevices[dev[identifier]]=createDevice(identifier: dev[identifier], type: dev[type], setting: dev[setting])
        }
        return tmpDevices
    }
    func createDevice(identifier:String,type:String,setting:String?) -> OznerBaseDevice {
        let typeInfo = (DeviceConfigManager.deviceTypeInfo)[type]!
        var tmpdev:OznerBaseDevice!
        switch  typeInfo.deviceClass{
        case .Cup:
            tmpdev=Cup(Identifier: identifier, Type: type, Settings: setting)
        case .Tap:
            tmpdev = Tap(Identifier: identifier, Type: type, Settings: setting)
        case .WaterPurifier_Wifi:
            tmpdev = WaterPurifier_Wifi(Identifier: identifier, Type: type, Settings: setting)
            break
        case .WaterPurifier_Blue:
            tmpdev = WaterPurifier_Blue(Identifier: identifier, Type: type, Settings: setting)
        case .WaterReplenish:
            tmpdev = WaterReplenish(Identifier: identifier, Type: type, Settings: setting)            
        case .AirPurifier_Blue:
            tmpdev = AirPurifier_Bluetooth(Identifier: identifier, Type: type, Settings: setting)
        case .AirPurifier_Wifi:
            tmpdev = AirPurifier_Wifi(Identifier: identifier, Type: type, Settings: setting)
        }
        return tmpdev
    }
}
