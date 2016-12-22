//
//  NewGroupView.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/20.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "NewGroupView.h"

@interface NewGroupView ()

@property (weak, nonatomic) IBOutlet UIButton *tag1;
@property (weak, nonatomic) IBOutlet UIButton *tag2;
@property (weak, nonatomic) IBOutlet UIButton *tag3;
@property (weak, nonatomic) IBOutlet UIButton *tag4;
@property (weak, nonatomic) IBOutlet UIButton *tag5;


@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;

@property (weak, nonatomic) IBOutlet UITextField *groupName;



@end



@implementation NewGroupView
{
    UIView *v;
    UIVisualEffectView *flur;
}

- (instancetype)initWithSureBlock:(void (^)())block
{
    self =  [[NSBundle mainBundle]loadNibNamed:@"NewGroupView" owner:self options:nil].firstObject;
    self.bounds = CGRectMake(0, 0, 340*SCREEN_WIDTH/414, 484);
    if (self) {
        self.tag1.layer.cornerRadius = 12;
        self.tag2.layer.cornerRadius = 12;
        self.tag3.layer.cornerRadius = 12;
        self.tag4.layer.cornerRadius = 12;
        self.tag5.layer.cornerRadius = 12;
        
        self.color1.layer.cornerRadius = 5;
        self.color2.layer.cornerRadius = 5;
        self.color3.layer.cornerRadius = 5;
        self.color4.layer.cornerRadius = 5;
        self.color5.layer.cornerRadius = 5;

        self.sureBlock=block;

    }
    return self;
}

- (void)show
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    if (v == nil) {
        v = [[UIView alloc]initWithFrame:window.bounds];
        v.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.1];
    }
    self.center = window.center;
    
    // 模糊效果
    if(flur==nil){
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        flur = [[UIVisualEffectView alloc] initWithEffect:effect];
        flur.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        flur.alpha = 0.8;
    }

    [self makeRound:8];
    [window addSubview:v];
    [window addSubview:flur];
    [window addSubview:self];
}

- (void)dismiss{
    [flur removeFromSuperview];
    [v removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)hide:(id)sender {
    [self dismiss];
}

- (IBAction)selectedColor:(UIButton *)sender {

    if(sender.selected){
        sender.selected=NO;
    }
    else{
        _color1.selected=NO;
        _color2.selected=NO;
        _color3.selected=NO;
        _color4.selected=NO;
        _color5.selected=NO;
        sender.selected=YES;
    }
    switch (sender.tag) {
        case 101:
            _grpColor=Rgb2UIColor(51/255., 137/255., 142/255., 1.0);
            break;
        case 102:
            _grpColor=Rgb2UIColor(39/255., 208/255., 216/255., 1.0);
            break;
        case 103:
            _grpColor=Rgb2UIColor(247/255., 111/255., 111/255., 1.0);
            break;
        case 104:
            _grpColor=Rgb2UIColor(253/255., 178/255., 68/255., 1.0);
            break;
        case 105:
            _grpColor=Rgb2UIColor(252/255., 99/255., 171/255., 1.0);
            break;
        default:
            break;
    }

}

- (IBAction)sureAdd:(id)sender {
    _grpName=_groupName.text;
//    [Configure sharedConfigure].themeColor = _grpColor;
    [self dismiss];
    if (self.sureBlock) {
        self.sureBlock();
    }
}


@end
