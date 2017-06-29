//
//  DeviceConfigManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//IO类型
enum OZIOType{
    case Ayla
    case MxChip
    case Bluetooth
    case BlueMxChip
    case AylaMxChip
}
//App添加设备的列表类型
enum OZDeviceClass{
    case Cup
    case Tap
    case AirPurifier_Blue
    case AirPurifier_Wifi
    case WaterPurifier_Blue
    case WaterPurifier_Wifi
    case WaterReplenish
    public var IOType: OZIOType {
        switch self {
        case .AirPurifier_Wifi,.WaterPurifier_Wifi:
            return .MxChip
        case .Cup,.Tap,.AirPurifier_Blue,.WaterPurifier_Blue,.WaterReplenish:
            return .Bluetooth
        //case .otherDevice: return .BlueMxChip
        //case .otherDevice: return .AylaMxChip
        }
    }
    //按照app界面设备栏划分,配对专用
    public var pairID: String {
        switch self {
        case .Cup:
            return "Ozner Cup"
        case .Tap:
            return "Ozner Tap"
        case .AirPurifier_Blue:
            return "OAP"
        case .AirPurifier_Wifi:
            return "FOG_HAOZE_AIR@/10c347a8-562f-11e7-9baf-00163e120d98/e137b6e0-2668-11e7-9d95-00163e103941"
        case .WaterPurifier_Blue:
            return "Ozner RO/RO Comml"
        case .WaterPurifier_Wifi:
            return "MXCHIP_HAOZE_Water@/2821b472-5263-11e7-9baf-00163e120d98/f4edba26-549a-11e7-9baf-00163e120d98/67ea604c-549b-11e7-9baf-00163e120d98/b5d03ee4-549b-11e7-9baf-00163e120d98"
        case .WaterReplenish:
            return "OZNER_SKIN"
        }
    }
}

struct OznerDeviceInfo {
    var deviceID = ""//设备ID
    var deviceMac = ""//设备Mac
    var deviceType = ""
    /*
     productID
     蓝牙产品为"BLUE"
     wifi产品为 a.2.0水机 "737bc5a2-f345-11e6-9d95-00163e103941"
     b.1.0水机 MXCHIP_HAOZE_Water
     c.1.0空净 FOG_HAOZE_AIR
     */
    var productID = ""
    var wifiVersion = 1//wifi版本，1或2
    
    
    func des() -> String {
        return "设备ID:\(self.deviceID)\n设备Mac:\(self.deviceMac)\n设备型号:\(self.deviceType)\n产品ID:\(self.productID)\nWiFi版本:\(self.wifiVersion)"
    }
}
class DeviceConfigManager: NSObject {
    static var deviceTypeInfo:[String:(typeAttr:OZIOType,deviceClass:OZDeviceClass)] = [
        "Ozner Cup":(.Bluetooth,.Cup),
        "Ozner Tap":(.Bluetooth,.Tap),
        //"MXCHIP_HAOZE_Water@":(.MxChip,.WaterPurifier_Wifi),
        "OAP":(.Bluetooth,.AirPurifier_Blue),
        //"FOG_HAOZE_AIR@":(.MxChip,.AirPurifier_Wifi),
        "OZNER_SKIN":(.Bluetooth,.WaterReplenish),
        "580c2783":(.MxChip,.AirPurifier_Wifi),
        "Ozner RO":(.Bluetooth,.WaterPurifier_Blue),
        "RO Comml":(.Bluetooth,.WaterPurifier_Blue),
        "16a21bd6":(.MxChip,.WaterPurifier_Wifi),
        "2821b472-5263-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "f4edba26-549a-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "67ea604c-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "b5d03ee4-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "d50cd29a-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机C01
        "b78e2292-549a-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机A02
        "4295741c-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机M01
        "934ed042-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机A01
        "10c347a8-562f-11e7-9baf-00163e120d98":(.MxChip,.AirPurifier_Wifi),//空净(普信)KG460-140A
        "e137b6e0-2668-11e7-9d95-00163e103941":(.MxChip,.AirPurifier_Wifi)//空净(浩泽)KG460-110A
    ]
}
