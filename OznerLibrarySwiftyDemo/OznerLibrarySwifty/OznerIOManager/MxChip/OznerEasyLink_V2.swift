//
//  OznerEasyLink_V2.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/5/15.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit



class OznerEasyLink_V2: NSObject,ZBBonjourServiceDelegate,GCDAsyncSocketDelegate {
    
    var deviceInfo:OznerDeviceInfo!
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
    
    private var hostIP = ""
    private var gcdAsyncSocket:GCDAsyncSocket!
    private var starTime:Date!
    private var pairOutTime = 0
    private var pairTimer:Timer?
    private var SuccessBlock:((OznerDeviceInfo)->Void)!
    private var FailedBlock:((Error)->Void)!
    
    func starPair(password:String?,outTime:Int,successBlock:((OznerDeviceInfo)->Void)!,failedBlock:((Error)->Void)!) {
        SuccessBlock=successBlock
        FailedBlock=failedBlock
        //初始化参数
        pairOutTime=outTime
        deviceInfo=OznerDeviceInfo.init()
        deviceInfo.wifiVersion=2
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
    }
    @objc private func pairFailed() {
        canclePair()
        FailedBlock(NSError.init(domain: "配网失败", code: 0, userInfo: nil))
    }
    private func pairSuccess() {
        canclePair()
        SuccessBlock(deviceInfo)
    }
    
    func bonjourService(_ service: ZBBonjourService!, didReturnDevicesArray array: [Any]!) {
        print(array)
        for item in array {
            if let RecordData = (item as AnyObject).object(forKey: "RecordData")
            {
                if let tmpProductID = (RecordData as AnyObject).object(forKey: "FogProductId") {
                    deviceInfo.deviceMac = (RecordData as AnyObject).object(forKey: "MAC") as! String
                    hostIP = (RecordData as AnyObject).object(forKey: "IP") as! String
                    deviceInfo.productID = tmpProductID as! String
                    deviceInfo.deviceType = deviceInfo.productID
                    //if isHaveSuperUser != "UNCHECK" {
                    print("\n搜索到新设备\n"+"ProductID:"+deviceInfo.deviceMac+"\nmac:"+deviceInfo.deviceType)
                    print("\n开始激活设备:\(hostIP)")
                    ZBBonjourService.sharedInstance().stopSearchDevice()
                    if gcdAsyncSocket != nil {
                        gcdAsyncSocket.setDelegate(nil, delegateQueue: nil)
                        gcdAsyncSocket.disconnect()
                        gcdAsyncSocket=nil
                    }
                    isneedReconnectHost=true
                    let myQueue = DispatchQueue.init(label: "come.ozner.GCDAsyncSocket")
                    gcdAsyncSocket=GCDAsyncSocket.init(delegate: self, delegateQueue: myQueue)
                    do {
                        try gcdAsyncSocket?.connect(toHost: hostIP, onPort: 8002)
                    } catch let error {
                        print("\n激活设备失败!")
                        print(error)
                        pairFailed()
                    }
                    break
                }
            }
        }
    }
    
    private var isneedReconnectHost = true
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        print("Socket 断开链接")
        if Int(Date().timeIntervalSince1970-starTime.timeIntervalSince1970)>pairOutTime {
            pairFailed()
            return
        }
        if !isneedReconnectHost {
            return
        }
        do {
            try gcdAsyncSocket?.connect(toHost: hostIP, onPort: 8002)
        } catch let error {
            print("\n激活设备失败!\(error)")
            pairFailed()
        }
        sleep(1)
    }
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("Socket 连接成功")
        gcdAsyncSocket.readData(withTimeout: -1, tag: 200)
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
        pairSuccess()
    }
}
