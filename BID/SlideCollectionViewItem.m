//
//  SlideCollectionViewItem.m
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import "SlideCollectionViewItem.h"

@interface SlideCollectionViewItem ()

@end

@implementation SlideCollectionViewItem 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.codeField.delegate = self;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberLimitNotice:) name:@"numberLimitNotice" object:nil];
}

- (void)numberLimitNotice:(NSNotification *)notice{
    NSLog(@"－－－－－接收到通知------");
    self.numberLimitState = notice.userInfo[@"numberLimit"];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSLog(@"输入对象：%@",obj);
    NSTextField *textfield = [obj object];
    
    //限定长度
    if ([textfield.stringValue length] > 4) {
        [textfield setStringValue:[textfield.stringValue substringWithRange:NSMakeRange(0, 4)]];
    }
    
    //限定数字
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSLog(@"%@",textfield.stringValue);
    char *stringResult = malloc([textfield.stringValue length]);
    int cpt=0;
    for (int i = 0; i < [textfield.stringValue length]; i++) {
        unichar c = [textfield.stringValue characterAtIndex:i];
        if ([charSet characterIsMember:c]) {
            stringResult[cpt]=c;
            cpt++;
        }
    }
    stringResult[cpt]='\0';
    textfield.stringValue = [NSString stringWithUTF8String:stringResult];
    free(stringResult);
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement ) {
        NSLog(@"按下了回车键!");
        NSString *code = self.codeField.stringValue;
        if ([@"1" isEqualToString:self.numberLimitState]) {
            if (!(code.length==4 || [@"" isEqualToString:code])) {
                return;
            }
        }
        [self.delegate sendMsg:code withKey:self.key];
        [self.codeField setStringValue:@""];
    }
}

@end
