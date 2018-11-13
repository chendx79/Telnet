//
//  GameViewController.h
//  陈鼎星
//
//  Created by 陈鼎星 on 2018/11/9.
//  Copyright © 2018 Chen DingXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController{
    UIButton* toolButtons[3][6];
    UIView* toolButtonView[3];
    NSMutableArray *directionButtons;
    NSMutableArray *itemsButtons;
}
@end
