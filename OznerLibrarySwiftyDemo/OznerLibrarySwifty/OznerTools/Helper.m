//
//  Helper.m
//  MxChip
//
//  Created by Zhiyongxu on 15/12/3.
//  Copyright © 2015年 Zhiyongxu. All rights reserved.
//

#import "Helper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


static Byte findKey[]={0x23, 0x23, 0x24, 0x24, 0x40, 0x40, 0x2a, 0x2a, 0x54, 0x61, 0x70, 0x00};

@implementation Helper

+(uint8_t)Crc8:(uint8_t*) inBuffer inLen:(uint16_t)inLen
{
    uint8_t Crc8Table[] = { 0x00, 0x07, 0x0E,
        0x09, 0x1C, 0x1B, 0x12, 0x15, 0x38, 0x3F, 0x36, 0x31, 0x24,
        0x23, 0x2A, 0x2D, 0x70, 0x77,
        0x7E, 0x79, 0x6C, 0x6B, 0x62,
        0x65, 0x48, 0x4F, 0x46, 0x41,
        0x54, 0x53, 0x5A, 0x5D, 0xE0,
        0xE7, 0xEE, 0xE9, 0xFC, 0xFB,
        0xF2, 0xF5, 0xD8, 0xDF, 0xD6,
        0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
        0x90, 0x97, 0x9E, 0x99, 0x8C,
        0x8B, 0x82, 0x85, 0xA8, 0xAF,
        0xA6, 0xA1, 0xB4, 0xB3, 0xBA,
        0xBD, 0xC7, 0xC0, 0xC9, 0xCE,
        0xDB, 0xDC, 0xD5, 0xD2, 0xFF,
        0xF8, 0xF1, 0xF6, 0xE3, 0xE4,
        0xED, 0xEA, 0xB7, 0xB0, 0xB9,
        0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
        0x8F, 0x88, 0x81, 0x86, 0x93,
        0x94, 0x9D, 0x9A, 0x27, 0x20,
        0x29, 0x2E, 0x3B, 0x3C, 0x35,
        0x32, 0x1F, 0x18, 0x11, 0x16,
        0x03, 0x04, 0x0D, 0x0A, 0x57,
        0x50, 0x59, 0x5E, 0x4B, 0x4C,
        0x45, 0x42, 0x6F, 0x68, 0x61,
        0x66, 0x73, 0x74, 0x7D, 0x7A,
        0x89, 0x8E, 0x87, 0x80, 0x95,
        0x92, 0x9B, 0x9C, 0xB1, 0xB6,
        0xBF, 0xB8, 0xAD, 0xAA, 0xA3,
        0xA4, 0xF9, 0xFE, 0xF7, 0xF0,
        0xE5, 0xE2, 0xEB, 0xEC, 0xC1,
        0xC6, 0xCF, 0xC8, 0xDD, 0xDA,
        0xD3, 0xD4, 0x69, 0x6E, 0x67,
        0x60, 0x75, 0x72, 0x7B, 0x7C,
        0x51, 0x56, 0x5F, 0x58, 0x4D,
        0x4A, 0x43, 0x44, 0x19, 0x1E,
        0x17, 0x10, 0x05, 0x02, 0x0B,
        0x0C, 0x21, 0x26, 0x2F, 0x28,
        0x3D, 0x3A, 0x33, 0x34, 0x4E,
        0x49, 0x40, 0x47, 0x52, 0x55,
        0x5C, 0x5B, 0x76, 0x71, 0x78,
        0x7F, 0x6A, 0x6D, 0x64, 0x63,
        0x3E, 0x39, 0x30, 0x37, 0x22,
        0x25, 0x2C, 0x2B, 0x06, 0x01,
        0x08, 0x0F, 0x1A, 0x1D, 0x14,
        0x13, 0xAE, 0xA9, 0xA0, 0xA7,
        0xB2, 0xB5, 0xBC, 0xBB, 0x96,
        0x91, 0x98, 0x9F, 0x8A, 0x8D,
        0x84, 0x83, 0xDE, 0xD9, 0xD0,
        0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
        0xE6, 0xE1, 0xE8, 0xEF, 0xFA,
        0xFD, 0xF4, 0xF3 };
    
    uint8_t TempCrc, TempN;
    TempCrc = 0;
    for (TempN=0;TempN<inLen;TempN++) {
        TempCrc ^= inBuffer[TempN];
        TempCrc=Crc8Table[TempCrc];
    }
    return TempCrc;
}

+ (NSData *) stringToHexData:(NSString*)str
{
    long len = [str length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

+(NSString*)md5:(NSString*)str
{
    if (StringIsNullOrEmpty(str)) return nil;
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (uint)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

+(NSString*)rndString:(int)len
{
    char HexString[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    NSMutableString * ret=[[NSMutableString alloc] init];
    uint key=(int)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    
    for (int i=0;i<len;i++)
    {
        
        rand_r(&key);
        
        uint rnd=key%sizeof(HexString);
        [ret appendFormat:@"%c",HexString[rnd]];
    }
    return ret;
}
bool StringIsNullOrEmpty(NSString* str)
{
    if (!str)
        return true;
    if ([str isEqualToString:@""]) return true;
    return false;
}
+ (NSString *) getDeviceIDFromService:(NSString*)ipAdress Login_id:(NSString*)login_id PassWord:(NSString*)passWord{
    
    @try {
        NSString* url=[NSString stringWithFormat:@"http://%@:%d/dev-activate",ipAdress,8000];
        NSMutableURLRequest* request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSMutableDictionary* dict=[[NSMutableDictionary alloc] init];
        [dict setObject:login_id forKey:@"login_id"];
        [dict setObject:passWord forKey:@"dev_passwd"];
        int token=[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]*1000;
        [dict setObject:[NSString stringWithFormat:@"%d",token] forKey:@"user_token"];
        NSError* error;
        NSError* jerror;
        
        NSData* data=[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        [request addValue:[NSString stringWithFormat:@"%d",(int)data.length] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
        NSData* respone=[NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&error];
        if (error!=NULL)
        {
            NSLog(@"request %@",[error debugDescription]);
        }
        NSDictionary* json= [NSJSONSerialization JSONObjectWithData:respone
                                                            options:NSJSONReadingMutableLeaves error:&jerror];
        
        return [NSString stringWithString:[json objectForKey:@"device_id"]];
    }
    @catch (NSException *exception) {
        NSLog(@"active exception:%@",[exception debugDescription]);
    }
    @finally {
        
    }
    return @"";

}
+ (void)post:(NSString *)URL RequestParams:(NSDictionary *)params FinishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError)) block{
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:URL];
    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    //解析请求参数，用NSDictionary来存参数，通过自定义的函数parseParams把它解析成一个post格式的字符串
    NSString *parseParamsResult = [self parseParams:params];
    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    //创建一个新的队列（开启新线程）
    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:block];
    //    return result;
}
//把NSDictionary解析成post格式的NSString字符串
+ (NSString *)parseParams:(NSDictionary *)params{
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    //实例化一个key枚举器用来存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&",key,[params valueForKey:key]];
        [result appendString:keyValueFormat];
    }
    return result;
}

+ (int)OTACheckSumWithFileStr:(NSString *)filepath
{

    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSData *file = [NSData dataWithContentsOfFile:filepath];
    
    int Size = (int)file.length;
    
    if ((Size % 256) != 0) {
        
        Size = (Size/256) * 256 + 256;
    }
    int CheckSum = 0;
    Byte* bytes = alloca(Size);
    @try {
        
        memset(bytes, 0, Size);
        memcpy(bytes, [file bytes], file.length);
        long temp = 0;
        int len = Size/4;
        long TempMask = 0x1FFFFFFFFL-0x100000000L;

        for (int i = 0; i < len; i++) {
            temp += *((UInt32*)bytes + i*4);
            
        }
        
        CheckSum = (int)(temp & TempMask);
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        free(bytes);
    }
    
    return CheckSum;
    
}

+ (int)loadFileWithpath:(NSString *)path
{
    
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:path];
    //    Byte *firmware = alloca(fileData.length);
    //    memset(firmware, 0, fileData.length);
    //    memcpy(firmware, [fileData bytes], fileData.length);
    //    int Size = [self CheckFirmwareSizeWithbyte:firmware];
    
    NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
    
    //绕过第一步 验证
    int Size = (int)fileData.length;
    
    if (Size > 127 * 1024) {
        NSLog(@"文件太大");
    }
    
    if (Size %256 != 0) {
        Size = (Size / 256) * 256 + 256;
    }
    
    Byte* bytes = alloca(Size);
    int checkSum= 0;
    
    @try {
        memset(bytes, 0x00, Size);
        memcpy(bytes, fileData.bytes, fileData.length);
        
        Boolean ver = false;
        
        for (int i = 0; i < Size - sizeof(findKey); i++) {
            ver = false;
            for (int x = 0;x < sizeof(findKey); x++) {
                
                if (findKey[x] == bytes[i + x]) {
                    ver = true;
                } else {
                    ver = false;
                    break;
                }
                
            }
            
            if (ver) {
                Byte *subBytes = alloca(8);
                
                [self bytesplit2byte:bytes orc:subBytes begin:i = 8 count:8];
                
                NSString *check = [[NSString alloc] initWithBytes:bytes length:8 encoding:NSASCIIStringEncoding];
                NSLog(@"%@",check);
                if (![@"OznerROB" isEqualToString:check]) {
                    NSLog(@"错误的文件");
                }
                break;
            }
        }
        
        int myLoc1 = 0;
        int myLoc2 = 0;
        
        for (int i = 0; i < Size - 6; i++) {
            if ((bytes[i] == 0x12) && (bytes[i + 1] == 0x34) && (bytes[i + 2] == 0x56)
                && (bytes[i + 3] == 0x65) && (bytes[i + 4] == 0x43) && (bytes[i + 5] == 0x21)) {
                if (myLoc1 == 0)
                    myLoc1 = i;
                else
                    myLoc2 = i;
            }
        }
        NSLog(@"%d---%d",myLoc1,myLoc2);
        
        if (myLoc1!=0)
        {
            //            bytes[myLoc1 + 5] = (Byte) [self hexToint:[@"123" substringWithRange:NSMakeRange(0, 2)]];
            //            bytes[myLoc1 + 4] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(3, 2)]];
            //            bytes[myLoc1 + 3] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(6, 2)]];
            //            bytes[myLoc1 + 2] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(9, 2)]];
            //            bytes[myLoc1 + 1] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(12, 2)]];
            //            bytes[myLoc1] = (Byte) [self hexToint:[self.mac substringWithRange:NSMakeRange(15, 2)]];
        }
        if (myLoc2 != 0) {
            bytes[myLoc2 + 5] = bytes[myLoc1];
            bytes[myLoc2 + 4] = bytes[myLoc1 + 1];
            bytes[myLoc2 + 3] = bytes[myLoc1 + 2];
            bytes[myLoc2 + 2] = bytes[myLoc1 + 3];
            bytes[myLoc2 + 1] = bytes[myLoc1 + 4];
            bytes[myLoc2] = bytes[myLoc1 + 5];
        }
        
        long temp = 0;
        
        int len = Size / 4;
        for (int i = 0; i < len; i++) {
            temp += [self getBigHost:bytes index:i * 4];
        }
        long TempMask = 0x1FFFFFFFFL-0x100000000L;
        checkSum = (int) (temp & TempMask);
        NSLog(@"%d",(int)checkSum);
        NSLog(@"%d",0xc0 & 0x0ff);
        NSLog(@"%d",checkSum & 0x7fffffff);
        return checkSum;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        //        free(bytes);
        [stream close];
        return checkSum;
    }
    
}

+ (int)getBigHost:(Byte[])byte index:(int)index {
    
    return  (((byte[index + 3] & 0xff) <<  24) | ((byte[index + 2] & 0xff) <<  16) | ((byte[index + 1] & 0xff) <<  8) | (byte[index] & 0xff));
    
}

+ (void)bytesplit2byte:(Byte[])src orc:(Byte[])orc begin:(NSInteger)begin count:(NSInteger)count{
    memset(orc, 0, sizeof(char)*count);
    for (NSInteger i = begin; i < begin+count; i++){
        orc[i-begin] = src[i];
    }
}
@end
