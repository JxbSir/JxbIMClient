//
//  JxbIMUser.m
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbIMUser.h"

@implementation JxbIMUser

+ (instancetype)getUser:(NSString*)uid nick:(NSString*)nick iconUrl:(NSString*)iconUrl {
    JxbIMUser* user = [[JxbIMUser alloc] init];
    user.userId = uid;
    user.userNick = nick;
    user.iconUrl = iconUrl;
    return user;
}

@end
