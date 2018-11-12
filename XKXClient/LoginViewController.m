//
//  LoginViewController.m
//  Chen DingXing
//
//  Created by Chen DingXing on 09/11/2018.
//  Copyright © 2018 Chen DingXing. All rights reserved.
//

#import "LoginViewController.h"
#import "GameViewController.h"
#import "GameLogic/GameLogic.h"

@interface LoginViewController () <GameLogicDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *firstToolView;
@property (nonatomic, strong) UIView *secondToolView;

@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UIButton *configButton;
@property (nonatomic, strong) UIButton *charListButton;
@property (nonatomic, strong) UIButton *createCharButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.delegate = self;
    [GameLogic shareInstance].delegate = self;

    [self decorateUIs];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[GameLogic shareInstance] ConnectMudServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)decorateUIs
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.textView];//地图
    [self.view addSubview:self.firstToolView];//按钮
    [self.view addSubview:self.secondToolView];//按钮
    [self.firstToolView addSubview:self.enterButton];
    [self.secondToolView addSubview:self.configButton];
    [self.firstToolView addSubview:self.charListButton];
    [self.secondToolView addSubview:self.createCharButton];
    [self.view setNeedsUpdateConstraints];
}

- (void) updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self.secondToolView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.secondToolView autoSetDimension:ALDimensionHeight toSize:60];
        [self.secondToolView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.secondToolView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.firstToolView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.secondToolView withOffset:-5];
        [self.firstToolView autoSetDimension:ALDimensionHeight toSize:60];
        [self.firstToolView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.firstToolView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.textView autoPinToTopLayoutGuideOfViewController:self withInset:0];
        [self.textView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.firstToolView];
        [self.textView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.textView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        NSArray *buttonsFirstLine = @[self.enterButton, self.charListButton];
        [buttonsFirstLine autoSetViewsDimension:ALDimensionHeight toSize:60.0];
        [buttonsFirstLine autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:5.0 insetSpacing:YES matchedSizes:YES];

        NSArray *buttonsSecondLine = @[self.configButton, self.createCharButton];
        [buttonsSecondLine autoSetViewsDimension:ALDimensionHeight toSize:60.0];
        [buttonsSecondLine autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:5.0 insetSpacing:YES matchedSizes:YES];

        self.didSetupConstraints = YES;
    }

    [super updateViewConstraints];
}

- (UIView *)textView
{
    if (!_textView) {
        _textView = [UITextView newAutoLayoutView];
        _textView.userInteractionEnabled = true;
        _textView.scrollEnabled = true;
        _textView.backgroundColor = [UIColor blackColor];
    }
    return _textView;
}

- (UIView *)firstToolView
{
    if (!_firstToolView) {
        _firstToolView = [UIView newAutoLayoutView];
        _firstToolView.backgroundColor = [UIColor blackColor];
    }
    return _firstToolView;
}

- (UIView *)secondToolView
{
    if (!_secondToolView) {
        _secondToolView = [UIView newAutoLayoutView];
        _secondToolView.backgroundColor = [UIColor blackColor];
    }
    return _secondToolView;
}

- (UIButton *)enterButton
{
    if (!_enterButton) {
        _enterButton = [UIButton newAutoLayoutView];
        _enterButton.backgroundColor = [UIColor darkGrayColor];
        [_enterButton setTitle:@"进入" forState:UIControlStateNormal];
        [_enterButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_enterButton addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [_enterButton addTarget:self action:@selector(buttonBackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];

        [_enterButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterButton;
}

- (UIButton *)configButton
{
    if (!_configButton) {
        _configButton = [UIButton newAutoLayoutView];
        _configButton.backgroundColor = [UIColor darkGrayColor];
        [_configButton setTitle:@"设定" forState:UIControlStateNormal];
        [_configButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_configButton addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [_configButton addTarget:self action:@selector(buttonBackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _configButton;
}

- (UIButton *)charListButton
{
    if (!_charListButton) {
        _charListButton = [UIButton newAutoLayoutView];
        _charListButton.backgroundColor = [UIColor darkGrayColor];
        [_charListButton setTitle:@"角色" forState:UIControlStateNormal];
        [_charListButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_charListButton addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [_charListButton addTarget:self action:@selector(buttonBackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _charListButton;
}

- (UIButton *)createCharButton
{
    if (!_createCharButton) {
        _createCharButton = [UIButton newAutoLayoutView];
        _createCharButton.backgroundColor = [UIColor darkGrayColor];
        [_createCharButton setTitle:@"创建角色" forState:UIControlStateNormal];
        [_createCharButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_createCharButton addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [_createCharButton addTarget:self action:@selector(buttonBackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createCharButton;
}

//  button高亮状态下的背景色
- (void)buttonBackGroundHighlighted:(UIButton *)sender
{
    sender.backgroundColor = [UIColor grayColor];
}

- (void)buttonBackGroundNormal:(UIButton *)sender
{
    sender.backgroundColor = [UIColor darkGrayColor];
}

- (void)appendText:(NSAttributedString *)msg
{
    if (msg == nil)
        return;

    __weak LoginViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{


        NSMutableAttributedString *fullTextAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:weakSelf.textView.attributedText];

        [fullTextAttributed appendAttributedString:msg];

        weakSelf.textView.attributedText = fullTextAttributed;
        //

        //[weakSelf.consoleView insertText:msg];
        [weakSelf.textView setNeedsDisplay];

        NSRange visibleRange = NSMakeRange(weakSelf.textView.text.length-2, 1);
        [weakSelf.textView scrollRangeToVisible:visibleRange];
    });

}

- (IBAction)enterGame:(UIButton *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"userName"];
    if (userName != nil) {
        [[GameLogic shareInstance] login];
    }
    else{
        [self inputUsernamePassword];
    }
}

- (void)inputUsernamePassword{
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请输入您的英文名字和密码"
                                                                   message:@"第一次登录"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         [[GameLogic shareInstance] loginWithUserNamePassword:alert.textFields[0].text Password:alert.textFields[1].text];
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             //NSLog(@"action = %@", alert.textFields);
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"英文名字";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
    }];

    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - GameLogicDelegate
- (void)showMessage:(NSAttributedString *)msg
{
    [self appendText:msg];
}

- (void)loginSuccessfully{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameViewController *gameVC = [storyboard instantiateViewControllerWithIdentifier:@"gameVC"];
    [self presentViewController:gameVC animated:YES completion:nil];
}

@end
