//
//  ViewController.m
//  JxbImClient
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "ViewController.h"
#import <JxbQmttKit/JxbQmttKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[JxbQmttClient sharedInstance] connect:@"192.168.0.170" clentId:@"123456" successBlock:^{
        [[JxbQmttClient sharedInstance] subscribe:@[@"111"]];
    } failureBlock:^(JxbConnectionCode statusCode) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
