//
//  NSMutableDictionary+NilFuckOff.m
//  Pods
//
//  Created by WuZhengBin on 16/3/4.
//
//

#import "NSMutableDictionary+NilFuckOff.h"

@implementation NSMutableDictionary (NilFuckOff)
- (void)safeSetObject:(id)object forKey:(id<NSCopying>)aKey
{
    if (object) {
        [self setObject:object forKey:aKey];
    }
}   
@end
