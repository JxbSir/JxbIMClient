//
//  JxbIMTextMessage.m
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbIMTextMessage.h"

@implementation JxbIMTextMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        _msgType = JxbIM_Text;
    }
    return self;
}

@end
