//
//  JxbRealmMessage.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/28.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface JxbRealmMessage : RLMObject

@property (nonatomic, assign) NSInteger         type;
@property (nonatomic, strong) NSString          *sendUser;
@property (nonatomic, strong) NSString          *topicId;
@property (nonatomic, assign) NSTimeInterval    sentTime;
@property (nonatomic, strong) NSString          *content;
@property (nonatomic, strong) NSString          *extra;

@end
