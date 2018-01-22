//
//  OznerBluetoothManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit


//蓝牙库管理中心
public class OznerBluetoothManager: NSObject {
    private static var _instance: OznerBluetoothManager! = nil
   public static var instance: OznerBluetoothManager! {
        get {
            if _instance == nil {
                _instance = OznerBluetoothManager()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    private var IODics=[String:OZBluetoothIO]()
    //获取已配对的设备IO，或者设备重新连接调用
  public  func getIO(deviceinfo:OznerDeviceInfo) -> OZBluetoothIO? {
        if let tmpIO = IODics[deviceinfo.deviceID] {
            return tmpIO
        }else{
            IODics[deviceinfo.deviceID] = OZBluetoothIO(deviceinfo: deviceinfo)
            return IODics[deviceinfo.deviceID]
        }
        
    }
    //搜索新设备的IO进行配对
    private var failDelegateUsed:Bool=false
   public func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?) {//开始配对
        var scanData=OznerDeviceInfo()
        let starDate = Date()
        self.failDelegateUsed=false
        BabyBLEHelper.share().starScan(30, deviceName: (deviceClass == .TDSPan ? "Ozner Tap":deviceClass.pairID), block: { (uuidString,type,Mac, Distance,bleData) in
            if self.failDelegateUsed{//已经回调过了
                return
            }
            if !self.IODics.keys.contains(uuidString!)//不是已配对过的设备
            {
                if scanData.deviceMac==""{//不是已扫描到的设备
                    scanData.deviceID=uuidString!
                    scanData.deviceMac=Mac!
                    scanData.deviceType=(deviceClass == .TDSPan ? "Ozner TDSPan":type!)
                    scanData.productID = scanData.deviceType
                    pairDelegate?.OznerPairSucceed(deviceInfo: scanData)
                    self.canclePair()
                }
                
            }            
            
        }) { (errorCode) in
            if self.failDelegateUsed{//已经回调过了
                return
            }
            self.failDelegateUsed=true
            switch errorCode
            {
            case 1://手机蓝牙未打开
                self.failDelegateUsed=true
                pairDelegate?.OznerPairFailured(error: NSError(domain: "手机蓝牙未打开", code: 1, userInfo: nil))
            case 2://扫描结束
                if scanData.deviceMac==""&&(Date().timeIntervalSince1970-starDate.timeIntervalSince1970)>=30{
                    pairDelegate?.OznerPairFailured(error: NSError(domain: "未搜索到设备，扫描超时！", code: 2, userInfo: nil))
                }
                
            default:
                break;
            }
        }
    }
   public func canclePair() {//取消配对
        BabyBLEHelper.share().cancelScan()
        self.failDelegateUsed=true
    }
    //删除设备时解除绑定的IO
   public func deleteIO(identifier:String) {
        if let tmpIO = IODics[identifier] {
            tmpIO.destroySelf()
            IODics.removeValue(forKey: identifier)
        }
    }
}
