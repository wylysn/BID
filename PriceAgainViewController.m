//
//  PriceAgainViewController.m
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import "PriceAgainViewController.h"

@interface PriceAgainViewController ()

@end

@implementation PriceAgainViewController {
    NSMutableArray *imageArr;
    NSMutableDictionary *socketsDics;
    NSMutableArray *pricePicOkArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageArr = [[NSMutableArray alloc] init];
    
//    NSImage *image1 = [NSImage imageNamed:@"8.png"];
//    NSImage *image2 = [NSImage imageNamed:@"9.png"];
//    NSImage *image3 = [NSImage imageNamed:@"6.png"];
//    [imageArr addObject:image1];
//    [imageArr addObject:image2];
//    [imageArr addObject:image3];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectNotice:) name:@"connectNotice" object:nil];
}

- (void)connectNotice:(NSNotification *)notice{
    NSLog(@"－－－－－接收到通知------");
    imageArr = notice.userInfo[@"imageArr"];
    socketsDics = notice.userInfo[@"socketsDics"];
    pricePicOkArr = notice.userInfo[@"pricePicOkArr"];
    [self.collectionView reloadData];
}

#pragma mark NSCollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageArr.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSCollectionViewItem *item = [self.collectionView makeItemWithIdentifier:@"Slide2CollectionViewItem" forIndexPath:indexPath];
    return item;
}

#pragma mark NSCollectionViewDelegateFlowLayout Methods

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NSMakeSize(240, 211);
}

// Implementing this delegate method tells a NSCollectionViewFlowLayout (such as our AAPLWrappedLayout) what size to make a "Header" supplementary view.  (The actual size will be clipped to the CollectionView's width.)
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return NSZeroSize;
}

// Implementing this delegate method tells a NSCollectionViewFlowLayout (such as our AAPLWrappedLayout) what size to make a "Footer" supplementary view.  (The actual size will be clipped to the CollectionView's width.)
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return NSZeroSize; // If groupByTag is NO, we don't want to show a footer.
}

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(NSCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.item;
    
    Slide2CollectionViewItem *slideItem = (Slide2CollectionViewItem *)item;
    slideItem.imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
    slideItem.delegate = self;
    [slideItem.imgView setImage:imageArr[row]];
    
    if (pricePicOkArr && pricePicOkArr.count>0) {
        NSDictionary *dic = socketsDics[pricePicOkArr[row]];
        ConnectInfo *connectinfo = dic[@"connectinfo"];
        [slideItem.ipLabel setStringValue:[NSString stringWithFormat:@"%@:%@", connectinfo.IP,connectinfo.port]];
        
        slideItem.key = pricePicOkArr[row];
    } else {
        [slideItem.ipLabel setStringValue:@""];
    }
}

#pragma mark Slide2CollectionViewItemDelegate Methods
- (void)refreshPrice:(NSString *)key {
    NSDictionary *dic = socketsDics[key];
    GCDAsyncSocket *socketinfo = dic?dic[@"socketinfo"]:nil;
    if (socketinfo && socketinfo.isConnected) {
        NSString *echoMsg = @"YZMPRICE";
        NSData *echoData = [echoMsg dataUsingEncoding:NSUTF8StringEncoding];
        [socketinfo writeData:echoData withTimeout:-1 tag:1];
    }
}

- (void)priceAgain:(NSString *)key {
    NSDictionary *dic = socketsDics[key];
    GCDAsyncSocket *socketinfo = dic?dic[@"socketinfo"]:nil;
    if (socketinfo && socketinfo.isConnected) {
        NSString *echoMsg = @"YZMFIRSTBID";
        NSData *echoData = [echoMsg dataUsingEncoding:NSUTF8StringEncoding];
        [socketinfo writeData:echoData withTimeout:-1 tag:1];
    }
}

@end
