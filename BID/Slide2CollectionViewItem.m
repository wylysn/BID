//
//  Slide2CollectionViewItem.m
//  BID
//
//  Created by wangyilu on 2017/1/17.
//  Copyright © 2017年 ___PURANG___. All rights reserved.
//

#import "Slide2CollectionViewItem.h"

@interface Slide2CollectionViewItem ()

@end

@implementation Slide2CollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)refreshPrice:(id)sender {
    [self.delegate refreshPrice:self.key];
}

- (IBAction)priceAgain:(id)sender {
    [self.delegate priceAgain:self.key];
}

@end
