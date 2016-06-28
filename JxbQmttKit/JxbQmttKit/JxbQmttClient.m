//
//  JxbQmttClient.m
//  JxbQmttKit
//
//  Created by Peter on 16/6/25.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbQmttClient.h"
#import "JxbQmttCode.h"
#import "MQTTKit.h"
#import "JxbIMParser.h"
#import "JxbIMBaseMessage.h"
#import "JxbIMTextMessage.h"
#import "JxbIMImageMessage.h"
#import "JxbIMLocationMessage.h"
#import "JxbIMInputingMessage.h"
#import "JxbIMNotifyMessage.h"
#import "JxbIMSystemMessage.h"
#import "JxbIMCustomMessage.h"
#import "NSDictionary+Json.h"
#import "JxbRealmMessage.h"
#import "JxbIMUser.h"



@interface JxbQmttClient()

@property (nonatomic, strong) NSURL         *realmUrl;
/**
 *  MQTT
 */
@property (nonatomic, strong) MQTTClient    *client;
/**
 *  客户端唯一标识
 */
@property (nonatomic, strong) NSString      *clientId;

@end

@implementation JxbQmttClient

#pragma mark - 初始化
+ (instancetype)sharedInstance {
    static dispatch_once_t  once;
    static JxbQmttClient    *client;
    dispatch_once(&once, ^{
        client = [[JxbQmttClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
        NSString* dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/JxbIMLog"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSURL* url = [NSURL URLWithString:[dir stringByAppendingPathComponent:@"chat.realm"]];
        self.realmUrl = url;
        configuration.fileURL = url;
        [RLMRealmConfiguration setDefaultConfiguration:configuration];
    }
    return self;
}

- (MQTTClient*)client {
    if (!_client) {
        _client = [[MQTTClient alloc] initWithClientId:self.clientId];
    }
    return _client;
}

#pragma mark - 连接
- (void)connect:(NSString *)host clentId:(NSString*)clentId successBlock:(void(^)(void))successBlock failureBlock:(void(^)(JxbConnectionCode statusCode))failureBlock {
    __weak typeof (self) wSelf = self;
    self.clientId = clentId;
    [self.client connectToHost:host completionHandler:^(NSUInteger code) {
        if (code == ConnectionAccepted) {
            NSLog(@"JxbQmtt login success[%@]",wSelf.clientId);
            if (successBlock != NULL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            }
        }
        else {
            NSLog(@"JxbQmtt login failed[%@](%ld)",wSelf.clientId,(unsigned long)code);
            if (failureBlock != NULL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock((JxbConnectionCode)code);
                });
            }
        }
    }];
    
    [self.client setMessageHandler:^(MQTTMessage* message) {
        [wSelf receiveMessage:message];
    }];
}

#pragma mark - 断开
- (void)disconnect {
    __weak typeof (self) wSelf = self;
    [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
        // The client is disconnected when this completion handler is called
        NSLog(@"MQTT client is disconnected[%@]",wSelf.clientId);
    }];
}

#pragma mark - 订阅
- (void)subscribe:(NSArray *)topics {
    for (NSString* topic in topics) {
        [self.client subscribe:topic withQos:ExactlyOnce completionHandler:nil];
    }
}

- (void)unsubscribe:(NSArray *)topics {
    for (NSString* topic in topics) {
        [self.client unsubscribe:topic withCompletionHandler:nil];
    }
}

#pragma mark - 发送消息
- (void)sendMessage:(NSString*)topic conetnt:(NSString*)content completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    __weak typeof (self) wSelf = self;
    [self.client publishString:content toTopic:topic withQos:ExactlyOnce retain:NO completionHandler:^(int mid) {
        NSLog(@"message has been delivered[%@]",wSelf.clientId);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlcok != NULL) {
                completeBlcok(mid > 0);
            }
        });
        [wSelf addMessage2DB:topic content:content];
    }];
}

- (void)sendMessage:(JxbIMBaseMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    message.sentTime = @([[NSDate date] timeIntervalSince1970]);
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt completeBlcok:completeBlcok];
}

- (void)sendTextMessage:(JxbIMTextMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendImageMessage:(JxbIMImageMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendLocationMessage:(JxbIMLocationMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendNotifyMessage:(JxbIMNotifyMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendInputingMessage:(JxbIMInputingMessage *)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendSystemMessage:(JxbIMSystemMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

- (void)sendCustomMessage:(JxbIMCustomMessage*)message completeBlcok:(void(^)(bool bSuccess))completeBlcok {
    [self sendMessage:message completeBlcok:completeBlcok];
}

#pragma mark - 解析数据
- (JxbIMBaseMessage*)parse2ImMessage:(JxbRealmMessage*)realmMsg {
    JxbIMBaseMessage* baseMessage = nil;
    switch (realmMsg.type) {
        case JxbIM_Unknown: {
            break;
        }
        case JxbIM_Text: {
            JxbIMTextMessage* msg = [[JxbIMTextMessage alloc] init];
            msg.text = realmMsg.content;
            baseMessage = msg;
            break;
        }
        case JxbIM_Image: {
            JxbIMImageMessage* msg = [[JxbIMImageMessage alloc] init];
            msg.imageData = [realmMsg.content dataUsingEncoding:NSUTF8StringEncoding];
            baseMessage = msg;
            break;
        }
        case JxbIM_Location: {
            NSError *error = nil;
            NSDictionary* dicLocation = [NSDictionary dictionaryWithJSONString:realmMsg.content error:&error];
            if (error) {
                break;
            }
            JxbIMLocationMessage* msg = [[JxbIMLocationMessage alloc] init];
            msg.longitude = [dicLocation[@"longitude"] doubleValue];
            msg.latitude = [dicLocation[@"latitude"] doubleValue];
            baseMessage = msg;
            break;
        }
        case JxbIM_Notify: {
            JxbIMTextMessage* msg = [[JxbIMTextMessage alloc] init];
            msg.text = realmMsg.content;
            baseMessage = msg;
            break;
        }
        case JxbIM_Voice: {
            break;
        }
        case JxbIM_Video: {
            break;
        }
        case JxbIM_Shake: {
            break;
        }
        case JxbIM_Inputing: {
            break;
        }
        case JxbIM_Money: {
            break;
        }
        default: {
            break;
        }
    }
   
    if (baseMessage) {
        baseMessage.topicId = realmMsg.topicId;
        baseMessage.sentTime = @(realmMsg.sentTime);
        baseMessage.extra = realmMsg.extra;
        
        NSError *error = nil;
        NSDictionary* dicUser = [NSDictionary dictionaryWithJSONString:realmMsg.sendUser error:&error];
        if (!error) {
            baseMessage.sendUser = [[JxbIMUser alloc] initWithDictionary:dicUser];
        }
    }
    return baseMessage;
}

- (JxbIMBaseMessage*)parseMessage:(NSString*)content {
    NSError *error = nil;
    NSDictionary* dicMessage = [NSDictionary dictionaryWithJSONString:content error:&error];
    if (error) {
        NSLog(@"receiveMessage error:%@",error);
        return nil;
    }
    JxbIMBaseMessage* baseMessage = [[JxbIMBaseMessage alloc] initWithDictionary:dicMessage];
    switch (baseMessage.msgType) {
        case JxbIM_Unknown: {
            break;
        }
        case JxbIM_Text: {
            baseMessage = [[JxbIMTextMessage alloc] initWithDictionary:dicMessage];
            break;
        }
        case JxbIM_Image: {
            baseMessage = [[JxbIMImageMessage alloc] initWithDictionary:dicMessage];
            break;
        }
        case JxbIM_Location: {
            baseMessage = [[JxbIMLocationMessage alloc] initWithDictionary:dicMessage];
            break;
        }
        case JxbIM_Notify: {
            baseMessage = [[JxbIMNotifyMessage alloc] initWithDictionary:dicMessage];
            break;
        }
        case JxbIM_Voice: {
            break;
        }
        case JxbIM_Video: {
            break;
        }
        case JxbIM_Shake: {
            break;
        }
        case JxbIM_Inputing: {
            baseMessage = [[JxbIMInputingMessage alloc] initWithDictionary:dicMessage];
            break;
        }
        case JxbIM_Money: {
            break;
        }
        default: {
            break;
        }
    }
    return baseMessage;
}

#pragma mark - 接收消息
- (void)receiveMessage:(MQTTMessage*)message {
    __weak typeof (self) wSelf = self;
    NSString* msg = [[NSString alloc] initWithData:message.payload encoding:NSUTF8StringEncoding];
    if (msg && msg.length > 0) {
        JxbIMBaseMessage* baseMessage = [self parseMessage:msg];
        if (!baseMessage)
            return;
        if (self.delegate && [self.delegate respondsToSelector:@selector(receiveMessage:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wSelf.delegate receiveMessage:baseMessage];
            });
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:JxbIMNewMessageNotification object:baseMessage];
    }
}

#pragma mark - Realm数据库操作
- (void)loadAllMsg:(NSString*)topic completeBlock:(void(^)(NSArray *messages))completeBlock {
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray  *allMessages = [NSMutableArray array];
        RLMResults *results = nil;
        if (topic.length > 0) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"topicId = %@", topic];
            results = [JxbRealmMessage objectsWithPredicate:pred];
        }
        else {
            results = [JxbRealmMessage allObjects];
        }
        for (JxbRealmMessage* result in results) {
            JxbIMBaseMessage* msg = [wSelf parse2ImMessage:result];
            [allMessages addObject:msg];
        }
        if (completeBlock != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(allMessages);
            });
        }
    });
}

- (void)addMessage2DB:(NSString*)topicId content:(NSString*)content {
    JxbIMBaseMessage* baseMessage = [self parseMessage:content];
    [self addMessage2DB:baseMessage];
}

- (void)addMessage2DB:(JxbIMBaseMessage*)baseMessage {
    if (!baseMessage)
        return;
    JxbRealmMessage* realMsg = [[JxbRealmMessage alloc] init];
    realMsg.topicId = baseMessage.topicId;
    realMsg.type = baseMessage.msgType;
    realMsg.extra = baseMessage.extra;
    realMsg.sendUser = [[baseMessage.sendUser toDictionary] toString];
    realMsg.sentTime = baseMessage.sentTime.doubleValue;
    if (baseMessage.msgType == JxbIM_Text) {
        realMsg.content = ((JxbIMTextMessage*)baseMessage).text;
    }
    else if (baseMessage.msgType == JxbIM_Image) {
        NSData *data = ((JxbIMImageMessage*)baseMessage).imageData;
        realMsg.content = [data base64EncodedStringWithOptions:0];
    }
    else if (baseMessage.msgType == JxbIM_Location) {
        double latitude = ((JxbIMLocationMessage*)baseMessage).latitude;
        double longitude = ((JxbIMLocationMessage*)baseMessage).longitude;
        realMsg.content = [NSString stringWithFormat:@"{\"latitude\":\"%f\",\"longitude\":\"%f\"}",latitude,longitude];
    }
    else if (baseMessage.msgType == JxbIM_Notify) {
        realMsg.content = ((JxbIMNotifyMessage*)baseMessage).text;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:realMsg];
    }];
    
    NSLog(@"%@",NSHomeDirectory());
}
@end
