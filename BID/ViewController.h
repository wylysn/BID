//
//  ViewController.h
//  BID
//
//  Created by wangyilu on 2017/1/12.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import CocoaAsyncSocket;
#import "ListenSocketServer.h"
#import "ConnectInfo.h"
#import "SlideCollectionViewItem.h"
#import "Slide2CollectionViewItem.h"
#import "CRVStompClient.h"

@interface ViewController : NSViewController< NSCollectionViewDataSource, NSCollectionViewDelegate,NSCollectionViewDelegateFlowLayout, ListenSocketDelegate, NSTextFieldDelegate, SlideCollectionViewItemDelegate, CRVStompClientDelegate>

@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSTextField *ipLabel;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (weak) IBOutlet NSTextField *connectNumLabel;
@property (weak) IBOutlet NSView *containerView;
@property (weak) IBOutlet NSButton *numberLimitBtn;

@property (strong, nonatomic) ListenSocketServer *listenSocketServer;

@end

