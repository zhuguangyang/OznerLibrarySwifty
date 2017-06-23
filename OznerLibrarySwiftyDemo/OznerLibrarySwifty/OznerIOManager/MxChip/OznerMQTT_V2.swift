//
//  OznerMQTT_V2.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/5/15.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
import MQTTKit

class OznerMQTT_V2: NSObject {

    private var mqttClient:MQTTClient!
    private static var _instance: OznerMQTT_V2! = nil
    static var instance: OznerMQTT_V2! {
        get {
            if _instance == nil {
                
                _instance = OznerMQTT_V2()
            }
            return _instance
        }
        set {
            _instance = newValue
        }
    }
    private var SubscribeTopics:[String:(dataCallBack:((Data)->Void),statusCallBack:((OznerConnectStatus)->Void))]!
    required override init() {
        super.init()
        SubscribeTopics=[String:(dataCallBack:((Data)->Void),statusCallBack:((OznerConnectStatus)->Void))]()
        mqttClient=MQTTClient(clientId: "v1-app-"+rndString(len: 12))
        mqttClient.port=1883
        mqttClient.username="admin"
        mqttClient.password="admin"
        mqttClient.keepAlive=60
        mqttClient.cleanSession=false
        mqttClient.connect(toHost: "qk.ozner.net") { (code) in
            //MQTTConnectionReturnCode
            switch code {
            case ConnectionAccepted:
                print("ConnectionAccepted")
                for (key,value) in self.SubscribeTopics {
                    self.mqttClient.subscribe(key, withQos: AtLeastOnce, completionHandler: { (_) in
                    })
                    value.statusCallBack(OznerConnectStatus.Connected)
                }
            default:
                for item in self.SubscribeTopics {
                    item.value.statusCallBack(OznerConnectStatus.Disconnect)
                }
                print("error:connect MQTT")
            }
        }
        
        mqttClient.messageHandler={(mess) in
            if let callback = self.SubscribeTopics[mess?.topic ?? "none"] {
                if let hexStr=mess?.payloadString() {
                    
                    if hexStr.characters.count>0 {
                        print("2.0收到指令："+hexStr)
                        let needData=OznerTools.hexStringToData(strHex: hexStr)
                        callback.dataCallBack(needData)
                    }
                }
            }
        }
        
    }
    func subscribeTopic(topic:String,messageHandler:(dataCallBack:((Data)->Void),statusCallBack:((OznerConnectStatus)->Void))) {
    
        mqttClient.subscribe(topic, withQos: AtLeastOnce) { (_) in
        }
        
        SubscribeTopics[topic]=messageHandler
        
    }
    func unSubscribeTopic(topic:String) {
        SubscribeTopics.removeValue(forKey: topic)
        mqttClient.unsubscribe(topic) {
        }
    }
    func sendData(data:Data,deviceid:String,callback:((Int32)->Void)!)  {
        OznerTools.publicString(payload: data, deviceid: deviceid, callback: callback)
    }
    private func rndString(len:Int) -> String {
        let  HexString = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var str = ""
        for _ in 0..<len {
            let temp = Int(arc4random()%16)
            str+=HexString[temp]
        }
        return str
    }
}
