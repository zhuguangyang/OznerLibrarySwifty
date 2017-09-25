//
//  DeviceConfigManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
import SwiftyJSON
//IO类型
enum OZIOType{
    case Ayla
    case MxChip
    case Blue
    case BlueMxChip
    case AylaMxChip
    
    static func getFromString(str:String) -> OZIOType {
        switch str {
        case "Ayla":
            return .Ayla
        case "MxChip":
            return .MxChip
        case "Blue":
            return .Blue
        case "BlueMxChip":
            return .BlueMxChip
        case "AylaMxChip":
            return .AylaMxChip
        default:
            return .Blue
        }
    }
}
//App添加设备的列表类型
enum OZDeviceClass:String{
    case WaterPurifier_Blue="WaterPurifier_Blue"
    case Cup="Cup"
    case TwoCup="TwoCup"
    case Tap="Tap"
    case TDSPan="TDSPan"
    case WaterPurifier_Wifi="WaterPurifier_Wifi"
    case AirPurifier_Blue="AirPurifier_Blue"
    case AirPurifier_Wifi="AirPurifier_Wifi"
    case WaterReplenish="WaterReplenish"
    case Electrickettle_Blue="Electrickettle_Blue"
    case WashDush_Wifi="WashDush_Wifi"
        
    static func getFromString(str:String)->OZDeviceClass{
        return ["WaterPurifier_Blue":.WaterPurifier_Blue,"Cup":.Cup,"TwoCup":.TwoCup,"Tap":.Tap,"TDSPan":.TDSPan,"WaterPurifier_Wifi":.WaterPurifier_Wifi,"AirPurifier_Blue":.AirPurifier_Blue,"AirPurifier_Wifi":.AirPurifier_Wifi,"WaterReplenish":.WaterReplenish,"Electrickettle_Blue":.Electrickettle_Blue,"WashDush_Wifi":.WashDush_Wifi][str]!
    }
    public var ioType:OZIOType {
        switch self {
        case .WaterPurifier_Blue,.Cup,.Tap,.TDSPan,.AirPurifier_Blue,.WaterReplenish,.Electrickettle_Blue,.TwoCup:
            return OZIOType.Blue
        case .WaterPurifier_Wifi,.AirPurifier_Wifi,.WashDush_Wifi:
            return OZIOType.MxChip
//        default:
//            return OZIOType.Blue
        }
    }
    public var pairID:String {
        var pairStr = ""
        for i in 0..<ProductInfo.products.count {
            if self.rawValue == ProductInfo.products["\(i)"]?["ClassName"].stringValue {
                for id in (ProductInfo.products["\(i)"]?["ProductIDs"].arrayValue)! {
                    pairStr+=id.stringValue+"/"
                }
                break
            }
            
        }
        return pairStr
    }
    public var name:String {
        var name = ""
        for i in 0..<ProductInfo.products.count {
            if self.rawValue == ProductInfo.products["\(i)"]?["ClassName"].stringValue {                
                name=(ProductInfo.products["\(i)"]?["Name"].stringValue)!
                break
            }
        }
        return name
    }
    
}

struct OznerDeviceInfo {
    var deviceID = ""//设备唯一ID
    var deviceMac = ""//设备Mac：访问服务器和接口的时候才用到这个，或者Wi-Fi协议里面会用这个，其余的都用deviceID
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
let temperature_high=50
let temperature_low=25
let tds_bad=200
let tds_good=50
class ProductInfo: NSObject {
    
    static private let info:JSON=JSON(NSDictionary(contentsOfFile: Bundle.main.path(forResource: "ProductInfo", ofType: "plist")!)!) as JSON
    static var products: [String:JSON] {
        return info["Products"].dictionaryValue
    }
    class func getIOTypeFromProductID(productID:String)->OZIOType {
        var IOStr = ""
        
        for product in products.values {
            if IOStr != "" {
                break
            }
            for id in product["ProductIDs"].arrayValue {
                if productID==id.stringValue {
                    IOStr=product["IOType"].stringValue
                    break
                }
            }
        }
        if IOStr != "" {
            return OZIOType.getFromString(str: IOStr)
        }
        return OZIOType.Blue
    }
    class func getDeviceClassFromProductID(productID:String)->OZDeviceClass {
        var classStr = ""
        
        for product in products.values {
            if classStr != "" {
                break
            }
            for id in product["ProductIDs"].arrayValue {
                if productID==id.stringValue {
                    classStr=product["ClassName"].stringValue
                    
                    if productID == "智能水杯" {
                        classStr = "TwoCup"
                    }
                    
                    break
                }
            }
            
        }
        if classStr != "" {
            return OZDeviceClass.getFromString(str: classStr)
        }
        return OZDeviceClass.Cup
    }
    class func getProductInfoFromProductID(productID:String)->JSON! {
        var tmpinfo:JSON!
        
        for product in products.values {
            if tmpinfo != nil {
                break
            }
            for id in product["ProductIDs"].arrayValue {
                if productID==id.stringValue {
                    tmpinfo=product
                    break
                }
            }
        }
        if tmpinfo != nil {
            return tmpinfo
        }
        return products["0"]
    }
    class func getNameFromProductID(productID:String)->String {
        var Str = ""
        
        for product in products.values {
            if Str != "" {
                break
            }
            for id in product["ProductIDs"].arrayValue {
                if productID==id.stringValue {
                    Str=product["Name"].stringValue
                    break
                }
            }
            
        }
        return Str
    }

    class func getCurrDeviceClass()->OZDeviceClass
    {
        return ProductInfo.getDeviceClassFromProductID(productID: (OznerManager.instance.currentDevice?.deviceInfo.productID)!)
    }
    class func getCurrDeviceMac()->String
    {
        return (OznerManager.instance.currentDevice?.deviceInfo.deviceMac)!
    }
}


