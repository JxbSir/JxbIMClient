//
//  ViewController.m
//  JxbImClient
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "ViewController.h"
#import <JxbQmttKit/JxbQmttKit.h>
#import <AdSupport/AdSupport.h>



@interface ViewController ()<JxbQmttDelegate>

@property (nonatomic, assign) BOOL      isSubscribe;
@property (nonatomic, strong) NSString  *clientId;
@property (weak, nonatomic) IBOutlet UIButton *btnSubscribe;
@property (weak, nonatomic) IBOutlet UITextField *txtTopic;
@property (weak, nonatomic) IBOutlet UITextView *txtSend;
@property (weak, nonatomic) IBOutlet UITextView *txtRec;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[JxbQmttClient sharedInstance] setDelegate:self];
    
    self.clientId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [[JxbQmttClient sharedInstance] connect:@"192.168.0.170" clentId:self.clientId successBlock:^{
        self.txtRec.text = [NSString stringWithFormat:@"连接成功...\n%@",self.txtRec.text];
    } failureBlock:^(JxbConnectionCode statusCode) {
        self.txtRec.text = [NSString stringWithFormat:@"连接失败...\n%@",self.txtRec.text];
    }];
    
}

- (IBAction)btnSubscribe:(id)sender {
    if (_txtTopic.text.length > 0) {
        if (_isSubscribe) {
            _isSubscribe = false;
            [[JxbQmttClient sharedInstance] unsubscribe:@[self.txtTopic.text]];
            [_btnSubscribe setTitle:@"subscribe" forState:UIControlStateNormal];
        }
        else {
            _isSubscribe = true;
            [[JxbQmttClient sharedInstance] subscribe:@[self.txtTopic.text]];
            [_btnSubscribe setTitle:@"unsubscribe" forState:UIControlStateNormal];;
        }
    }
}

- (IBAction)btnSend:(id)sender {
    if (!_isSubscribe)
        return;
    JxbIMTextMessage* message = [[JxbIMTextMessage alloc] init];
    message.text = _txtSend.text;
    message.topicId = _txtTopic.text;
    message.fromUser = [JxbIMUser getUser:self.clientId nick:self.clientId iconUrl:nil];
    [[JxbQmttClient sharedInstance] sendTextMessage:message];
}

- (void)receiveMessage:(JxbIMBaseMessage *)message {
    JxbIMTextMessage* msg = (JxbIMTextMessage*)message;
    if ([message.fromUser.userId isEqualToString:self.clientId]) {
        self.txtRec.text = [NSString stringWithFormat:@"发送消息:%@\n%@",msg.text,self.txtRec.text];
    }
    else {
        self.txtRec.text = [NSString stringWithFormat:@"收到消息:%@\n%@",msg.text,self.txtRec.text];
    }
}
@end
