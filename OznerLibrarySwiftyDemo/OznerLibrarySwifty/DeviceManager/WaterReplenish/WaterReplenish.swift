//
//  WaterReplenish.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/6.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class WaterReplenish: OznerBaseDevice {
    
    private(set) var status:WaterReplenishStatus!
    
    required init(deviceinfo: OznerDeviceInfo, Settings settings: String?) {
        super.init(deviceinfo: deviceinfo, Settings: settings)
        status=WaterReplenishStatus()
    }
    
    override func OznerBaseIORecvData(recvData: Data) {

        switch UInt8(recvData[0]) {
        case 0x21://opCode_StatusResp
            status.loadData(data: recvData)
            self.delegate?.OznerDeviceStatusUpdate?(identifier: self.deviceInfo.deviceID)
            print(1)
        case 0x34://opCode_Testing
            print(2)
            status.startTest()
            self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
        case 0x33://opCode_TestResp
            print(3)
            let adc = Int(recvData[1])+256*Int(recvData[2])
            status.loadTest(adc: Float(adc))
        default:
            break
        }
    }
    override func doWillInit() {

    }
    override func repeatFunc() {
        if NSDate().second()%3==0 {
            requestStatus()
        }
    }
    private func requestStatus() {
        self.SendDataToDevice(sendData: Data.init(bytes: [0x20])) { (error) in
        }
    }
    override func describe() -> String {
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n battery:\(self.status.battery)\n power:\(self.status.power)\n moisture:\(self.status.moisture)\n oil:\(self.status.oil)\n testing:\(self.status.testing)\n"
    }
}
