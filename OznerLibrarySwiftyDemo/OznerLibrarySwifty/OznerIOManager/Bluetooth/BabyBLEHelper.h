//
//  BabyBLEHelper.h
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/27.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"
typedef void (^BabyBLEScanDataBlock)(NSString* identifier,int distance,NSDictionary* data);
typedef void (^BabyBLEScanFailedBlock)(int code);
@interface BabyBLEHelper : NSObject
@property (nonatomic, copy) BabyBLEScanDataBlock babyBLEScanDataBlock;
@property (nonatomic, copy) BabyBLEScanFailedBlock babyBLEScanFailedBlock;
/**
 * 单例构造方法
 * @return BabyBluetooth共享实例
 */
+ (instancetype)shareBabyBLEHelper;
-(void)starScan:(int)scanTimer deviceName:(NSString*)name block:(BabyBLEScanDataBlock)block failblock:(BabyBLEScanFailedBlock)failblock;
-(void)cancelScan;
@end
