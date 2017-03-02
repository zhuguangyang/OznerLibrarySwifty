//
//  WaterReplenishStatus.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/6.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class WaterReplenishStatus: NSObject {
   
    private(set) var power:Bool = false//电源
    private(set) var testing:Bool = false//检测状态 ，(检测中，未在检测中）
    private(set) var battery:Int = 0//电量
    private(set) var moisture:Float = 0//水分
    private(set) var oil:Float = 0//油分
    
    private let testValueTable:[[Float]] = [
        [8, 220, -1, -1, -1, -1, 0, 0],
        [220,300,0.093,20 ,28 ,0.042,9 ,13],
        [300,350,0.092,28 ,32 ,0.041,12 ,14],
        [350,400,0.09,32 ,36 ,0.04,14 ,16],
        [400,450,0.089,36 ,40 ,0.039,16 ,18],
        [450,500,0.088,40 ,44 ,0.038,17 ,19],
        [500,600,0.087,44 ,52 ,0.037,19 ,22],
        [600,700,0.086,52 ,60 ,0.036,22 ,25],
        [700,800,0.085,60 ,68 ,0.035,25 ,28],
        [800,1023,0.084,67 ,86 ,0.034,27 ,35]
    ]
    
    func startTest()  {
        testing=true
        moisture=0
        oil=0
    }

    func loadTest(adc:Float) {
        
        for item in testValueTable {
            
            if adc>item[0]&&adc<item[1] {
                moisture=abs(item[1]-item[0])*item[2]+item[3]
                oil=abs(item[1]-item[0])*item[5]+item[6]
                break
            }
        }
        testing=false
    }
    func loadData(data:Data) {
        power=Int(data[1])==1
        battery=Int(data[2])
    }
    func reset()  {
        power = false//电源
        testing = false//检测状态 ，(检测中，未在检测中）
        battery = 0//电量
        moisture = 0//水分
        oil = 0//油分
    }
}
