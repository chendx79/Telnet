//
//  TelnetViewController.m
//  BryanYuan
//
//  Created by Bryan Yuan on 28/12/2016.
//  Copyright © 2016 Bryan Yuan. All rights reserved.
//

#import "TelnetViewController.h"
#import "TelnetClient.h"
#import "AnsiEscapeHelper.h"
#import "PureLayout/PureLayout.h"

#define kANSIColorPrefKey_FgBlack    @"ansiColorsFgBlack"
#define kANSIColorPrefKey_FgWhite    @"ansiColorsFgWhite"
#define kANSIColorPrefKey_FgRed        @"ansiColorsFgRed"
#define kANSIColorPrefKey_FgGreen    @"ansiColorsFgGreen"
#define kANSIColorPrefKey_FgYellow    @"ansiColorsFgYellow"
#define kANSIColorPrefKey_FgBlue    @"ansiColorsFgBlue"
#define kANSIColorPrefKey_FgMagenta    @"ansiColorsFgMagenta"
#define kANSIColorPrefKey_FgCyan    @"ansiColorsFgCyan"
#define kANSIColorPrefKey_BgBlack    @"ansiColorsBgBlack"
#define kANSIColorPrefKey_BgWhite    @"ansiColorsBgWhite"
#define kANSIColorPrefKey_BgRed        @"ansiColorsBgRed"
#define kANSIColorPrefKey_BgGreen    @"ansiColorsBgGreen"
#define kANSIColorPrefKey_BgYellow    @"ansiColorsBgYellow"
#define kANSIColorPrefKey_BgBlue    @"ansiColorsBgBlue"
#define kANSIColorPrefKey_BgMagenta    @"ansiColorsBgMagenta"
#define kANSIColorPrefKey_BgCyan    @"ansiColorsBgCyan"

@interface TelnetViewController () <TelnetDelegate, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>
@property TelnetClient *client;
@property BOOL doEcho;

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *mapView;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UITextField *commandField;

@end

@implementation TelnetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.hostEntry.host;
    _client = [[TelnetClient alloc] init];
    _client.delegate = self;
    self.consoleView.delegate = self;
    self.doEcho = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBack"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(confirmQuit)];
    
    //[self.consoleView setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeSize:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeSize:) name:UIKeyboardDidHideNotification object:nil];

    [self.view addSubview:self.mapView];//地图
    [self.view addSubview:self.toolView];//按钮
    self.commandField.delegate = self;
    [self.toolView addSubview:self.commandField];//命令输入栏
    [self.view setNeedsUpdateConstraints];
}

- (void) updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self.mapView autoPinToTopLayoutGuideOfViewController:self withInset:0];
        [self.mapView autoSetDimensionsToSize:CGSizeMake(200, 100)];
        [self.mapView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.mapView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.toolView autoSetDimensionsToSize:CGSizeMake(200, 330)];
        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.toolView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        [self.consoleView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mapView];
        [self.consoleView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.toolView];
        [self.consoleView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.consoleView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.consoleView autoSetDimensionsToSize:CGSizeMake(200, 300)];

        [self.commandField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toolView withOffset:50];
        [self.commandField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.commandField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [self.commandField autoSetDimensionsToSize:CGSizeMake(200, 30)];

        self.didSetupConstraints = YES;
    }

    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    //self.consoleView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self.client setup:self.hostEntry];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.client = nil;
}

- (void)confirmQuit
{
    [self.consoleView resignFirstResponder];
    
    __weak TelnetViewController *weakSelf = self;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Terminate the session?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction* stopAction = [UIAlertAction actionWithTitle:@"Terminate" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action) {
                                                           [weakSelf.navigationController popViewControllerAnimated:YES];
                                                       }];
    
    [alert addAction:defaultAction];
    [alert addAction:stopAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (bool)appendText:(NSString *)msg
{
    if (msg == nil)
        return false;

    //处理AnsiEscapeString
    ANSIEscapeHelper *ansiEscapeHelper = [[ANSIEscapeHelper alloc] init];
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
    [ansiEscapeHelper setFont:[self.consoleView font]];

    NSAttributedString *attrStr;
    @try {
        attrStr = [ansiEscapeHelper attributedStringWithANSIEscapedString:msg];
    }
    @catch (NSException *exception) {
        return false;
    }

    __weak TelnetViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{


        NSMutableAttributedString *fullTextAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:weakSelf.consoleView.attributedText];

        [fullTextAttributed appendAttributedString:attrStr];

        weakSelf.consoleView.attributedText = fullTextAttributed;
        //

        //[weakSelf.consoleView insertText:msg];
        [weakSelf.consoleView setNeedsDisplay];
        
        NSRange visibleRange = NSMakeRange(weakSelf.consoleView.text.length-2, 1);
        [weakSelf.consoleView scrollRangeToVisible:visibleRange];
    });

    return true;
}

#pragma mark - UIKeyboardEvent

- (void)keyboardWillChangeSize:(NSNotification *)notification
{
    return;
    //NSLog(@"%s", __func__);
    NSDictionary *info = notification.userInfo;
    
    CGRect r = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"keyboard %@", NSStringFromCGRect(r));
    
    CGRect oriBound = self.consoleView.bounds;
    [self.consoleView setBounds:CGRectMake(0, 0, oriBound.size.width, oriBound.size.height-r.size.height)];
    [self.consoleView setCenter:CGPointMake(self.consoleView.bounds.size.width/2.0, self.consoleView.bounds.size.height/2.0)];
    [self.consoleView setNeedsLayout];
}

- (void)keyboardDidChangeSize:(NSNotification *)notification
{
    return;
    //NSLog(@"%s", __func__);
    
    [self.consoleView setBounds:self.view.bounds];
    [self.consoleView setCenter:self.view.center];
}

- (UIView *)mapView
{
    if (!_mapView) {
        _mapView = [UIView newAutoLayoutView];
        _mapView.backgroundColor = [UIColor grayColor];
    }
    return _mapView;
}

- (UIView *)toolView
{
    if (!_toolView) {
        _toolView = [UIView newAutoLayoutView];
        _toolView.backgroundColor = [UIColor grayColor];
    }
    return _toolView;
}

- (UITextField *)commandField
{
    if (!_commandField) {
        _commandField = [UITextField newAutoLayoutView];
        _commandField.backgroundColor = [UIColor whiteColor];
        [_commandField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_commandField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    }
    return _commandField;
}

#pragma mark - TelnetDelegate

- (bool)didReceiveMessage:(NSString *)msg
{
    NSLog(@"Got %lu string [%@]", [msg length], msg);
    return [self appendText:msg];
}

- (void)shouldEcho:(BOOL)echo
{
    //NSLog(@"%s %d", __func__, echo);
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.client writeMessage:text];
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        //NSLog(@"Backspace was pressed");
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //NSLog(@"%@", _commandField.text);
    [self.client writeMessage:[_commandField.text stringByAppendingString:@"\n"]];
    [_commandField selectAll:self];
    return YES;
}

@end
