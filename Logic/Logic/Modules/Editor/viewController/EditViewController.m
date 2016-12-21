//
//  EditViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "EditViewController.h"
#import "PreviewViewController.h"
#import "EditView.h"
#import "KeyboardBar.h"
#import "FileManager.h"
#import "Configure.h"
#import "AppDelegate.h"
#import "PathUtils.h"

@interface EditViewController () <UITextViewDelegate,KeyboardBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIView *centerview;

@end

@implementation EditViewController
{
    Item *item;
    FileManager *fm;
    BOOL needSave;
    UIControl *overView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fm = [FileManager sharedManager];
    [self loadFile];
    _editView.delegate = self;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
    // 指滑出现view
    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showAd:)];
    ges.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:ges];
    [self.editView.panGestureRecognizer requireGestureRecognizerToFail:ges];
}


- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    if (fm.currentItem == nil) {
        [self saveFile];
    }
    [self saveContent];
    [self.editView resignFirstResponder];
    if (kDevicePad) {
        return;
    }
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

- (void)viewDidLayoutSubviews{
    if ([Configure sharedConfigure].keyboardAssist && [Configure sharedConfigure].landscapeEdit == NO){
        KeyboardBar *bar = [[KeyboardBar alloc]init];
        bar.editView = _editView;
        bar.vc = self;
        bar.inputDelegate = self;
        _editView.inputAccessoryView = bar;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFile];
    });
}

- (void)loadFile{
    if (fm.currentItem == nil) {
        return;
    }
    item = fm.currentItem;
    
    NSString *path = item.fullPath;
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            stopLoadingAnimationOnParent(self.view);
            self.editView.text = text;
            self.editView.editable = YES;
            [self.editView updateSyntax];
            self.title = item.name;
        });
    });
}

//保存内容
- (void)saveContent
{
    if (item == nil) {
        return;
    }
    if (!needSave) {
        return;
    }
    item = fm.currentItem;
    NSData *content = [self.editView.text dataUsingEncoding:NSUTF8StringEncoding];
    [fm saveFile:item.fullPath Content:content];
    needSave = NO;
}

-(void)saveFile{
    NSString *name = [_editView.text componentsSeparatedByString:@"\n"][0];
    if (name.length == 0) {
        name = ZHLS(@"Untitled");
    }
    name = [name stringByAppendingString:@".md"];
    
    NSString *path = name;
    if (!_parentItem.root) {
        path = [_parentItem.path stringByAppendingPathComponent:name];
    }
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    i.cloud = _parentItem.cloud;
    if ([self.parentItem.items containsObject:i]) {
        
    }
    NSString *ret = [[FileManager sharedManager] createFile:i.fullPath Content:[NSData data]];
    if (ret.length == 0) {
        showToast(ZHLS(@"DuplicateError"));
        return;
    }
    NSString *prePath = localWorkspace();
    i.path = [ret stringByReplacingOccurrencesOfString:prePath withString:@""];
    [_parentItem addChild:i];
    fm.currentItem=i;
}

#pragma mark - 侧边栏
- (void)showAd:(UIScreenEdgePanGestureRecognizer *)ges {
    CGPoint p = [ges locationInView:self.view];
    if((SCREEN_WIDTH-p.x)>207){
        _leading.constant=-207;
    }
    else
        _leading.constant=-(SCREEN_WIDTH-p.x);
    float constant;
    if (ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateCancelled) {
        if (CGRectContainsPoint(self.view.frame, self.addView.center)) {
            constant=-207;
        }else{
            constant=0;
        }
        [UIView animateWithDuration:0.25 animations:^{
            _leading.constant=constant;
        }];
    }
    if(overView==nil){
        overView = [[UIControl alloc] init];
        overView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [overView addTarget:self action:@selector(hideview) forControlEvents:UIControlEventTouchDown];
        [_centerview addSubview:overView];
        UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(closeAd:)];
        [self.addView addGestureRecognizer:ges];
    }
    overView.backgroundColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:(SCREEN_WIDTH-p.x)/1000];
}

- (void)closeAd:(UIPanGestureRecognizer *)sender{
    CGPoint moviePoint = [sender translationInView:sender.view];
    if(moviePoint.x >= 0){
        _leading.constant+=moviePoint.x/50;
        overView.backgroundColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:-_leading.constant/1000];
    }
    if(moviePoint.x<0){
        if(_leading.constant==-207){}
        else _leading.constant-=moviePoint.x;
    }
    float constant;
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if (self.addView.center.x>SCREEN_WIDTH*3/4) {
            constant=0;
        }else{
            constant=-207;
        }
        [UIView animateWithDuration:0.25 animations:^{
            _leading.constant=constant;
        }];
    }
}

-(void)hideview{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _leading.constant=0;
                     }
                     completion:^(BOOL finished){
                         [overView removeFromSuperview];
                         overView=nil;
                     }];
}

#pragma mark - 输入
- (void)didInputText{
    needSave = YES;
}

- (void)keyboardHide:(NSNotification*)noti{
    self.bottom.constant = 0;
    [self.view updateConstraints];
}

- (void)keyboardShow:(NSNotification*)noti{
    NSDictionary *info = noti.userInfo;
    CGFloat keyboardHeight = kScreenHeight - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.bottom.constant = keyboardHeight;
    [self.view updateConstraints];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    needSave = YES;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    self.bottom.constant = 0;
    [self.view updateConstraints];
    return YES;
}


 #pragma mark - Navigation
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)show:(id)sender {
    PreviewViewController *vc=[[PreviewViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
