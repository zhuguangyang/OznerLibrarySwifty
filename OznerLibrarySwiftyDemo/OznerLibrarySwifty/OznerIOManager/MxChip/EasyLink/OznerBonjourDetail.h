//
//  bonjourDetailTableViewController.h
//  MICO
//
//  Created by William Xu on 14-4-30.
//  Copyright (c) 2014年 MXCHIP Co;Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"//"AsyncSocket.h"
typedef void (^OznerWifiScanDataBlock)(NSString* deviceID);

typedef enum
{
    eState_start                        = -1,
    eState_ReadConfig                   = 0,
   
} _ConfigState_t;

@interface OznerBonjourDetail : NSObject{

@private
    NSString *_address;
    AsyncSocket *configSocket;
   
    CFHTTPMessageRef inComingMessage;
    NSMutableDictionary *configData;
    
    _ConfigState_t currentState;
    OznerWifiScanDataBlock oznerCallBackBlock;
}

- (id)init:(NSString *)newAddress block:(OznerWifiScanDataBlock)block;

@end
