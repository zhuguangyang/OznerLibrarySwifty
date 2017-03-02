//
//  OznerMQTTManager.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/2/15.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
import MQTTKit

class OznerMQTT: NSObject {
    private var mqttClient:MQTTClient!
    private static var _instance: OznerMQTT! = nil
    static var instance: OznerMQTT! {
        get {
            if _instance == nil {
                
                _instance = OznerMQTT()
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
//        mqttClient.disconnect { (code) in
//            print("disconnect")
//            for item in self.SubscribeTopics {
//                item.value.statusCallBack(OznerConnectStatus.Disconnect)
//            }
//        }
        
//        mqttClient.connect { (code) in
//            print("connect")
//            for item in self.SubscribeTopics {
//                item.value.statusCallBack(OznerConnectStatus.Connected)
//            }
//        }
        
        mqttClient.connect(toHost: "api.easylink.io") { (code) in
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
                if let tmpdata=mess?.payload {
                    if tmpdata.count>0 {
                        callback.dataCallBack(tmpdata)
                    }
                    
                }
            }
        }
       
    }
    func subscribeTopic(topic:String,messageHandler:(dataCallBack:((Data)->Void),statusCallBack:((OznerConnectStatus)->Void))) {
        mqttClient.subscribe(topic+"/out", withQos: AtLeastOnce) { (_) in
        }
        SubscribeTopics[topic+"/out"]=messageHandler
        
    }
    func unSubscribeTopic(topic:String) {
        SubscribeTopics.removeValue(forKey: topic+"/out")
        mqttClient.unsubscribe(topic+"/out") {
        }
    }
    func sendData(data:Data,toTopic:String,callback:((Int32)->Void)!)  {
        mqttClient.publishData(data, toTopic: toTopic+"/in", withQos: AtMostOnce, retain: true, completionHandler: callback)
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
