//
//  bonjourDetailTableViewController.m
//  MICO
//
//  Created by William Xu on 14-4-30.
//  Copyright (c) 2014年 MXCHIP Co;Ltd. All rights reserved.
//

#import "OznerBonjourDetail.h"
#import <sys/socket.h>
#import <netinet/in.h>
#include <arpa/inet.h>



@implementation OznerBonjourDetail

- (id)init:(NSString *)newAddress block:(OznerWifiScanDataBlock)block
{
    if((self = [super init]))
    {
        oznerCallBackBlock=nil;
        oznerCallBackBlock=block;
        currentState = eState_start;
        if (_address != newAddress) {
            _address = newAddress;
            NSError *err;
            configSocket = [[AsyncSocket alloc] initWithDelegate:self];
            [configSocket connectToHost:_address onPort:8000 withTimeout:4.0 error:&err];
            currentState = eState_ReadConfig;
        }
    }
    return self;
}




- (void)dealloc
{
    NSLog(@"%@ dealloced", [self class]);
    if(configSocket){
        [configSocket disconnect];
        [configSocket setDelegate:nil];
        configSocket = nil;
    }
}




#pragma mark - AsyncSocket delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connected");
    
    inComingMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
    
    if(currentState == eState_ReadConfig){
        CFURLRef urlRef = CFURLCreateWithString(kCFAllocatorDefault, CFSTR("/config-read"), NULL);
        CFHTTPMessageRef httpRequestMessage = CFHTTPMessageCreateRequest (kCFAllocatorDefault,
                                                                          CFSTR("GET"),
                                                                          urlRef,
                                                                          kCFHTTPVersion1_1);
        CFHTTPMessageSetHeaderFieldValue(httpRequestMessage, CFSTR("Connection"), CFSTR("close"));
        CFDataRef httpData = CFHTTPMessageCopySerializedMessage ( httpRequestMessage );
        [sock writeData:(__bridge NSData*)httpData withTimeout:-1 tag:0];
        CFRelease(httpData);
        CFRelease(httpRequestMessage);
        CFRelease(urlRef);
        
        [sock readDataWithTimeout:-1 tag:0];
    }

}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSError *err;
    NSUInteger contentLength, currentLength;
    
    CFHTTPMessageAppendBytes(inComingMessage, [data bytes], [data length]);
    if (!CFHTTPMessageIsHeaderComplete(inComingMessage)){
        [sock readDataWithTimeout:100 tag:tag];
        return;
    }
    
    CFDataRef bodyRef = CFHTTPMessageCopyBody (inComingMessage );
    NSData *body = (__bridge_transfer NSData*)bodyRef;
    
    CFStringRef contentLengthRef = CFHTTPMessageCopyHeaderFieldValue (inComingMessage, CFSTR("Content-Length") );
    contentLength = [(__bridge NSString*)contentLengthRef intValue];
    
    currentLength = [body length];
    NSLog(@"%lu/%lu", (unsigned long)currentLength, (unsigned long)contentLength);
    
    if(currentLength < contentLength){
        [sock readDataToLength:(contentLength-currentLength) withTimeout:100 tag:(long)tag];
        return;
    }
    
#ifdef DEBUG
    CFURLRef urlRef = CFHTTPMessageCopyRequestURL(inComingMessage);
    CFStringRef urlPathRef= CFURLCopyPath (urlRef);
    NSString *urlPath= (__bridge NSString*)urlPathRef;
    NSLog(@"URL: %@", urlPath);
    CFRelease(urlRef);
    CFRelease(urlPathRef);
#endif
    
    if(currentState == eState_ReadConfig){
        configData = [NSJSONSerialization JSONObjectWithData:body
                                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                        error:&err];
        NSLog(@"Recv JSON data, length: %lu", (unsigned long)[body length]);
        
        if (err) {
            return;
        }
        NSString* deviceIDNeed=[[[[[configData objectForKey:@"C"] objectAtIndex:2] objectForKey:@"C"] objectAtIndex:3] objectForKey:@"C"];
        NSLog(@"%@",deviceIDNeed);
        oznerCallBackBlock(deviceIDNeed);
    }
    
}



- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"disconnected");
    if(inComingMessage) {
        CFRelease(inComingMessage);
        inComingMessage = NULL;
    }
    sock = nil;
    currentState = eState_start;
    
}



@end
