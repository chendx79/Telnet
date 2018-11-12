//
//  GameLogic.m
//  陈鼎星
//
//  Created by 陈鼎星 on 8/11/2018.
//  Copyright © 2018 陈鼎星. All rights reserved.
//

#import "GameLogic.h"

@interface GameLogic()
{
    NSString *userName;
    NSString *password;
    bool justSendUserName;
    bool justSendPassword;
    bool userLogined;
    bool askingUserName;
    bool askingPassword;
    bool justSend;
    bool justMove;
    bool justLook;
    NSAttributedString* locationName;
    NSAttributedString* map;
    NSAttributedString* locationDescription;
}

@end

ANSIEscapeHelper *ansiEscapeHelper;
TelnetClient *client;

@implementation GameLogic

static GameLogic* _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        //处理AnsiEscapeString
        ansiEscapeHelper = [[ANSIEscapeHelper alloc] init];
        // set colors & font to use to ansiEscapeHelper
        NSDictionary *colorPrefDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:SGRCodeFgBlack], kANSIColorPrefKey_FgBlack,
                                           [NSNumber numberWithInt:SGRCodeFgWhite], kANSIColorPrefKey_FgWhite,
                                           [NSNumber numberWithInt:SGRCodeFgRed], kANSIColorPrefKey_FgRed,
                                           [NSNumber numberWithInt:SGRCodeFgGreen], kANSIColorPrefKey_FgGreen,
                                           [NSNumber numberWithInt:SGRCodeFgYellow], kANSIColorPrefKey_FgYellow,
                                           [NSNumber numberWithInt:SGRCodeFgBlue], kANSIColorPrefKey_FgBlue,
                                           [NSNumber numberWithInt:SGRCodeFgMagenta], kANSIColorPrefKey_FgMagenta,
                                           [NSNumber numberWithInt:SGRCodeFgCyan], kANSIColorPrefKey_FgCyan,
                                           [NSNumber numberWithInt:SGRCodeBgBlack], kANSIColorPrefKey_BgBlack,
                                           [NSNumber numberWithInt:SGRCodeBgWhite], kANSIColorPrefKey_BgWhite,
                                           [NSNumber numberWithInt:SGRCodeBgRed], kANSIColorPrefKey_BgRed,
                                           [NSNumber numberWithInt:SGRCodeBgGreen], kANSIColorPrefKey_BgGreen,
                                           [NSNumber numberWithInt:SGRCodeBgYellow], kANSIColorPrefKey_BgYellow,
                                           [NSNumber numberWithInt:SGRCodeBgBlue], kANSIColorPrefKey_BgBlue,
                                           [NSNumber numberWithInt:SGRCodeBgMagenta], kANSIColorPrefKey_BgMagenta,
                                           [NSNumber numberWithInt:SGRCodeBgCyan], kANSIColorPrefKey_BgCyan,
                                           nil];
        NSUInteger iColorPrefDefaultsKey;
        NSData *colorData;
        NSString *thisPrefName;
        for (iColorPrefDefaultsKey = 0; iColorPrefDefaultsKey < [[colorPrefDefaults allKeys] count]; iColorPrefDefaultsKey++)
        {
            thisPrefName = [[colorPrefDefaults allKeys] objectAtIndex:iColorPrefDefaultsKey];
            colorData = [[NSUserDefaults standardUserDefaults] dataForKey:thisPrefName];
            if (colorData != nil)
            {
                UIColor *thisColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
                [[ansiEscapeHelper ansiColors] setObject:thisColor forKey:[colorPrefDefaults objectForKey:thisPrefName]];
            }
        }

        client = [[TelnetClient alloc] init];
        client.delegate = _instance;
    }) ;

    return _instance ;
}

- (void)ConnectMudServer{
    [client setup:@"47.90.49.49" Port:8080];
}

//^[\u4e00-\u9fa5]* - $

- (NSString *)getLocationName:(NSString *) msg{
    NSString *result;
    NSArray *lines = [msg componentsSeparatedByString:@"\r\n"];
    for (int line = 0; line < [lines count]; line = line + 1) {
        NSString *lineString = [lines objectAtIndex:line];
        NSRange range = [lineString rangeOfString:@"^[\u4e00-\u9fa5]* - $" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            NSRange nameRange = [lineString rangeOfString:@"^[\u4e00-\u9fa5]*" options:NSRegularExpressionSearch];
            result = [lineString substringWithRange:nameRange];
            NSLog(@"%@", result);
            break;
        }
    }
    return result;
}

- (bool)checkUserExist:(NSString *) msg{
    NSRange range = [msg rangeOfString:@"^此ID档案已存在，请输入密码：$" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return true;
    }
    return false;
}

- (bool)checkUserLogined:(NSString *) msg{
    NSRange range = [msg rangeOfString:@"^目前权限" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return true;
    }
    else{
        range = [msg rangeOfString:@"重新连线完毕。" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return true;
        }
    }
    return false;
}

- (void)logSentMessage:(NSString *)msg{
    if ([msg isEqualToString:@"l"]) {
        justLook = true;
    }
    if ([[NSArray arrayWithObjects: @"e", @"s", @"w", @"n", @"ne", @"nw", @"se", @"sw", nil] containsObject:msg]) {
        justMove = true;
    }
}

- (void)loginWithUserNamePassword:(NSString *)inputUserName Password:(NSString *)inputPassword
{
    userName = inputUserName;
    password = inputPassword;
    [client writeMessage:[userName stringByAppendingString:@"\n"]];
    justSendUserName = true;
}

- (void)login
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userName = [userDefaults objectForKey:@"userName"];
    password = [userDefaults objectForKey:@"password"];
    [client writeMessage:[userName stringByAppendingString:@"\n"]];
    justSendUserName = true;
}

- (void)sendMessage:(NSString *)msg
{
    [client writeMessage:[msg stringByAppendingString:@"\n"]];
}

- (NSAttributedString *)filterMessage:(NSString *)msg{
    NSString * cleanMsg;
    NSAttributedString *attrStr = [ansiEscapeHelper attributedStringWithANSIEscapedString:msg cleanString:&cleanMsg];
    //NSLog(@"Got %lu string [%@]", [cleanMsg length], cleanMsg);
    if (justLook) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        NSLog(@"地点名字:[\n%@\n]", [self getLocationName:cleanMsg]);
        justLook = false;
        return attrStr;
    }
    if (justMove) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        justMove = false;
        return attrStr;
    }
    if (justSendUserName) {
        justSendUserName = false;
        if ([self checkUserExist:cleanMsg]) {
            [client writeMessage:[password stringByAppendingString:@"\n"]];
            justSendPassword = true;
        }
        return attrStr;
    }
    if (justSendPassword) {
        justSendPassword = false;
        if ([self checkUserLogined:cleanMsg]) {
            userLogined = true;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:password forKey:@"password"];
            [userDefaults setObject:userName forKey:@"userName"];
            NSLog(@"%@", @"登录成功");

            //打开游戏窗口
            id gameLogicDelegate = self.delegate;
            SEL sel = @selector(loginSuccessfully);
            void (*myObjCSelectorPointer)(id, SEL)  = (void (*)(id,SEL))[gameLogicDelegate methodForSelector:sel];
            myObjCSelectorPointer(gameLogicDelegate, sel);
        }
        else{
            NSLog(@"%@", @"登录失败");
        }
        return attrStr;
    }
    return attrStr;
}

#pragma mark - TelnetDelegate

- (void)didReceiveMessage:(NSString *)msg
{
    NSAttributedString *attrStr = [self filterMessage:msg];
    id gameLogicDelegate = self.delegate;
    SEL sel = @selector(showMessage:);
    void (*myObjCSelectorPointer)(id, SEL, NSAttributedString*)  = (void (*)(id,SEL,NSAttributedString*))[gameLogicDelegate methodForSelector:sel];
    myObjCSelectorPointer(gameLogicDelegate, sel, attrStr);
}

- (void)shouldEcho:(BOOL)echo
{
    //NSLog(@"%s %d", __func__, echo);
}

@end
