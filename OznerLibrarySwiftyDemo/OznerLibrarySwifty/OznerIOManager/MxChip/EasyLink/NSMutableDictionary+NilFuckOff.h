//
//  NSMutableDictionary+NilFuckOff.h
//  Pods
//
//  Created by WuZhengBin on 16/3/4.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NilFuckOff)
/**
 *  用于接口传值，如果 object 为空，则不插入字典
 *
 *  @param object
 *  @param aKey
 */
- (void)safeSetObject:(id)object forKey:(id<NSCopying>)aKey;
@end
