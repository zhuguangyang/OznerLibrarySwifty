//
//  BabyBLEIO.h
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/27.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"
typedef void (^BabyBLEStatusBlock)(int status);

typedef void (^BabyBLESensorBlock)(NSData* data);

typedef void(^BabyBLEFailureBlock)(NSError *error);

@interface BabyBLEIO : NSObject
{
@public
    BabyBluetooth *baby;
}
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (nonatomic, copy) BabyBLEStatusBlock babyBLEStatusBlock;//-2 手机蓝牙未断开,-1 设备连接失败,1 设备连接成功,2 手机蓝牙连接
@property (nonatomic, copy) BabyBLESensorBlock babyBLESensorBlock;//传感器数据变化回掉block

@property (nonatomic,copy) BabyBLEFailureBlock babyFailureBlock;

- (instancetype)init:(NSString*)identifier statusBlock:(BabyBLEStatusBlock)statusBlock sensorBlock:(BabyBLESensorBlock)sensorBlock;
- (void)sendDataToDevice:(NSData *)data block:(void (^)(NSError *error))block;
- (void)destroySelf;


@end
