//
//  ViewController.m
//  BID
//
//  Created by wangyilu on 2017/1/12.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import "ViewController.h"
#import "StompKit.h"

@implementation ViewController {
    NSMutableArray *imageArr;
    NSMutableArray *priceImageArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *ipaddr = [ListenSocketServer getIPAddress:YES];
    [self.ipLabel setStringValue:[NSString stringWithFormat:@"%@:%d",ipaddr,[ListenSocketServer getPort]]];
    
    priceImageArr = [[NSMutableArray alloc] init];
    imageArr = [[NSMutableArray alloc] init];
    
//    NSImage *image1 = [NSImage imageNamed:@"8.png"];
//    [imageArr addObject:image1];
    
    //启动监听
    self.listenSocketServer = [[ListenSocketServer alloc] init];
    self.listenSocketServer.delegate = self;
    [self.listenSocketServer start];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //activemq客户端
    CRVStompClient *s = [[CRVStompClient alloc]
                         initWithHost:@"10.1.110.21"
                         port:61616
                         login:@""
                         passcode:@""
                         delegate:self];
    [s connect];
    
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: @"client", nil];
    [s subscribeToDestination:@"carautobid" withHeader: headers];
    
//    STOMPClient *client = [[STOMPClient alloc] initWithHost:@"10.1.110.21" port:61616];
//    // connect to the broker
//    [client connectWithLogin:@"" passcode:@"" completionHandler:^(STOMPFrame *_, NSError *error) {
//        if(error) {
//            NSLog(@"%@", error);
//            return;
//        }
//               
//        // subscribe to the destination
//        [client subscribeTo:@"carautobid" headers:nil messageHandler:^(STOMPMessage *message) {
//                        // callback when the client receive a message
//                        // for the /queue/myqueue destination
//                        NSLog(@"got message %@", message.body); // => "Hello, iOS"
//        }];
//    }];
    
    //窗口顶部时间显示
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

#pragma mark CRVStompClientDelegate
- (void)stompClientDidConnect:(CRVStompClient *)stompService {
    NSLog(@"stompServiceDidConnect");
}

- (void)stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader {
    NSLog(@"gotMessage body: %@, header: %@", body, messageHeader);
    NSLog(@"Message ID: %@", [messageHeader valueForKey:@"message-id"]);
    // If we have successfully received the message ackknowledge it.
    [stompService ack: [messageHeader valueForKey:@"message-id"]];
}

- (void)timerAction {
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    [self.timeLabel setStringValue:currentDateString];
}

- (IBAction)numberLimitClick:(id)sender {
    NSButton *checkBox = (NSButton *)sender;
    NSInteger state = checkBox.state;
    
    //创建通知
    NSDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSString stringWithFormat:@"%ld",state] forKey:@"numberLimit"];
    NSNotification *notification =[NSNotification notificationWithName:@"numberLimitNotice" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)socketcomeInOut:(int)flag withSocket:(GCDAsyncSocket *)socket {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.connectNumLabel setStringValue:[NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.connectedSockets.count]];
    });
    
    if (flag==-1) { //有连接断开
        [self.connectNumLabel setStringValue:[NSString stringWithFormat:@"%ld", (unsigned long)self.listenSocketServer.connectedSockets.count+flag]];//因为是在connectedSockets里的sock移除之前操作，所以需要减操作才准确
        
        NSMutableArray *pricePicOkArr = self.listenSocketServer.pricePicOkArr;
        NSString *rkey = [NSString stringWithFormat: @"%lu", (unsigned long)socket.hash];
        if ([pricePicOkArr containsObject:rkey]) {
            [pricePicOkArr removeObject:rkey];
        }
        
        [self reloadPriceImages:pricePicOkArr];
    }
}

- (void)displayPic:(NSString *)key {
    [self displayNewPics];
}

- (void)displayNewPics {
    NSMutableArray *picOkArr = self.listenSocketServer.picOkArr;
    [imageArr removeAllObjects];
    for (NSInteger i=0; i<picOkArr.count; i++) {
        NSDictionary *dic = self.listenSocketServer.socketsDics[picOkArr[i]];
        ConnectInfo *connectinfo = dic[@"connectinfo"];
        NSImage *image = connectinfo.pic1;
        [imageArr addObject:image];
    }
    
    [self.collectionView reloadData];
}

- (void)displayPricePic:(NSString *)key {
    NSMutableArray *pricePicOkArr = self.listenSocketServer.pricePicOkArr;
    
    [self reloadPriceImages:pricePicOkArr];
}

- (void)reloadPriceImages:(NSMutableArray *)pricePicOkArr {
    [priceImageArr removeAllObjects];
    for (NSInteger i=0; i<pricePicOkArr.count; i++) {
        NSDictionary *dic = self.listenSocketServer.socketsDics[pricePicOkArr[i]];
        ConnectInfo *connectinfo = dic[@"connectinfo"];
        NSImage *image = connectinfo.pic2;
        [priceImageArr addObject:image];
    }
    
    //创建通知
    NSDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.listenSocketServer.socketsDics forKey:@"socketsDics"];
    [dict setValue:priceImageArr forKey:@"imageArr"];
    [dict setValue:pricePicOkArr forKey:@"pricePicOkArr"];
    NSNotification *notification =[NSNotification notificationWithName:@"connectNotice" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)opennotice:(id)sender {
    [imageArr removeAllObjects];
    NSImage *image2 = [NSImage imageNamed:@"2.png"];
    NSImage *image3 = [NSImage imageNamed:@"3.png"];
    [imageArr addObject:image2];
    [imageArr addObject:image3];
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
    NSCollectionViewItem *item = [self.collectionView makeItemWithIdentifier:@"Slide" forIndexPath:indexPath];
    return item;
}

#pragma mark NSCollectionViewDelegateFlowLayout Methods

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NSMakeSize(410, 250);
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
    
    SlideCollectionViewItem *slideItem = (SlideCollectionViewItem *)item;
    slideItem.numberLimitState = [NSString stringWithFormat:@"%ld",self.numberLimitBtn.state];
    slideItem.imgView.imageScaling = NSImageScaleProportionallyUpOrDown;
    slideItem.delegate = self;
    [slideItem.imgView setImage:imageArr[row]];
    
    NSMutableArray *picOkArr = self.listenSocketServer.picOkArr;
    if (picOkArr && picOkArr.count>0) {
        NSDictionary *dic = self.listenSocketServer.socketsDics[picOkArr[row]];
        ConnectInfo *connectinfo = dic[@"connectinfo"];
        [slideItem.ipLabel setStringValue:[NSString stringWithFormat:@"%@:%@", connectinfo.IP,connectinfo.port]];
        slideItem.key = picOkArr[row];
    } else {
        [slideItem.ipLabel setStringValue:@""];
    }
    [slideItem.codeField setStringValue:@""];
    if (row==0) {
        [slideItem.codeField becomeFirstResponder];
    }
}

#pragma mark SlideCollectionViewItemDelegate method

- (void)sendMsg:(NSString *)code withKey:(NSString *)key {
    NSDictionary *dic = self.listenSocketServer.socketsDics[key];
    GCDAsyncSocket *socketinfo = dic?dic[@"socketinfo"]:nil;
    if (socketinfo && socketinfo.isConnected) {
        NSString *echoMsg = [NSString stringWithFormat:@"YZM%@\r\n", [@"" isEqualToString:code]?@"NULL":code];
        NSData *echoData = [echoMsg dataUsingEncoding:NSUTF8StringEncoding];
        [socketinfo writeData:echoData withTimeout:-1 tag:1];
    }
    
    if (self.listenSocketServer.picOkArr && [self.listenSocketServer.picOkArr containsObject:key]) {
        [self.listenSocketServer.picOkArr removeObject:key];
    }
    
    [self displayNewPics];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
