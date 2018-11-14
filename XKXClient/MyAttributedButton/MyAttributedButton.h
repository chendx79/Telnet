//
//  MyAttributedButton.h
//  XKXClient
//
//  Created by 陈鼎星 on 2018/11/14.
//  Copyright © 2018 Bryan Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAttributedButton : UIButton

@property (nonatomic, strong) NSAttributedString *myAttributedString;

- (instancetype)initWithFrame:(CGRect)frame MyAttributedString:(NSAttributedString *) myAttributedString;

@end

