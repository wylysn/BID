//
//  ListenSocketServer.h
//  hp
//
//  Created by wangyilu on 16/6/1.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//
#define PORT 9019

//#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@import CocoaAsyncSocket;

@protocol ListenSocketDelegate <NSObject>

- (void) socketcomeInOut:(int)flag withSocket:(GCDAsyncSocket *)socket;

- (void) displayPic:(NSString *)key;
- (void) displayPricePic:(NSString *)key;

@end

@interface ListenSocketServer : NSObject<GCDAsyncSocketDelegate> {
    dispatch_queue_t socketQueue;
    BOOL isRunning;
}

@property (nonatomic, strong) GCDAsyncSocket *listenSocket;
@property (nonatomic, strong) NSMutableArray *connectedSockets;
@property (nonatomic, strong) NSMutableDictionary *socketsDics;
@property (nonatomic, strong) NSMutableArray *pricePicOkArr;
@property (nonatomic, strong) NSMutableArray *picOkArr;

@property (nonatomic, weak) id<ListenSocketDelegate> delegate;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (BOOL)isValidatIP:(NSString *)ipAddress;
+ (NSDictionary *)getIPAddresses;
+ (int)getPort;

-(void) start;

-(void) stop;

@end
