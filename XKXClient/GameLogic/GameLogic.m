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
    if ([[NSArray arrayWithObjects: @"e", @"s", @"w", @"n", @"ne", @"nw", @"se", @"sw", @"east", @"south", @"west", @"north", @"northeast", @"northwest", @"southeast", @"southwest", nil] containsObject:msg]) {
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
    [self logSentMessage:msg];
    [client writeMessage:[msg stringByAppendingString:@"\n"]];
}

- (NSAttributedString *)filterMessage:(NSString *)msg{
    NSString * cleanMsg;
    NSAttributedString *attrStr = [ansiEscapeHelper attributedStringWithANSIEscapedString:msg cleanString:&cleanMsg];
    //NSLog(@"Got %lu string [%@]", [cleanMsg length], cleanMsg);
    if (justLook) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        [self analyzeMapInfo:cleanMsg AttrStr:attrStr];
        justLook = false;
        return nil;
    }
    if (justMove) {
        NSLog(@"Mapinfo [\n%@\n]", cleanMsg);
        [self analyzeMapInfo:cleanMsg AttrStr:attrStr];
        justMove = false;
        return nil;
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

- (void)analyzeMapInfo:(NSString*)cleanMsg AttrStr:(NSAttributedString *)attrStr{
    //获取地名
    NSArray *lines = [cleanMsg componentsSeparatedByString:@"\r\n"];
    NSString *location;
    NSString *lookString;
    NSString *directionString;
    NSString *map;
    NSString *locationDscrp;
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    bool locationFound = false;
    bool mapFound = false;
    bool locationDscrpFound = false;
    for (int line = 0; line < [lines count]; line = line + 1) {
        NSString *lineString = [lines objectAtIndex:line];
        if ([[lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            continue;
        }

        if (!locationFound) {
            NSRange range = [lineString rangeOfString:@"^[\u4e00-\u9fa5]* - $" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSRange nameRange = [lineString rangeOfString:@"^[\u4e00-\u9fa5]*" options:NSRegularExpressionSearch];
                location = [lineString substringWithRange:nameRange];
                locationFound = true;
                mapFound = true;
                continue;
            } else{
                if (!mapFound) {
                    if ((map == nil) || [map isEqualToString:@""]) {
                        map = [[[NSString alloc] init] stringByAppendingString:lineString];
                    } else {
                        map = [map stringByAppendingFormat:@"\r\n%@", lineString];
                    }
                    continue;
                }
            }
        }
        else{
            NSRange lookRange = [lineString rangeOfString:@"^    你可以看看" options:NSRegularExpressionSearch];
            if (lookRange.location != NSNotFound) {
                lookString = lineString;
                locationDscrpFound = true;
                continue;
            }
            NSRange directionRange = [lineString rangeOfString:@"^    这里[\u4e00-\u9fa5]*的方向有" options:NSRegularExpressionSearch];
            if (directionRange.location != NSNotFound) {
                directionString = lineString;
                locationDscrpFound = true;

                //处理方向字符串，增加按钮 [a-zA-Z]+
                NSMutableArray *directionArray = [[NSMutableArray alloc] init];
                NSRange directionRange = [directionString rangeOfString:@"[a-zA-Z]+" options:NSRegularExpressionSearch];
                while (directionRange.location != NSNotFound) {
                    [directionArray addObject:[directionString substringWithRange:directionRange]];
                    directionRange = [directionString rangeOfString:@"[a-zA-Z]+" options:NSRegularExpressionSearch range:NSMakeRange(directionRange.location + directionRange.length, [directionString length] - directionRange.location - directionRange.length)];
                }
                id gameLogicDelegate = self.delegate;
                SEL changeDirectionSelector = @selector(changeDirectionButtons:);
                void (*changeDirectionPointer)(id, SEL, NSArray*)  = (void (*)(id, SEL, NSArray*))[gameLogicDelegate methodForSelector:changeDirectionSelector];
                changeDirectionPointer(gameLogicDelegate, changeDirectionSelector, directionArray);

                continue;
            }
            if (!locationDscrpFound) {
                if ((locationDscrp == nil) || [locationDscrp isEqualToString:@""]) {
                    locationDscrp = [[[NSString alloc] init] stringByAppendingString:lineString];
                } else {
                    locationDscrp = [locationDscrp stringByAppendingFormat:@"\r\n%@", lineString];
                }
            } else {
                NSString *cleanStr = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSRange leftBracketRange = [cleanStr rangeOfString:@"("];
                NSRange rightBracketRange = [cleanStr rangeOfString:@")"];
                if (leftBracketRange.location != NSNotFound && rightBracketRange.location != NSNotFound) {
                    NSRange itemDscrpRange = [cleanMsg rangeOfString:[cleanStr substringWithRange:NSMakeRange(0, leftBracketRange.location)]];
                    NSAttributedString *itemDscrpAttributed = [attrStr attributedSubstringFromRange:itemDscrpRange];

                    [itemsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:itemDscrpAttributed, @"name", [cleanStr substringWithRange:NSMakeRange(leftBracketRange.location + 1, rightBracketRange.location - leftBracketRange.location - 1)], @"id" , nil] ];
                }
            }
        }
    }

    NSRange locationDscrpRange = [cleanMsg rangeOfString:locationDscrp];
    NSAttributedString *locationDscrpAttributed = [attrStr attributedSubstringFromRange:locationDscrpRange];

    //显示地点描述
    id gameLogicDelegate = self.delegate;
    SEL showLocationDescriptionSelector = @selector(showLocationDescription:);
    void (*showLocationDescriptionPointer)(id, SEL, NSAttributedString*)  = (void (*)(id, SEL, NSAttributedString*))[gameLogicDelegate methodForSelector:showLocationDescriptionSelector];
    showLocationDescriptionPointer(gameLogicDelegate, showLocationDescriptionSelector, locationDscrpAttributed);

    //增加物品按钮
    SEL changeItemSelector = @selector(changeItemsButtons:);
    void (*changeItemPointer)(id, SEL, NSArray*)  = (void (*)(id, SEL, NSArray*))[gameLogicDelegate methodForSelector:changeItemSelector];
    changeItemPointer(gameLogicDelegate, changeItemSelector, itemsArray);

    //显示地名
    NSString *locationButtonTitle = [[NSString alloc] initWithFormat:@"[%@]", location];
    SEL sel = @selector(showLocation:);
    void (*myObjCSelectorPointer)(id, SEL, NSString*)  = (void (*)(id, SEL, NSString*))[gameLogicDelegate methodForSelector:sel];
    myObjCSelectorPointer(gameLogicDelegate, sel, locationButtonTitle);

    //你来到了 。。。。
    location = [[NSString alloc] initWithFormat:@"\r\n>你来到了 %@\r\n", location];
    NSDictionary *locationDict = @{NSForegroundColorAttributeName:[UIColor greenColor]};
    NSAttributedString *locationAttributed = [[NSAttributedString alloc]initWithString:location attributes:locationDict];
    SEL locationSelector = @selector(showMessage:);
    void (*locationPointer)(id, SEL, NSAttributedString*)  = (void (*)(id,SEL,NSAttributedString*))[gameLogicDelegate methodForSelector:locationSelector];
    locationPointer(gameLogicDelegate, sel, locationAttributed);
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
