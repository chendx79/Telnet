//
//  TelnetClient.h
//  陈鼎星
//
//  Created by 陈鼎星 on 9/11/2018.
//  Copyright © 2018 陈鼎星. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TelnetDelegate <NSObject>

- (void)didReceiveMessage:(NSString *)msg;
- (void)shouldEcho:(BOOL)echo;

@end

@interface TelnetClient : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id<TelnetDelegate> delegate;

- (void)setup:(NSString *)hostName Port:(int)port;
- (void)writeMessage:(NSString *)msg;

@end
