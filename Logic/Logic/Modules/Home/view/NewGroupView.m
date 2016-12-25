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

- (void)showAtView:(UIView *)parentview
{
    if (v == nil) {
        v = [[UIView alloc]initWithFrame:parentview.bounds];
        v.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.1];
    }
    self.center = parentview.center;
    
    // 模糊效果
    if(flur==nil){
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        flur = [[UIVisualEffectView alloc] initWithEffect:effect];
        flur.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        flur.alpha = 0.8;
    }

    [self makeRound:8];
    [parentview addSubview:v];
    [parentview addSubview:flur];
    [parentview addSubview:self];
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
            _grpColor=@"#33898e";
            break;
        case 102:
            _grpColor=@"#27d0d8";
            break;
        case 103:
            _grpColor=@"#f75555";
            break;
        case 104:
            _grpColor=@"#fda529";
            break;
        case 105:
            _grpColor=@"#fe3e9b";
            break;
        default:
            break;
    }

}

- (IBAction)sureAdd:(id)sender {
    _grpName=_nameTxtField.text;
    [self dismiss];
    if (self.sureBlock) {
        self.sureBlock();
    }
}


@end
