//
//  OznerTools.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/5.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class OznerTools: NSObject {
    class func dataFromInt(number:CLongLong,length:Int)->Data{
        var data=Data()
        if length<1 {
            return data
        }
        var tmpValue = CLongLong(0)
        for i in 0...(length-1) {
            let powInt = CLongLong(pow(CGFloat(256), CGFloat(i)))
            let needEle=(number-tmpValue)/powInt%256
            data.append(UInt8(needEle))
            tmpValue+=CLongLong(needEle)*powInt
        }
        return data
    }
}
