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

    private  var Channel:String!//"type/mac"
    required init(identifier: String) {//此处 identifier为"type/mac"，mac去掉“:”转小写
        super.init(identifier: identifier)
        Channel=identifier        
    }
    //发送数据
    override func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        OznerMQTT_V1.instance.sendData(data: sendData, toTopic: Channel) { (code) in
            
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
        OznerMQTT_V1.instance.subscribeTopic(topic: Channel, messageHandler: (dataCallBack,statusCallBack))
    }
    override func stopWork() {// 暂停工作
        OznerMQTT_V1.instance.unSubscribeTopic(topic: Channel)
    }
    //删除设备时销毁自己
    func destroySelf() {
        OznerMQTT_V1.instance.unSubscribeTopic(topic: Channel)
    }
}
