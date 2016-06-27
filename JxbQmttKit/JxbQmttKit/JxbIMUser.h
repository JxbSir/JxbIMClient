//
//  JxbIMUser.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JxbIMParser.h"

@interface JxbIMUser : JxbIMParser
@property (nonatomic, strong) NSString  *userId;
@property (nonatomic, strong) NSString  *userNick;
@property (nonatomic, strong) NSString  *iconUrl;

+ (instancetype)getUser:(NSString*)uid nick:(NSString*)nick iconUrl:(NSString*)iconUrl;
@end
