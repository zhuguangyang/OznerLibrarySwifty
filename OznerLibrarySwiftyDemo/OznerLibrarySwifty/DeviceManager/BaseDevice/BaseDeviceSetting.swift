//
//  BaseDeviceSetting.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

class BaseDeviceSetting: NSObject {
    //设备名称
    var name:String!{
        set{
            
            SetValue(key: "name", value:newValue )
        }
        get{
            return GetValue(key: "name", defaultValue: "浩泽")
        }
    }
    //使用地点
    var useAdress:String!{
        set{
            SetValue(key: "useAdress", value: newValue)
        }
        get{
            return GetValue(key: "useAdress", defaultValue: "家")
        }
    }
    private var values:[String:String]!
    required init(json:String?) {
        values=[String:String]()
        if json != nil && json != "" {
            let data = json?.data(using: String.Encoding.utf8)
            
            values = try! JSONSerialization.jsonObject(with: data!,
                                                            options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: String]
        }
    }
    func GetValue(key:String,defaultValue:String) -> String {
        if let value=values[key] {
            return value
        }else{
            return defaultValue
        }
    }
    func SetValue(key:String,value:String) {
        values[key]=value
    }
    func toJsonString() -> String {
        //首先判断能不能转换
        if !JSONSerialization.isValidJSONObject(values) {
            print("is not a valid json object")
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: values, options: [])
        //Data转换成String打印输出
        return String(data:data!, encoding: String.Encoding.utf8)!
    }
}
