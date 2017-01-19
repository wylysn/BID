//
//  ConnectInfo.h
//  hp
//
//  Created by wangyilu on 16/6/12.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectInfo : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *t1;
@property (nonatomic, strong) NSString *t2;
@property (nonatomic, strong) NSMutableString *messages;
@property (nonatomic, strong) NSImage *pic1;//有问题就用UIImage
@property (nonatomic, strong) NSImage *pic2;//有问题就用UIImage
@property (nonatomic, assign) BOOL isOk;
@property (nonatomic, strong) NSString *IP;
@property (nonatomic, strong) NSString *port;

@end
