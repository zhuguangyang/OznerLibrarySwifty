//
//  NSDictionary+ZBKeyMapping.h
//  Learning
//
//  Created by WuZhengBin on 16/5/20.
//  Copyright © 2016年 WuZhengBin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZBKeyMapping)
- (NSDictionary *)zbRemapKeyWithMappingDictionary:(NSDictionary *)keyMappingDic removingNullValues:(BOOL)removeNulls;
@end
