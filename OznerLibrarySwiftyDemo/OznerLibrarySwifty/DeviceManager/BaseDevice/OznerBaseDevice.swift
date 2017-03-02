//
//  OznerBaseDevice.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
enum OznerConnectStatus {
    case Connecting
    case Disconnect
    case Connected
    case ConnectedOfPhoneBLE
    case DisconnectOfPhoneBLE
    case ConnectedOfPhoneNetWork
    case DisconnectOfPhoneNetWork
    case IOIsReadly
    case IOIsNotReadly
}
//外部使用

@objc public protocol OznerBaseDeviceDelegate {
    @objc optional func OznerDeviceSensorUpdate(identifier:String)->Void//传感器数据变化
    @objc optional func OznerDeviceStatusUpdate(identifier:String)->Void//设备状态变化
    @objc optional func OznerDevicefilterUpdate(identifier:String)->Void//设备滤芯变化
    @objc optional func OznerDeviceRecordUpdate(identifier:String)->Void//设备滤芯变化
}

class OznerBaseDevice: NSObject,OznerBaseIODelegate {

    var identifier:String!//系统自动生成的，自带的，原生的设备id，不一样的设备获取到的不唯一，蓝牙自动连接使用
    var macAdress:String!//广播包发过来的，浩泽自己定义的唯一识别码,接口调用时用,滤芯，周月数据
    var type:String!
    var settings:BaseDeviceSetting!
    var connectStatus=OznerConnectStatus.Disconnect{
        didSet{
            delegate?.OznerDeviceStatusUpdate?(identifier: self.identifier)
        }
    }
    var delegate:OznerBaseDeviceDelegate?
    private var io:OznerBaseIO?
    required init(Identifier id:String,Type type:String,Settings settings:String?) {
        super.init()
        self.identifier=id
        self.type=type
        self.settings=BaseDeviceSetting(json: settings)
        self.io=OznerIOManager.instance.getIO(identifier: id, type: type)
        self.io?.delegate=self
       
    }
    func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        if io != nil {
             io?.SendDataToDevice(sendData: sendData, CallBack: callback)
        }
       
    }
    private var cycyleTimer:Timer?
    var isCurrentDevice = false{
        didSet{
            if isCurrentDevice == oldValue {
                return
            }
            if isCurrentDevice {//开启循环数据模式
                io?.starWork()
                
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(doWillInit), userInfo: nil, repeats: false)
                cycyleTimer?.invalidate()
                cycyleTimer = nil
                cycyleTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.repeatFunc), userInfo: nil, repeats: true)                
                RunLoop.main.add(cycyleTimer!, forMode: RunLoopMode.commonModes)
            }else{//关闭循环数据模式
                // 从运行循环中移除
                cycyleTimer?.invalidate()
                cycyleTimer = nil
                io?.stopWork()
            }
        }
    }
    func repeatFunc() {//需要重复执行的调用
        
    }
    //io 发送初始化数据
    func doWillInit() {
    }
    
    
    
    //OznerBaseIODelegate
    //收到传感器变化数据
    func OznerBaseIORecvData(recvData: Data) {
    }
    //连接状态变化
    func OznerBaseIOStatusUpdate(status: OznerConnectStatus) {
        
        if status==OznerConnectStatus.IOIsReadly {
            connectStatus=OznerConnectStatus.Connected
            self.doWillInit()
        }else{
            connectStatus=status
        }
    }
    func describe() -> String {
        return ""
    }
}
