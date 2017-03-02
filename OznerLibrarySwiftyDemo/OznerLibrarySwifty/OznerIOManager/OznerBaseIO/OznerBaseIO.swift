//
//  OznerBaseIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//外部使用
protocol OznerBaseIODelegate {
    func OznerBaseIORecvData(recvData:Data)->Void//IO收到传感器数据变化
    func OznerBaseIOStatusUpdate(status:OznerConnectStatus)->Void//IO状态变化
}
class OznerBaseIO: NSObject {
  
    var delegate:OznerBaseIODelegate!
    
    required init(identifier:String) {
        super.init()
    }
    func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        
    }
    func starWork() {
        
    }
    func stopWork()  {
        
    }
}
