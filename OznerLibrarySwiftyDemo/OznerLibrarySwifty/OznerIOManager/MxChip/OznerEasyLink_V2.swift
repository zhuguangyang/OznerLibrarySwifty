//
//  OznerEasyLink_V2.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/5/15.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

struct WifiDeviceInfo {
    var deviceID = ""
    var deviceMac = ""
    var deviceType = ""
    var wifiVersion = 1//1.0 or 2.0
}
class OznerEasyLink_V2: NSObject,ZBBonjourServiceDelegate,GCDAsyncSocketDelegate {

    var deviceInfo:WifiDeviceInfo!
    private static var _instance: OznerEasyLink_V2! = nil
    static var instance: OznerEasyLink_V2! {
        get {
            if _instance == nil {
                
                _instance = OznerEasyLink_V2()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    required  override init() {
        
    }
    //自定义方法
    private var hostIP = ""
    private var gcdAsyncSocket:GCDAsyncSocket!
    private var starTime:Date!
    private var pairOutTime = 0
    private var pairTimer:Timer?
    private var PairDelegate:OznerPairDelegate?
    private var deviceType=OZDeviceClass.AirPurifier_Wifi
    func starPair(deviceClass:OZDeviceClass,pairDelegate:OznerPairDelegate?,password:String?,outTime:Int) {
        //初始化参数
        pairOutTime=outTime
        deviceType=deviceClass
        PairDelegate=pairDelegate
        deviceInfo=WifiDeviceInfo.init()
        starTime = Date()
        //配网超时
        pairTimer?.invalidate()
        pairTimer=Timer.scheduledTimer(timeInterval: TimeInterval(pairOutTime), target: self, selector: #selector(pairFailed), userInfo: nil, repeats: false)
        //启动配网
        let weakSelf = self
        MicoDeviceManager.sharedInstance().startEasyLink(withPassword: password) { (isSuccess) in
            if isSuccess{
                ZBBonjourService.sharedInstance().stopSearchDevice()
                ZBBonjourService.sharedInstance().delegate=weakSelf
                ZBBonjourService.sharedInstance().startSearchDevice()
            }
        }
        
    }
    
    func canclePair() {//取消配对
        pairTimer?.invalidate()
        pairTimer = nil
        ZBBonjourService.sharedInstance().stopSearchDevice()
        ZBBonjourService.sharedInstance().delegate=nil
        gcdAsyncSocket=nil
        gcdAsyncSocket.delegate=nil
    }
    @objc private func pairFailed() {
        pairTimer?.invalidate()
        pairTimer = nil
        ZBBonjourService.sharedInstance().stopSearchDevice()
        ZBBonjourService.sharedInstance().delegate=nil
        PairDelegate?.OznerPairFailured(error: NSError(domain: "未找到设备，配对超时", code: 2, userInfo: nil))
    }
    
    
    func bonjourService(_ service: ZBBonjourService!, didReturnDevicesArray array: [Any]!) {
        print(array)
        for item in array {
            if let RecordData = (item as AnyObject).object(forKey: "RecordData")
            {
                if let tmpProductID = (RecordData as AnyObject).object(forKey: "FogProductId") {
                    deviceInfo.deviceMac = (RecordData as AnyObject).object(forKey: "MAC") as! String
                    hostIP = (RecordData as AnyObject).object(forKey: "IP") as! String
                    deviceInfo.deviceType = tmpProductID as! String
                    //if isHaveSuperUser != "UNCHECK" {
                    print("\n搜索到新设备\n"+"ProductID:"+deviceInfo.deviceMac+"\nmac:"+deviceInfo.deviceType)
                    print("\n开始激活设备:\(hostIP)")
                    ZBBonjourService.sharedInstance().stopSearchDevice()
                    gcdAsyncSocket=GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
                    do {
                        try gcdAsyncSocket?.connect(toHost: hostIP, onPort: 8002)
                    } catch let error {
                        print("\n激活设备失败!")
                        print(error)
                    }
                }
            }
        }
    }
    
    private var isneedReconnectHost = true
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        if Int(Date().timeIntervalSince1970-starTime.timeIntervalSince1970)>pairOutTime {
            print("\n激活设备失败!")
            return
        }
        if !isneedReconnectHost {
            return
        }
        do {
            try gcdAsyncSocket?.connect(toHost: hostIP, onPort: 8002)
        } catch let error {
            print("\n激活设备失败!")
            print(error)
        }
        sleep(1)
    }
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("Socket 连接成功")
        sock.readData(withTimeout: -1, tag: 200)
        // 发送消息
        let sPostURL = "POST / HTTP/1.1\r\n\r\n{\"getvercode\":\"\"}\r\n"
        let sPostdata = sPostURL.data(using: String.Encoding.utf8)
        // 开始发送消息 这里不需要知道对象的ip地址和端口
        gcdAsyncSocket?.write(sPostdata, withTimeout: 10, tag: 100)
    }
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        isneedReconnectHost=false
        let stringFromData = String.init(data: data, encoding: String.Encoding.utf8)
        print(stringFromData ?? "")
        let array1=stringFromData?.components(separatedBy: ",")
        let array2=array1?[0].components(separatedBy: ":")
        deviceInfo.deviceID = (array2?.last)!
        deviceInfo.deviceID=deviceInfo.deviceID.replacingOccurrences(of: "\"", with: "")
        let useTime = Date().timeIntervalSince1970-starTime.timeIntervalSince1970
        print("\n设备激活成功(\(Date()))\n配网完成(用时:\(useTime))")
        
    }
}
