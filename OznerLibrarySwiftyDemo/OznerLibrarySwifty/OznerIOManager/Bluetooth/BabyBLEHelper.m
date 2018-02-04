//
//  BabyBLEHelper.m
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/27.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import "BabyBLEHelper.h"
//#import "ScanData.h"

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
#pragma mark -设备是否可以被搜索（RO Comml）

- (BOOL)isCanSearch:(NSDictionary *)advertisementData {
    NSData* macData1=nil;
    if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
    {
        NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
        CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
        macData1=[dict objectForKey:uuid];
    }
    
    NSData *data = [macData1 subdataWithRange:NSMakeRange(0, 8)];
    
    if (macData1.length < 18) {
        return true;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
    NSLog(@"%@",str);
    BytePtr bytes2 = (BytePtr)[[macData1 subdataWithRange:NSMakeRange(18, 1)] bytes];
    NSLog(@"%d",bytes2[0]);
    
    return bytes2[0] == 0 ? true : false;
}

#pragma mark -蓝牙配置和操作
-(NSString*)getMac:(NSDictionary *)advertisementData Name:(NSString*)name {
    NSString* MAC=@"";
    NSData* macData1=nil;
    NSData* macData2=nil;
    if ([advertisementData objectForKey:CBAdvertisementDataServiceDataKey])
    {
        NSDictionary* dict=[advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
        CBUUID* uuid=[CBUUID UUIDWithString:@"FFF0"];
        macData1=[dict objectForKey:uuid];
    }
    
    if ([advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey]){
        macData2=[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    }
    if ([name isEqualToString:@"Ozner RO"]&&macData1.length>23) {
        BytePtr bytes=(BytePtr)[macData1 bytes];
        MAC=[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
             bytes[23],bytes[22],bytes[21],bytes[20],bytes[19],bytes[18]];
    }
    if ([name isEqualToString:@"智能水杯"]&&macData1.length>23) {
        BytePtr bytes=(BytePtr)[macData1 bytes];
        MAC=[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
             bytes[23],bytes[22],bytes[21],bytes[20],bytes[19],bytes[18]];
    }
    if ([name isEqualToString:@"Ozner Cup"]&&macData2.length>5) {
        BytePtr bytes=(BytePtr)[macData2 bytes];
        MAC=[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
             bytes[5],bytes[4],bytes[3],bytes[2],bytes[1],bytes[0]];
    }
    
    if ([name isEqualToString:@"RO Comml"] && (macData1.length < 20)) {
        BytePtr bytes = (BytePtr)[macData1 bytes];
        MAC = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
               bytes[5],bytes[4],bytes[3],bytes[2],bytes[1],bytes[0]];
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
                       bytes[7],bytes[6],bytes[5],bytes[4],bytes[3],bytes[2]];
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
        sleep(1);
//        if ([peripheral.name isEqualToString:@"RO Comml"]) {
//
//            weakSelf.babyBLEScanDataBlock(peripheral.identifier.UUIDString,peripheral.name,mac,[weakSelf calcDistByRSSI:RSSI.intValue],advertisementData);
//
//        } else {
        
            weakSelf.babyBLEScanDataBlock(peripheral.identifier.UUIDString,peripheral.name,mac,[weakSelf calcDistByRSSI:RSSI.intValue],advertisementData);
//        }
        NSLog(@"发现设备name:%@,距离:%d,mac:%@",peripheral.name,RSSI.intValue,mac);
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        BOOL isCanSearch = false;
        
        if ([peripheralName  isEqual: @"RO Comml"]) {

            isCanSearch = [weakSelf isCanSearch:advertisementData];
        }
        
        if (peripheralName == nil || ([peripheralName  isEqual: @"RO Comml"]  && isCanSearch)) {
            return NO;
        }
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
