//
//  OZMxChipIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科读写类
public class OZMxChipIO: OznerBaseIO {

    //private  var deviceInfo:OznerDeviceInfo!//"type/mac"
    private var deviceID = ""
    
   public required init(deviceinfo:OznerDeviceInfo) {//此处 identifier为"type/mac"，mac去掉“:”转小写
        super.init(deviceinfo: deviceinfo)
        deviceID="d2c_hz/"+deviceinfo.deviceID+"/status"
        if deviceinfo.wifiVersion==1 {
            let chanelStr = deviceinfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased()
            deviceID=deviceinfo.deviceType+"/"+chanelStr
        }
        
    }
    //发送数据
   public override func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        if self.deviceInfo.wifiVersion==1 {
            OznerMQTT_V1.instance.sendData(data: sendData, toTopic: deviceID) { (code) in
            }
        }else{
            OznerMQTT_V2.instance.sendData(data: sendData, deviceid: deviceInfo.deviceID, callback: { (code) in
            })
        }
        
    }
    //开始工作
   public override func starWork() {
        weak var weakSelf=self
        let dataCallBack:((Data)->Void) = { data in
            weakSelf?.delegate.OznerBaseIORecvData(recvData: data)
        }
        let statusCallBack:((OznerConnectStatus)->Void) = { status in
            weakSelf?.delegate.OznerBaseIOStatusUpdate(status: status)
        }
        if self.deviceInfo.wifiVersion==1 {
            OznerMQTT_V1.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
        }else{
            OznerMQTT_V2.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
        }
        
    }
   public override func stopWork() {// 暂停工作
        if self.deviceInfo.wifiVersion==1 {
            OznerMQTT_V1.instance.unSubscribeTopic(topic: deviceID)
        }else{
            OznerMQTT_V2.instance.unSubscribeTopic(topic: deviceID)
        }
        
    }
    //删除设备时销毁自己
   public func destroySelf() {
        if self.deviceInfo.wifiVersion==1 {
            OznerMQTT_V1.instance.unSubscribeTopic(topic: deviceID)
        }else{
            OznerMQTT_V2.instance.unSubscribeTopic(topic: deviceID)
        }
        
    }
    
}
