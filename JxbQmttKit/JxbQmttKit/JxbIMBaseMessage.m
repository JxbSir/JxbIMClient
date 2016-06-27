//
//  JxbIMBaseMessage.m
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbIMBaseMessage.h"
#import "JxbIMUser.h"

@implementation JxbIMBaseMessage

+ (Class)toUser_class {
    return [JxbIMUser class];
}

+ (Class)fromUser_class {
    return [JxbIMUser class];
}
@end
