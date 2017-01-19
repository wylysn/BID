//
//  ConnectInfo.m
//  hp
//
//  Created by wangyilu on 16/6/12.
//  Copyright © 2016年 ___PURANG___. All rights reserved.
//

#import "ConnectInfo.h"

@implementation ConnectInfo

- (id)init {
    if((self = [super init]))
    {
        self.messages = [[NSMutableString alloc] init];
        self.isOk = NO;
    }
    return self;
}

@end
