//
//  OZMxChipIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

//庆科读写类
class OZMxChipIO: OznerBaseIO {

    //private  var deviceInfo:OznerDeviceInfo!//"type/mac"
    private var deviceID = ""
    
    required init(deviceinfo:OznerDeviceInfo) {//此处 identifier为"type/mac"，mac去掉“:”转小写
        super.init(deviceinfo: deviceinfo)
        deviceID="d2c_hz/"+deviceinfo.deviceID+"/status"
        if deviceinfo.wifiVersion==1 {
            let chanelStr = deviceinfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased()
            deviceID=deviceinfo.deviceType+"/"+chanelStr
        }
        
        if deviceinfo.wifiVersion == 3 {
            deviceID=deviceinfo.deviceType+"/"+deviceinfo.deviceMac
        }
        
    }
    //发送数据
    override func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        
        switch self.deviceInfo.wifiVersion {
        case 1:
            OznerMQTT_V1.instance.sendData(data: sendData, toTopic: deviceID) { (code) in
            }
            break
        case 2:
            OznerMQTT_V2.instance.sendData(data: sendData, deviceid: deviceInfo.deviceID, callback: { (code) in
            })
            break
        case 3:
            OznerMQTT_V3.instance.sendData(data: sendData, toTopic: deviceInfo.deviceID, callback: { (code) in
            })
            break
        default:
            break
        }
    }
    //开始工作
    override func starWork() {
        weak var weakSelf=self
        let dataCallBack:((Data)->Void) = { data in
            weakSelf?.delegate.OznerBaseIORecvData(recvData: data)
        }
        let statusCallBack:((OznerConnectStatus)->Void) = { status in
            weakSelf?.delegate.OznerBaseIOStatusUpdate(status: status)
        }
        
        switch self.deviceInfo.wifiVersion {
        case 1:
               OznerMQTT_V1.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
            break
        case 2:
             OznerMQTT_V2.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
            break
        case 3:
            OznerMQTT_V3.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
            break
        default:
            break
        }
        
    }
    override func stopWork() {// 暂停工作
        
        switch self.deviceInfo.wifiVersion {
        case 1:
            OznerMQTT_V1.instance.unSubscribeTopic(topic: deviceID)
            break
        case 2:
            OznerMQTT_V2.instance.unSubscribeTopic(topic: deviceID)
            break
        case 3:
            OznerMQTT_V3.instance.unSubscribeTopic(topic: deviceID)
            break
        default:
            break
        }
        
    }
    //删除设备时销毁自己
    func destroySelf() {
        
        switch self.deviceInfo.wifiVersion {
        case 1:
            OznerMQTT_V1.instance.unSubscribeTopic(topic: deviceID)
            break
        case 2:
            OznerMQTT_V2.instance.unSubscribeTopic(topic: deviceID)
            break
        case 3:
            OznerMQTT_V3.instance.unSubscribeTopic(topic: deviceID)
            break
        default:
            break
        }
        
    }
    
}
