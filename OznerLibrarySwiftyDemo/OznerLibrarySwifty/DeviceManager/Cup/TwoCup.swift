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
    var listHistoryCount:String = "0"
    var i = 0
    var eachInfo = ""
    
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
            print("0x42历史记录条数\(recvData[1])")
            
            let time1 = Int(recvData[2]) + (256 * Int(recvData[3])) + (256 * 256 * Int(recvData[4]))
            
            if time1 != 0 {
                
                let timeDate = secsToData(time1  + (256 * 256 * 256 * Int(recvData[5])))
                let tds = Int(recvData[6]) + Int(recvData[7]) * 256
                let temp = Int(recvData[8])
                print("第一条数据timeDate：\(secondstoString(time1))，tds:\(tds)，temp:\(temp)")
                
                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: timeDate, Tds: tds, Temperature: temp, Volume: 0, Updated: false)
            }
            
            let time2:Int = Int(recvData[9]) + 256 * Int(recvData[10]) + 256 * 256 * Int(recvData[11])
            
            if time2 != 0 {
                
                let timeDate = secsToData(time2 + 256 * 256 * 256 * Int(recvData[12]))
                let tds = Int(recvData[13]) + 256 * Int(recvData[14])
                let temp = Int(recvData[15])
                print("第二条时间戳:\(time2)" + "时间:\(secondstoString(time2))，tds:\(tds)，temp:\(temp)")
                
                OznerDeviceRecordHelper.instance.addRecordToSQL(Identifier: self.deviceInfo.deviceID, Tdate: timeDate, Tds: tds, Temperature: temp, Volume: 0, Updated: false)
            }
            
        case 0x43://历史记录数量
//            print("0x43总历史记录条数:\(Int(recvData[1]) + 256 * Int(recvData[2]) + 256 * 256 * Int(recvData[3]) + 256 * 256 * 256 * Int(recvData[4]))")
//            listHistoryCount = "0x43总历史记录条数:\(Int(recvData[1]) + 256 * Int(recvData[2]) + 256 * 256 * Int(recvData[3]) + 256 * 256 * 256 * Int(recvData[4]))"
//           let mm = OznerDeviceRecordHelper.instance.getRecords(Identifier: self.deviceInfo.deviceID)
//            print("数据库历史记录:\(mm.count)")
            break
        default:
            break
            
        }
        
    }
    
    var count = 1
    
    override func doWillInit() {
        
        readDeviceInfo()
        calibrationTime()
        count += 1
        if count == 2 {
        
            getHistory()

        }
    
    }
    
    var sumHistory = 0
    
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
        
        return "name:\(self.settings.name!)\n connectStatus:\(self.connectStatus)\n sensor:\(self.senSorTwo)\n,CupState:\(self.cupState)\n \(self.listHistoryCount)\n  0x42收到总条数:\(self.sumHistory)\n 记录信息:\(self.eachInfo)\n OTA进度:\(currenLength)/\(sumLength)"
    
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
    func getHistory() {
        
        self.sumHistory = 0
        self.eachInfo = ""
        i = 0
        let endtime = CLongLong(Date().timeIntervalSince1970)
        
        let startTime = CLongLong(Date().timeIntervalSince1970 - 60 * 60 * 24 * 3200)
        
        var data = Data.init(bytes: [
            0x41])
        data.append(OznerTools.dataFromInt(number: startTime, length: 4))
        data.append(OznerTools.dataFromInt(number: endtime, length: 4))
        self.SendDataToDevice(sendData: data) { (error) in}
        
        self.perform(#selector(TwoCup.updateSensor), with: nil, afterDelay: 3.5)
        
    }
    
    var slider:UISlider?
    func updateSensor() {
        
        self.delegate?.OznerDeviceSensorUpdate?(identifier: self.deviceInfo.deviceID)
        
//        if slider == nil {
//            slider = UISlider(frame: CGRect(x: 50, y: 200, width: 200, height: 30))
//            slider?.maximumValue = Float(sumLength)
//            slider?.minimumValue = 0
//            appDelegate.window?.addSubview(slider!)
//        }
//        
//        
//        slider?.value = Float(currenLength)
        
        

    }
    
    func twoCupClearUpgrade() {
        
        let data = Data.init(bytes: [0xC2])
        
        self.SendDataToDevice(sendData: data) { (error) in
            if error != nil {
                
                print("OTA失败")
                
            }
        }
        
        sleep(2)
        
    }
    
    var
    sumLength:Int = 0
    var currenLength:Int = 0
    
    func startOTA() {
   
        sleep(1)
        
        let filePath = Bundle.main.path(forResource: "TwoCup", ofType: "bin")
        
        let data = NSData(contentsOfFile: filePath!)!
        
        var size = data.length
        
        if size > 127 * 1024 {
            print("文件过大")
            appDelegate.window?.noticeOnlyText("OTA失败 文件过大!")
            return
        }
        
        if (size % 256) != 0 {
            size = (size/256) * 256 + 256
        }
        
 
        var readBuffer:[UInt8] = [UInt8].init(repeating: 0xff, count: size)
        
        memset(&readBuffer, 0xff, size)
        memcpy(&readBuffer, data.bytes, data.length)
        
        let data123 = Data.init(bytes: readBuffer)
        
        sumLength = data123.count

        for  i in 0 ... size/16 {
            
            var sendData = Data.init(bytes: [0xC1])
            Thread.sleep(forTimeInterval: 0.1)
            print(i)
            //固件包位置
            sendData.append(OznerTools.dataFromInt(number: CLongLong(i), length: 2))

            //固件包大小
            sendData.append(Data.init(bytes: [0x10]))
            sendData.append(data123.subData(starIndex: i * 16, count: 16))
            
            currenLength = i * 16
            
           
            if self.connectStatus != .Connected {
                currenLength = 0
                appDelegate.window?.noticeOnlyText("OTA失败 设备断开连接!")
                return
            }

//            self.perform(#selector(TwoCup.sendOTAData(_:)), with: sendData, afterDelay: TimeInterval(0.1))
            
//            self.perform(#selector(TwoCup.sendOTAData(_:)), on: Thread.current, with: sendData, waitUntilDone: true, modes: nil)
            
            self.SendDataToDevice(sendData: sendData, CallBack: { (error) in
                print("============")
            })

            updateSensor()
        }
        sleep(2)
        getBin()
        
    }
    
    
    func sendOTAData(_ data:Data) {
        
        print("====")
        
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
        let Checksum = 2146531410
        
        sendData.append(OznerTools.dataFromInt(number: CLongLong(Checksum), length: 4))
        
        self.SendDataToDevice(sendData: sendData, CallBack: nil)
        sleep(60)
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
        
        var readBuffer:[UInt8] = [UInt8].init(repeating: 0xff, count: size)
        
        memset(&readBuffer, 0, size)
        memcpy(&readBuffer, data?.bytes, (data?.length)!)
        
        var temp = 0
        var Checksum = 0
        let len = size/4 - 1
        let allData = NSData.init(bytes: readBuffer, length: readBuffer.count)

        
        for i in 0...len {
            var value:UInt32 = 0
            
            allData.getBytes(&value, range: NSRange.init(location: i * 4, length: 4))

            temp += Int(UInt32(bigEndian: value))
        }
        
//        var tempMask = CLongLong(0x1FFFFFFFF)
//        tempMask -= CLongLong(0x100000000)
//
//        Checksum = Int(CLongLong(temp) & tempMask)
//
        Checksum = 2146531471
        print(Checksum)
        
        inputStream?.close()
        
        return Checksum
        
    }

    
    

}
