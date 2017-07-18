//
//  BabyBLEHelper.m
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/27.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import "BabyBLEHelper.h"


@implementation BabyBLEHelper
{
    BabyBluetooth *baby;
    
}
//单例模式
+ (instancetype)shareBabyBLEHelper {
    static BabyBLEHelper *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[BabyBLEHelper alloc]init];
    });
    return share;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        
    }
    return self;
    
}
NSString* deviceName=nil;
-(void)starScan:(int)scanTimer deviceName:(NSString*)name block:(BabyBLEScanDataBlock)block failblock:(BabyBLEScanFailedBlock)failblock{
    deviceName=name;
    _babyBLEScanDataBlock=block;
    _babyBLEScanFailedBlock=failblock;
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin().stop(scanTimer);
}
-(void)cancelScan{
    //停止扫描
    [baby cancelScan];
}
- (float)calcDistByRSSI:(int)rssi
{
    int iRssi = abs(rssi);
    float power = (iRssi-59)/(10*2.0);
    return pow(10, power);
}
#pragma mark -蓝牙配置和操作
-(NSString*)getMac:(NSDictionary *)advertisementData Name:(NSString*)name {
    NSString* MAC=@"";
    if (![name isEqualToString:@"Ozner Cup"]) {
        
        if ([advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey])
        {
            NSData* data=[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
            
            BytePtr bytes=(BytePtr)[data bytes];
            MAC = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                         bytes[7],bytes[6],bytes[5],bytes[4],bytes[3],bytes[2]];
        }
    }
    //台式空净OAP、0x20
    //水杯、
    //RO蓝牙水机、0x11
    
    if ([MAC  isEqual: @""]) {
        if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
        {
            NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
            CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
            NSData* data=[dict objectForKey:uuid];
            BytePtr bytes=(BytePtr)[data bytes];
            if (data != nil && data.length>7) {
                MAC = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                       bytes[6],bytes[5],bytes[4],bytes[3],bytes[2],bytes[1]];
            }
        }
    }
    
    return MAC;
}
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state != CBCentralManagerStatePoweredOn) {
            weakSelf.babyBLEScanFailedBlock(1);
            [weakSelf cancelScan];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSString* mac=[weakSelf getMac:advertisementData Name:peripheral.name];
        weakSelf.babyBLEScanDataBlock(peripheral.identifier.UUIDString,peripheral.name,mac,[weakSelf calcDistByRSSI:RSSI.intValue],advertisementData);
        NSLog(@"发现设备name:%@,距离:%d,mac:%@",peripheral.name,RSSI.intValue,mac);
    }];
    
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([deviceName containsString:peripheralName]) {
            return YES;
        }
        return NO;
    }];
    
    
    
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
        weakSelf.babyBLEScanFailedBlock(2);
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSArray *scanForPeripheralsWithServices = @[[CBUUID UUIDWithString:@"FFF0"]];
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:nil discoverWithCharacteristics:nil];
}
@end
