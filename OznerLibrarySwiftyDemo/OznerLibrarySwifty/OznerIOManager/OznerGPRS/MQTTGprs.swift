//
//  OzneMQTTGprs.swift
//  OznerLibrarySwiftyDemo
//
//  Created by ZGY on 2017/9/19.
//  Copyright © 2017年 net.ozner. All rights reserved.
//
//  Author:        Airfight
//  My GitHub:     https://github.com/airfight
//  My Blog:       http://airfight.github.io/
//  My Jane book:  http://www.jianshu.com/users/17d6a01e3361
//  Current Time:  2017/9/19  下午3:52
//  GiantForJade:  Efforts to do my best
//  Real developers ship.

import UIKit
import MQTTKit


class MQTTGprs: NSObject {
    
    private var mqttClient:MQTTClient!
    
    static let `instance`: MQTTGprs = MQTTGprs()
    
    typealias dataCallBlock = (dataCallBack:((Data)->Void),statusCallBack:((OznerConnectStatus)->Void))
    
    private var SubscribeTopics:[String:dataCallBlock]!
    
    override init() {
        
        super.init()
        
        SubscribeTopics=[String:dataCallBlock]()
        
        mqttClient = MQTTClient(clientId: "1231zhu777777788")
        mqttClient.port=1884
        
        mqttClient.username="17621050877"//手机号
        var token = "12345678" + "@\(mqttClient.username!)" + "@\(mqttClient.clientID!)"
        
        token = Helper.gprsEncryption(token)
        print("加密后的password:\(token)")
        mqttClient.password=token//token
        mqttClient.keepAlive=60
        
        mqttClient.cleanSession=false
        
        //http://iot.ozner.net:1884 (内网地址请使用192.168.173.21:1884)
        mqttClient.connect(toHost: "iot.ozner.net") { (code) in
            
            switch code {
            case ConnectionAccepted:
                
                print("连接成功!")
                
//                self.mqttClient.subscribe("AirPurifier/f0fe6b49d02d", withQos: AtLeastOnce) { (dic) in
//                    
//                }
                for (key,value) in self.SubscribeTopics {
                    self.mqttClient.subscribe(key, withQos: AtLeastOnce, completionHandler: { (_) in
                    })
                    value.statusCallBack(OznerConnectStatus.Connected)
                }
                
            default:
                for item in self.SubscribeTopics {
                    item.value.statusCallBack(OznerConnectStatus.Disconnect)
                }
            }
            
        }
        
        mqttClient.messageHandler = { (message) in
            if let callback = self.SubscribeTopics[message?.topic ?? "none"] {
                
                if let playData = message?.payload {
                    
                    callback.dataCallBack(playData)
                    
                }
                
            }
            print(message?.payloadString() ?? "")
            
        }

    }
}
