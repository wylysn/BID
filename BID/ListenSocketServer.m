//
//  ListenSocketServer.m
//  hp
//
//  Created by wangyilu on 16/6/1.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15
#define READ_TIMEOUT_EXTENSION 10.0

#import "ListenSocketServer.h"
#import "ConnectInfo.h"

@implementation ListenSocketServer {

}

#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
+ (int)getPort
{
    return PORT;
}

- (id)init
{
    if((self = [super init]))
    {
        socketQueue = dispatch_queue_create("socketQueue", NULL);
        
        self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        
        // Setup an array to store all accepted client connections
        self.connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        
        isRunning = NO;
        
        self.socketsDics = [[NSMutableDictionary alloc] init];
//        self.socketsDicskeyArr = [[NSMutableArray alloc] initWithCapacity:1];
        self.picOkArr = [[NSMutableArray alloc] init];
        self.pricePicOkArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) start {
    NSError *error = nil;
    if(![self.listenSocket acceptOnPort:PORT error:&error])
    {
        NSLog(@"Error starting server: %@", error);
        return;
    }
    
    NSLog(@"Echo server started on port %hu", [self.listenSocket localPort]);
    isRunning = YES;
}

- (void) stop {
    // Stop accepting connections
    [self.listenSocket disconnect];
    
    //Stop any client connections
    @synchronized(self.connectedSockets)
    {
        NSUInteger i;
        for (i = 0; i < [self.connectedSockets count]; i++)
        {
            // Call disconnect on the socket,
            // which will invoke the socketDidDisconnect: method,
            // which will remove the socket from the list.
            [[self.connectedSockets objectAtIndex:i] disconnect];
        }
    }
    
    @synchronized(self.socketsDics)
    {
        for (id akey in [self.socketsDics allKeys]) {
            [self.socketsDics removeObjectForKey:akey];
        }
    }
    
    @synchronized(self.picOkArr)
    {
        [self.picOkArr removeAllObjects];
    }
    
    @synchronized(self.pricePicOkArr)
    {
        [self.pricePicOkArr removeAllObjects];
    }
    
    NSLog(@"Stopped Echo server............");
    isRunning = false;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    
    @synchronized(self.connectedSockets)
    {
        [self.connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSLog(@"Accepted client %@:%hu", host, port);
        }
    });
    
    NSString *welcomeMsg = @"iphone\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
//    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    //我改的
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    
    if (tag == ECHO_MSG)
    {
//        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
        //我改的
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            //var client=dictory.get(sock);
            NSString *key = [NSString stringWithFormat: @"%lu", (unsigned long)sock.hash];
            NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
            NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
            NSLog(@"接收到的信息：%@", msg);
            if (![@"heartbeat" isEqualToString:msg]) {
//                NSMutableDictionary *tempDic = self.socketsDics[sock.connectedHost];
                if (![[self.socketsDics allKeys] containsObject: key]) {
                    ConnectInfo *info = [[ConnectInfo alloc] init];
                    NSArray *infoArr = [msg componentsSeparatedByString:@","];
                    if (infoArr.count>0) {
                        info.userName = infoArr[0];
                    }
                    if (infoArr.count>1) {
                        info.password = infoArr[1];
                    }
                    if (infoArr.count>2) {
                        info.t1 = infoArr[2];
                    }
                    if (infoArr.count>3) {
                        info.t2 = infoArr[3];
                    }
                    info.IP = sock.connectedHost;
                    info.port = [NSString stringWithFormat:@"%hu", sock.connectedPort];
                    @synchronized(self.socketsDics)
                    {
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        [dic setObject:info forKey:@"connectinfo"];
                        [dic setObject:sock forKey:@"socketinfo"];
                        
                        [self.socketsDics setObject:dic forKey:key];
//                        [self.socketsDicskeyArr addObject:sock.connectedHost];
                        [self.delegate socketcomeInOut:1 withSocket:sock];
                    }
                } else {
                    ConnectInfo *info = self.socketsDics[key][@"connectinfo"];
                    if ([msg hasPrefix:@"RII:"]) {
                        NSArray *msgArr = [msg componentsSeparatedByString:@":"];
                        if (![@"100" isEqualToString:msgArr[1]]) {
                            info.messages = [[NSMutableString alloc] init];
                            [info.messages appendString:msg];

                            info.pic1 = [[NSImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:msgArr[3] options:0]];
                            //[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:msgArr[3] options:0]] ;//msgArr[3];
//                            info.pic2 = msgArr[4];
                            info.isOk = YES;
                            @synchronized(self.picOkArr)
                            {
                                if (![self.picOkArr containsObject:key]) {
                                    [self.picOkArr addObject:key];
                                }                                
                                [self.delegate displayPic:key];
                            }
                        } else {
                            info.messages = [[NSMutableString alloc] init];
                            [info.messages appendString:msg];
                            
                            info.pic2 = [[NSImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:msgArr[3] options:0]];
                            info.isOk = YES;
                            @synchronized(self.pricePicOkArr)
                            {
                                if (![self.pricePicOkArr containsObject:key]) {
                                    [self.pricePicOkArr addObject:key];
                                }
                                [self.delegate displayPricePic:key];
                            }
                        }
                    }
                    
                    
                    
//                    [info.messages appendString:msg];
//                    if ([msg hasSuffix:@"\r\n"]) {
//                        info.isOk = YES;
//                        NSArray *msgArr = [msg componentsSeparatedByString:@":"];
//                        info.pic1 = msgArr[3];
//                        info.pic2 = msgArr[4];
//                        [self.delegate socketcomeInOut:1];
//                    }
                }
            }
            
        }
    });
    
    // Echo message back to client
    NSString *echoMsg = @"\0";
    NSData *echoData = [echoMsg dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:echoData withTimeout:-1 tag:ECHO_MSG];
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
//    if (elapsed <= READ_TIMEOUT)
//    {
//        NSString *warningMsg = @"Are you still there?\r\n";
//        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
//        
//        return READ_TIMEOUT_EXTENSION;
//    }
    
    return -1;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != self.listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                
                NSLog(@"客户端断开连接......");
                
            }
        });
//        int index = [self.connectedSockets indexOfObject:sock];
        @synchronized(self.connectedSockets)
        {
            [self.delegate socketcomeInOut:-1 withSocket:sock];
            [self.connectedSockets removeObject:sock];
        }
        
        NSString *key = [NSString stringWithFormat: @"%lu", (unsigned long)sock.hash];
        @synchronized(self.socketsDics)
        {
            if ([[self.socketsDics allKeys] containsObject:key]) {
                [self.socketsDics removeObjectForKey:key];
//                [self.delegate socketcomeInOut:-1];
            }
        }
        
//        @synchronized(self.picOkArr)
//        {
//            [self.picOkArr removeObject:key];
//        }
    }
}

@end
