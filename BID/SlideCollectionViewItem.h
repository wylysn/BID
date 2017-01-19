//
//  SlideCollectionViewItem.h
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SlideCollectionViewItemDelegate <NSObject>

- (void)sendMsg:(NSString *)code withKey:(NSString *)key;

@end

@interface SlideCollectionViewItem : NSCollectionViewItem<NSTextFieldDelegate>

@property (nonatomic, weak) id<SlideCollectionViewItemDelegate> delegate;

@property (weak) IBOutlet NSTextField *ipLabel;
@property (weak) IBOutlet NSTextField *codeField;
@property (weak) IBOutlet NSImageView *imgView;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *numberLimitState;

@end
