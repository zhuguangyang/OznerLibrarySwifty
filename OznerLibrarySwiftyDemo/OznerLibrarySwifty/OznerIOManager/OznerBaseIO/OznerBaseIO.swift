//
//  OznerBaseIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//外部使用
public protocol OznerBaseIODelegate {
    func OznerBaseIORecvData(recvData:Data)->Void//IO收到传感器数据变化
    func OznerBaseIOStatusUpdate(status:OznerConnectStatus)->Void//IO状态变化
}
public class OznerBaseIO: NSObject {
  
   public var delegate:OznerBaseIODelegate!
   public var deviceInfo:OznerDeviceInfo!
   public required init(deviceinfo:OznerDeviceInfo) {
        super.init()
        deviceInfo=deviceinfo
    }
   public func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        
    }
   public func starWork() {
        
    }
   public func stopWork()  {
        
    }
}
