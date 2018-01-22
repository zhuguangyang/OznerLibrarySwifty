//
//  OznerBaseDevice.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit
public enum OznerConnectStatus {
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

public class OznerBaseDevice: NSObject,OznerBaseIODelegate {

    //var identifier:String!//系统自动生成的，自带的，原生的设备id，不一样的设备获取到的不唯一，蓝牙自动连接使用
    //var macAdress:String!//广播包发过来的，浩泽自己定义的唯一识别码,接口调用时用,滤芯，周月数据
    //var type:String!
  public var deviceInfo:OznerDeviceInfo!
    
  public  var settings:BaseDeviceSetting!
  public  var connectStatus=OznerConnectStatus.Disconnect{
        didSet{
            delegate?.OznerDeviceStatusUpdate?(identifier: deviceInfo.deviceID)
        }
    }
   public var delegate:OznerBaseDeviceDelegate?
    private var io:OznerBaseIO?
   public required init(deviceinfo:OznerDeviceInfo,Settings settings:String?) {
        super.init()
        self.deviceInfo=deviceinfo
        self.settings=BaseDeviceSetting(json: settings)
        self.io=OznerIOManager.instance.getIO(deviceinfo: deviceinfo)
        self.io?.delegate=self
       
    }
  public  func SendDataToDevice(sendData:Data,CallBack callback:((Error?)->Void)?) {
        if io != nil {
             io?.SendDataToDevice(sendData: sendData, CallBack: callback)
        }
       
    }
    private var cycyleTimer:Timer?
  public  var isCurrentDevice = false{
        didSet{
            if isCurrentDevice == oldValue {
                return
            }
            if isCurrentDevice {//开启循环数据模式
                io?.starWork()
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(doWillInit), userInfo: nil, repeats: false)
                cycyleTimer?.invalidate()
                cycyleTimer = nil
                cycyleTimer = Timer(timeInterval: 2.0, target: self, selector: #selector(self.repeatFunc), userInfo: nil, repeats: true)
                RunLoop.main.add(cycyleTimer!, forMode: RunLoopMode.commonModes)
            }else{//关闭循环数据模式
                // 从运行循环中移除
                cycyleTimer?.invalidate()
                cycyleTimer = nil
                io?.stopWork()
            }
        }
    }
   public func repeatFunc() {//需要重复执行的调用
        
    }
    //io 发送初始化数据
   public func doWillInit() {

    }
    
    //OznerBaseIODelegate
    //收到传感器变化数据
   public func OznerBaseIORecvData(recvData: Data) {
    }
    //连接状态变化
   public func OznerBaseIOStatusUpdate(status: OznerConnectStatus) {
        if status==OznerConnectStatus.IOIsReadly {
            connectStatus=OznerConnectStatus.Connected
            self.doWillInit()
        }else{
            connectStatus=status
        }
    }
   public func describe() -> String {
        return ""
    }
}
