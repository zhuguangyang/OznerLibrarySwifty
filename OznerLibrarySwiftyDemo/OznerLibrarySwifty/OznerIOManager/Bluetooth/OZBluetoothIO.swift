//
//  OZBluetoothIO.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
//蓝牙读写类
class OZBluetoothIO: OznerBaseIO {

    private var babyBLEIO:BabyBLEIO?
    private  var uuidStr:String!
    required init(deviceinfo:OznerDeviceInfo) {
        super.init(deviceinfo: deviceinfo)
        uuidStr=deviceinfo.deviceID
    }
    //发送数据
    override func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        babyBLEIO?.sendData(toDevice: sendData) { (error) in
            if callback != nil{
                callback!(error)
            }
        }
    }
    override func starWork() {
        babyBLEIO=nil;
        weak var weakSelf=self
        babyBLEIO=BabyBLEIO(uuidStr, statusBlock: { (statusInt) in
            //设备或手机蓝牙连接状态变化回掉block
            if weakSelf?.delegate != nil{
                weakSelf?.delegate.OznerBaseIOStatusUpdate(status: [
                    -3:OznerConnectStatus.IOIsNotReadly,
                    -2:.DisconnectOfPhoneBLE,
                    -1:.Disconnect,
                    0:.Connecting,
                    1:.Connected,
                    2:.ConnectedOfPhoneBLE,
                    3:.IOIsReadly][statusInt]!)
            }
        }, sensorBlock: { (data) in
            //设备传感器数据变化回掉
            if data != nil{
                if (data?.count)!>0
                {
                    weakSelf?.delegate.OznerBaseIORecvData(recvData: data!)
                }
            }
        })
    }
    override func stopWork() {// 暂停工作
        babyBLEIO=nil
    }
    func destroySelf() {//销毁自己
        babyBLEIO?.destroySelf()
        babyBLEIO=nil
    }
}
