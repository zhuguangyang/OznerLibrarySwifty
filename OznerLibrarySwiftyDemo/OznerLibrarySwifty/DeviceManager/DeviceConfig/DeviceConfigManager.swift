//
//  DeviceConfigManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//
enum OZTypeAttribute{
    case Ayla
    case MxChip
    case Bluetooth
}
enum OZDeviceClass{
    case Cup
    case Tap//tdspan类型一样
    case AirPurifier_Blue
    case AirPurifier_Wifi
    case WaterPurifier_Blue
    case WaterPurifier_Wifi
    case WaterReplenish
}

class DeviceConfigManager: NSObject {

    //DeviceConfigInfo plist读取
    
    static var deviceTypeInfo:[String:(typeAttr:OZTypeAttribute,deviceClass:OZDeviceClass)] = [
        "CP001":(.Bluetooth,.Cup),
        "SC001":(.Bluetooth,.Tap),
        "MXCHIP_HAOZE_Water":(.MxChip,.WaterPurifier_Wifi),
        "FLT001":(.Bluetooth,.AirPurifier_Blue),
        "FOG_HAOZE_AIR":(.MxChip,.AirPurifier_Wifi),
        "BSY001":(.Bluetooth,.WaterReplenish),
        "580c2783":(.MxChip,.AirPurifier_Wifi),
        "Ozner RO":(.Bluetooth,.WaterPurifier_Blue),
        "16a21bd6":(.MxChip,.WaterPurifier_Wifi),
        "737bc5a2-f345-11e6-9d95-00163e103941":(.MxChip,.WaterPurifier_Wifi)
    ]
    
}
