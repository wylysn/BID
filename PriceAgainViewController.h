//
//  PriceAgainViewController.h
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Slide2CollectionViewItem.h"
#import "ConnectInfo.h"
@import CocoaAsyncSocket;

@interface PriceAgainViewController : NSViewController<NSCollectionViewDataSource, NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout, Slide2CollectionViewItemDelegate>

@property (weak) IBOutlet NSCollectionView *collectionView;

@end
