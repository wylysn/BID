//
//  Slide2CollectionViewItem.h
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol Slide2CollectionViewItemDelegate <NSObject>

- (void)refreshPrice:(NSString *)key;

- (void)priceAgain:(NSString *)key;

@end

@interface Slide2CollectionViewItem : NSCollectionViewItem

@property (nonatomic, weak) id<Slide2CollectionViewItemDelegate> delegate;

@property (weak) IBOutlet NSTextField *ipLabel;
@property (weak) IBOutlet NSImageView *imgView;
@property (weak) IBOutlet NSButton *refreshBtn;
@property (weak) IBOutlet NSButton *priceAgainBtn;

@property (strong, nonatomic) NSString *key;

@end
