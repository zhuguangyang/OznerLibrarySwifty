//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



func dataFromInt(number:CLongLong,length:Int)->Data{
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

dataFromInt(number: CLongLong(20), length: 2)
MemoryLayout<UInt16>.size

func dataFromInt16(number:UInt16)->Data {
    
    let data = NSMutableData()
    var val = CFSwapInt16LittleToHost(number)
    
    data.append(&val, length: MemoryLayout<UInt16>.size)
    
    return data as Data
}

dataFromInt16(number: UInt16(20))
