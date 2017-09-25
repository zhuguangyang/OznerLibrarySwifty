//
//  OZGprsIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by ZGY on 2017/9/25.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/9/25  上午9:49
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

import UIKit

class OZGprsIO: OznerBaseIO {

    
    private var deviceID = ""
    
    required init(deviceinfo:OznerDeviceInfo) {//此处 identifier为"type/mac"，mac去掉“:”转小写
        super.init(deviceinfo: deviceinfo)
//            let chanelStr = deviceinfo.deviceID.replacingOccurrences(of: ":", with: "").lowercased()
        deviceID=deviceinfo.deviceType+"/"+deviceinfo.deviceMac
        
    }
    //发送数据
    override func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {

        MQTTGprs.instance.sendData(data: sendData, toTopic: deviceID) { (code) in
            
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
        
        MQTTGprs.instance.subscribeTopic(topic: deviceID, messageHandler: (dataCallBack,statusCallBack))
        
    }
    override func stopWork() {// 暂停工作
        
        MQTTGprs.instance.unSubscribeTopic(topic: deviceID)

    }
    //删除设备时销毁自己
    func destroySelf() {
        
        MQTTGprs.instance.unSubscribeTopic(topic: deviceID)

    }
    
    
}
