//
//  TwoCup.swift
//  OznerLibrarySwiftyDemo
//
//  Created by ZGY on 2017/9/1.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/9/1  上午10:33
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

import UIKit

struct ListStruct{
    
    var time:Int?
    var tds:Int?
    var Temperature:Int?

}

class TwoCup: OznerBaseDevice {
    
    //二代水杯
    private(set) var cupState:(isPower:Bool,Battery:Int) = (false,0) {
        
        didSet {
            
            if cupState != oldValue {
                
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
                
            }
            
        }
        
    }
    
    private(set) var senSorTwo:(TDS:Int,Temperature:Int) = (0,0) {
        
        didSet {
            
            if senSorTwo != oldValue {
                
                self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
                
            }
            
        }
        
    }
    
    private(set) var historyListArr:NSMutableArray = NSMutableArray()

    var listHistory:String = "未获取到历史数据"
    var listHistoryCount:Int = 0
    
    override func OznerBaseIORecvData(recvData: Data) {
        switch UInt8(recvData[0]) {
            
        //二代 设备状态返回
        case 0x21:
            let isPower = Int(recvData[1])
            let battery = Int(recvData[2])
            
            cupState = (isPower == 0 ? false : true,battery)
            print(cupState)
            
        case 0x33://检测结果返回
            
            senSorTwo = (Int(recvData[1]),Int(recvData[2]))
            print(senSorTwo)
        case 0x42://获取历史记录
            print(recvData)
            listHistory = String.init(data: recvData, encoding: String.Encoding.ascii)!
            
            print("0x42历史记录条数\(recvData[1])")
            let time1 = Int(recvData[2]) + 256 * Int(recvData[3]) + 256 * 256 * Int(recvData[4]) + 256 * 256 * 256 * Int(recvData[5])
//            print("第一条时间戳:\(time1)时间:\(secondstoString(time1))")

            if time1 != 0 {
                
                let timeDate = secsToData(time1)
                let tds = Int(recvData[6])
                let temp = Int(recvData[7])
                print("timeDate：\(timeDate)，tds:\(tds)，temp:\(temp)")

                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: timeDate, Tds: tds, Temperature: temp, Volume: 0, Updated: false)
            }
            
            let time2 = Int(recvData[8]) + 256 * Int(recvData[9]) + 256 * 256 * Int(recvData[10]) + 256 * 256 * 256 * Int(recvData[11])
            print("第二条时间戳:\(time2)" + "时间:\(secondstoString(time2))")

            if time2 != 0 {

                let timeDate = secsToData(time2)
                let tds = Int(recvData[12])
                let temp = Int(recvData[13])
                
                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: timeDate, Tds: tds, Temperature: temp, Volume: 0, Updated: false)
            }
            
            let time3 = Int(recvData[14]) + 256 * Int(recvData[15]) + 256 * 256 * Int(recvData[16]) + 256 * 256 * 256 * Int(recvData[17])
            print("第三条时间戳:\(time3)" + "时间:\(secondstoString(time3))")

            if time3 != 0 {

                let timeDate = secsToData(time3)
                let tds = Int(recvData[18])
                let temp = Int(recvData[19])
                
                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: timeDate, Tds: tds, Temperature: temp, Volume: 0, Updated: false)
            }
            
            
        case 0x43://历史记录数量
            print("0x43总历史记录条数:\(Int(recvData[1]) + 256 * Int(recvData[2]) + 256 * 256 * Int(recvData[3]) + 256 * 256 * 256 * Int(recvData[4]))")

        default:
            break
            
        }
        
    }
    
    override func doWillInit() {
        
        readDeviceInfo()
        calibrationTime()
        getHistory()
    }
    
    var i = 0
    
    override func repeatFunc() {
        
        //            readDeviceInfo()
        
//        if i%2 == 0 {
        
            readDeviceInfo()
  
//        } else {
        
//            getHistory()
//        }
//        i += 1
//        
  
    }
    
    override func describe() -> String {
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(self.senSorTwo)\n,CupState:\(self.cupState)\n 历史记录:\(self.listHistory)"
    
    }
    
    
    //MARK: - 二代水杯相关
    //二代智能水杯
    private func readDeviceInfo() {
        
        let data = Data.init(bytes: [
            0x20])
        self.SendDataToDevice(sendData: data) { (error) in}
        
    }
    
    //校准时钟
    private func calibrationTime() {
        
        let time = CLongLong(Date().timeIntervalSince1970)
        
        var data = Data.init(bytes: [
            0x40])
        data.append(OznerTools.dataFromInt(number: time, length: 4))
        //        let data = Data.init(bytes: [
        //            0x40,
        //            UInt8(NSDate().year()-2000),
        //            UInt8(NSDate().month()),
        //            UInt8(NSDate().day()),
        //            UInt8(NSDate().hour()),
        //            UInt8(NSDate().minute()),
        //            UInt8(NSDate().second())])
        
        self.SendDataToDevice(sendData: data) { (error) in}
        
    }
    
    private func secsToData(_ secs:Int) -> Date {
        
        return Date.init(timeIntervalSince1970: TimeInterval(secs))
        
    }
    
    private func secondstoString(_ seconds:Int) -> String{
        
        let data = Date.init(timeIntervalSince1970: TimeInterval(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        
        return formatter.string(from: data)
        
        
    }
    
    //获取历史记录
    private func getHistory() {
        
        
        let endtime = CLongLong(Date().timeIntervalSince1970)
        
        let startTime = CLongLong(Date().timeIntervalSince1970 - 60 * 60 * 240000)
        
        var data = Data.init(bytes: [
            0x41])
        data.append(OznerTools.dataFromInt(number: startTime, length: 4))
        data.append(OznerTools.dataFromInt(number: endtime, length: 4))
        self.SendDataToDevice(sendData: data) { (error) in}
        
    }
    
    func twoCupClearUpgrade() {
        
        let data = Data.init(bytes: [0xC2])
        
        self.SendDataToDevice(sendData: data) { (error) in
            if error != nil {
                
                print("OTA失败")
                
            }
        }
        
        sleep(3)
        
    }
    
    func startOTA() {
        
        let filePath = Bundle.main.path(forResource: "TwoCup", ofType: "bin")
        
        let data = NSData(contentsOfFile: filePath!)! as Data
        print(Int((data.count)/16))
        
        var sum = Int((data.count)/16)
        
        if Int((data.count)%16) != 0 {
            sum += 1
        }
 
        for i in 0...sum {
            
            var sendData = Data.init(bytes: [0xC1])
            
            //固件包位置
            sendData.append(OznerTools.dataFromInt(number: CLongLong(i), length: 2))
            
            if i != sum {
                //固件包大小
                sendData.append(Data.init(bytes: [0x10]))
                sendData.append(data.subData(starIndex: i * 16, count: 16))
                
            } else {
                sendData.append(Data.init(bytes: [UInt8(data.count%16 == 0 ? 16 : data.count%16)]))
                sendData.append(data.subData(starIndex: i * 16, count: (data.count%16 == 0 ? 16 : data.count%16)))
                
            }
//            sleep(1)
            Thread.sleep(forTimeInterval: 0.1)

            self.SendDataToDevice(sendData: sendData, CallBack: nil)

            //固件包
//            self.perform(#selector(TwoCup.sendOTAData(_:)), with: sendData, afterDelay: 0.5, inModes: [RunLoopMode.commonModes])
        }
        
    }
    
    func sendOTAData(_ data:Data) {
        
        self.SendDataToDevice(sendData: data, CallBack: nil)
        
    }
    
    func getBin() {

        let filePath = Bundle.main.path(forResource: "TwoCup", ofType: "bin")

        var sendData = Data.init(bytes: [0xC3])
        
        let data = NSData(contentsOfFile: filePath!)
        
        //0xC3
        let sum = data?.length
        
        if sum == nil {
            
            print("OTA失败 sum")
            return
            
        }
        sendData.append(OznerTools.dataFromInt(number: CLongLong(sum!), length: 4))
        let Checksum = CheckSum(filePath!)
        
        sendData.append(OznerTools.dataFromInt(number: CLongLong(Checksum), length: 4))
        
        self.SendDataToDevice(sendData: sendData, CallBack: nil)
        
    }
    
    func CheckSum(_ path:String) -> Int {
        
        
        let data = NSData(contentsOfFile: path)
        
        var size = (data?.length)!
        
        if size > 127 * 1024 {
            print("文件过大")
            return 0
        }
        
        if (size % 256) != 0 {
            size = (size/256) * 256 + 256
        }
        
        let inputStream = InputStream(fileAtPath: path)
        
        //        let readBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        
        var readBuffer:[UInt8] = [UInt8]()
        
        inputStream?.read(&readBuffer, maxLength: (data?.length)!)
        var temp = 0
        var Checksum = 0
        let len = size/4
        let data123 = NSData(bytes: readBuffer, length: 4)
        
        
        for i in 0...len {
            var value:UInt32 = 0
            
            data123.getBytes(&value, length: i * 4)
            temp += Int(UInt32(bigEndian: value))
        }
        
        var tempMask = CLongLong(0x1FFFFFFFF);
        tempMask -= CLongLong(0x100000000)
        
        Checksum = Int(CLongLong(temp) & tempMask)
        
        
        print(Checksum)
        
        inputStream?.close()
        
        return Checksum
        
    }

    
    

}
