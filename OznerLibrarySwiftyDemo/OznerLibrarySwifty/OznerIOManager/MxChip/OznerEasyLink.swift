//
//  OznerEasyLink.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/2/15.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//
import UIKit

class OznerEasyLink: NSObject,EasyLinkFTCDelegate {
    private var easylink_config:EASYLINK!
    private var wifiReachability:Reachability!
    private static var _instance: OznerEasyLink! = nil
    static var instance: OznerEasyLink! {
        get {
            if _instance == nil {
                
                _instance = OznerEasyLink()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    required override init() {
        super.init()
        if( easylink_config == nil){
            easylink_config = EASYLINK(delegate: self)
        }
        wifiReachability = Reachability.forLocalWiFi()  //监测Wi-Fi连接状态
    }
    //自定义方法
    //获取当前设备连接的无线网名称
    func getSsid() -> String {
        let netStatus = wifiReachability.currentReachabilityStatus()
        if ( netStatus != NetworkStatus.NotReachable ){
            return EASYLINK.ssidForConnectedNetwork()
        }
        else{
            return ""
        }
        
    }
    private var pairTimer:Timer?
    private var PairDelegate:OznerPairDelegate?
    private var deviceType=OZDeviceClass.AirPurifier_Wifi
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,ssid:String?,password:String?) {//开始配对
        deviceType=deviceClass
        PairDelegate=nil
        PairDelegate=pairDelegate
        if( easylink_config == nil){
            easylink_config = EASYLINK(delegate: self)
        }
        if ( wifiReachability.currentReachabilityStatus() != NetworkStatus.NotReachable ) {
            var wlanConfig = [String:Any]()
            wlanConfig[KEY_SSID]=ssid!.data(using: String.Encoding.utf8)
            wlanConfig[KEY_PASSWORD]=password!
            wlanConfig[KEY_DHCP]=1
            wlanConfig[KEY_IP]=EASYLINK.getIPAddress()
            wlanConfig[KEY_NETMASK]=EASYLINK.getNetMask()
            wlanConfig[KEY_GATEWAY]=EASYLINK.getGatewayAddress()
            wlanConfig[KEY_DNS1]=EASYLINK.getGatewayAddress()
            easylink_config.prepareEasyLink_(withFTC: wlanConfig, info: "".data(using: String.Encoding.utf8), mode: EASYLINK_V2_PLUS)
            easylink_config.transmitSettings()
            print("开始进行WIFI配对，配对信息如下")
            print(wlanConfig)
            pairTimer?.invalidate()
            pairTimer = nil
            pairTimer=Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(pairFailed), userInfo: nil, repeats: false)
        }else{
            PairDelegate?.OznerPairFailured(error: NSError(domain: "手机wifi未连接", code: 1, userInfo: nil))
        }
        
    }
    
    func canclePair() {//取消配对
        pairTimer?.invalidate()
        pairTimer = nil
        if (easylink_config != nil) {
            easylink_config.stopTransmitting()
        }
        
    }
    @objc private func pairFailed() {
        pairTimer?.invalidate()
        pairTimer = nil
        if (easylink_config != nil) {
            easylink_config.stopTransmitting()
        }
        PairDelegate?.OznerPairFailured(error: NSError(domain: "未找到设备，配对超时", code: 2, userInfo: nil))
    }
    private func pairSuccessed(configDict: [AnyHashable : Any]!) {
        print(configDict)        
        easylink_config.stopTransmitting()//停止扫描
        var deviceInfoArr=[String:(type:String,instance:Int)]()
        let tmpStr = ((configDict["C"] as AnyObject).objectAt(2).object(forKey: "C") as AnyObject).objectAt(3).object(forKey: "C") as! String
        if tmpStr.contains("/") {
            let strArr = tmpStr.components(separatedBy: "/")
            let tmpIdent=strArr[1].uppercased()  as NSString
            var identifier = tmpIdent.substring(to: 2)
            
            for i in 1...5 {
                let tmpstr = tmpIdent.substring(from: i*2) as NSString
                identifier=identifier+":"+tmpstr.substring(to: 2)
            }
            let type = strArr[0]
            
            deviceInfoArr[identifier]=(type,0)
            pairTimer?.invalidate()
            pairTimer = nil
            PairDelegate?.OznerPairSucceed(devices: deviceInfoArr)
        }
        else{
            activateDevice(configDict: configDict)
        }
        
    }
     var oznerBonjourDetail:OznerBonjourDetail!
    func activateDevice(configDict: [AnyHashable : Any]!) {
        let IPAddress = ((configDict["C"] as AnyObject).objectAt(1).object(forKey: "C") as AnyObject).objectAt(3).object(forKey: "C") as! String
        easylink_config.unInit()
        easylink_config = nil
        oznerBonjourDetail=nil
        sleep(5)
        oznerBonjourDetail=OznerBonjourDetail.init(IPAddress, block: { (deviceid) in
            if (deviceid?.contains("/"))! {
                let strArr = deviceid!.components(separatedBy: "/")
                let tmpIdent=strArr[1].uppercased()  as NSString
                var identifier = tmpIdent.substring(to: 2)
                
                for i in 1...5 {
                    let tmpstr = tmpIdent.substring(from: i*2) as NSString
                    identifier=identifier+":"+tmpstr.substring(to: 2)
                }
                let type = strArr[0]
                self.pairTimer?.invalidate()
                self.pairTimer = nil
                self.PairDelegate?.OznerPairSucceed(devices: [identifier:(type,0)])
            }
        })
        
    }
    //EasyLinkFTCDelegate 代理方法
    func onFound(_ client: NSNumber!, withName name: String!, mataData mataDataDict: [AnyHashable : Any]!) {
        print("=====onFoundwithName=====")
        let tmptype =  mataDataDict["FW"] as! String
       
        switch deviceType {
        case OZDeviceClass.AirPurifier_Wifi:
            if tmptype=="FOG_HAOZE_AIR@" {
                self.pairSuccessed(configDict: mataDataDict)
            }
        case OZDeviceClass.WaterPurifier_Wifi:
            if tmptype=="MXCHIP_HAOZE_Water@" {
                self.pairSuccessed(configDict: mataDataDict)
            }
        default:
            break
        }
        
    }
    func onFound(byFTC client: NSNumber!, withConfiguration configDict: [AnyHashable : Any]!) {
        print("=====onFoundwithConfiguration=====")
        let tmptype =  configDict["FW"] as! String
        
        switch deviceType {
        case OZDeviceClass.AirPurifier_Wifi:
            if tmptype=="FOG_HAOZE_AIR@" {
                self.pairSuccessed(configDict: configDict)
            }
        case OZDeviceClass.WaterPurifier_Wifi:
            if tmptype=="MXCHIP_HAOZE_Water@" {
                self.pairSuccessed(configDict: configDict)
            }
        default:
            break
        }
    }
    func onDisconnect(fromFTC client: NSNumber!, withError err: Bool) {
        print("=====onDisconnect fromFTC=====")
    }
    
}
