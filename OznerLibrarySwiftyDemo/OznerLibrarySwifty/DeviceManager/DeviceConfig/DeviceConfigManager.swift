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
        "2821b472-5263-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "f4edba26-549a-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "67ea604c-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "b5d03ee4-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//1.5商用
        "d50cd29a-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机C01
        "b78e2292-549a-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机A02
        "4295741c-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机M01
        "934ed042-549b-11e7-9baf-00163e120d98":(.MxChip,.WaterPurifier_Wifi),//RO家用机A01
        "10c347a8-562f-11e7-9baf-00163e120d98":(.MxChip,.AirPurifier_Wifi),//空净（普信）KG460-140A
        "e137b6e0-2668-11e7-9d95-00163e103941":(.MxChip,.AirPurifier_Wifi)//空净（浩泽）KG460-110A
    ]
    
}
