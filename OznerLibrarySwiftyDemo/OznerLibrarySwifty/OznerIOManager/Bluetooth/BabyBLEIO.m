//
//  BabyBLEIO.m
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/27.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

#import "BabyBLEIO.h"

@implementation BabyBLEIO
{
    //CBService* curService;
    CBCharacteristic* writeCharacteristic;
    CBCharacteristic* readCharacteristic;
}
NSString* idString;
- (instancetype)init:(NSString*)identifier statusBlock:(BabyBLEStatusBlock)statusBlock sensorBlock:(BabyBLESensorBlock)sensorBlock {
    self = [super init];
    if (self) {
        idString=identifier;
        _babyBLEStatusBlock=statusBlock;//状态变化回掉block
        _babyBLESensorBlock=sensorBlock;//传感器数据变化回掉block
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        [baby cancelAllPeripheralsConnection];
        
        [self babyDelegate];//设置蓝牙委托
        //开始扫描设备
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5];
    }
    return self;
    
}
- (void)destroySelf{
    [baby AutoReconnectCancel:self.currPeripheral];
    [baby cancelAllPeripheralsConnection];
}

-(void)loadData{
    
    if (baby.centralManager.state==CBManagerStatePoweredOn) {
        self.currPeripheral=[baby retrievePeripheralWithUUIDString:idString];//获取外设
        _babyBLEStatusBlock(2);
        switch (self.currPeripheral.state) {//初始化设备状态
            case CBPeripheralStateConnected:
                _babyBLEStatusBlock(1);
                break;
            case CBPeripheralStateDisconnected:
                _babyBLEStatusBlock(-1);
                break;
            default:
                _babyBLEStatusBlock(0);
                break;
        }
        [baby AutoReconnect:self.currPeripheral];
        baby.having(self.currPeripheral).and.channel(idString).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    } else {
        _babyBLEStatusBlock(-2);
    }
    
}
//发送数据
- (void)sendDataToDevice:(NSData *)data block:(void (^)(NSError *error))block{
    if (self.currPeripheral != nil) {
        if (writeCharacteristic != nil) {
            [self.currPeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}
-(void)babyDelegate{
    __weak typeof(self)weakSelf = self;

    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        [weakSelf loadData];
    }];
    [baby setBlockOnCentralManagerDidUpdateStateAtChannel:idString block:^(CBCentralManager *central) {
        [weakSelf loadData];
    }];

    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:idString block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        if (![idString isEqualToString:peripheral.identifier.UUIDString]) {
            return ;
        }
        NSLog(@"设备：%@--连接成功",peripheral.name);
        weakSelf.babyBLEStatusBlock(1);
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:idString block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        if (![idString isEqualToString:peripheral.identifier.UUIDString]) {
            return ;
        }
        NSLog(@"设备：%@--连接失败",peripheral.name);
        weakSelf.babyBLEStatusBlock(-1);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:idString block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        if (![idString isEqualToString:peripheral.identifier.UUIDString]) {
            return ;
        }
        NSLog(@"设备：%@--断开连接",peripheral.name);
        weakSelf.babyBLEStatusBlock(-1);
    }];
    
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:idString block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if (![idString isEqualToString:peripheral.identifier.UUIDString]) {
            return ;
        }
        
//        CBService * service1=nil;
//        
//        for (CBService* s in [peripheral services])
//        {
//            if ([[[s UUID] UUIDString] isEqualToString:@"FFF0"])
//            {
//                NSLog(@"didDiscoverServices:%@",[[s UUID] UUIDString]);
//                service1=s;
//                [peripheral discoverCharacteristics:nil forService:service1];
//                sleep(3);
//                break;
//            }
//        }
//       
        
        
        for (CBCharacteristic* characteristic in service.characteristics)
        {
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF2"])
            {
                writeCharacteristic=characteristic;
            }
            if ([[[characteristic UUID] UUIDString] isEqualToString:@"FFF1"])
            {
                readCharacteristic=characteristic;
                [weakSelf setNotifiy];
                
            }
            if (writeCharacteristic != nil && readCharacteristic != nil) {
                weakSelf.babyBLEStatusBlock(3);
                break;
            }
        }
        
        
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:idString block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        if (![idString isEqualToString:peripheral.identifier.UUIDString]) {
            return ;
        }
        weakSelf.babyBLESensorBlock(characteristics.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:idString block:^(CBCharacteristic *characteristic, NSError *error) {
        weakSelf.babyBLESensorBlock(characteristic.value);
    }];
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@NO,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@NO,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@NO};
    
    [baby setBabyOptionsAtChannel:idString scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
//订阅一个值
-(void)setNotifiy{
    
    __weak typeof(self)weakSelf = self;
//    if(self.currPeripheral.state != CBPeripheralStateConnected) {
//        NSLog(@"peripheral已经断开连接，请重新连接");
//        return;
//    }
    if (self->readCharacteristic.properties & CBCharacteristicPropertyNotify ||  self->readCharacteristic.properties & CBCharacteristicPropertyIndicate) {
        
        if(!readCharacteristic.isNotifying) {
            
            [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self->readCharacteristic];
            
            [baby notify:self.currPeripheral
          characteristic:self->readCharacteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       if (weakSelf != nil) {
                           weakSelf.babyBLESensorBlock(characteristics.value);
                       }
                       
                   }];
        }
    }
    else{
        NSLog(@"这个characteristic没有nofity的权限");
        return;
    }
    
}
@end
