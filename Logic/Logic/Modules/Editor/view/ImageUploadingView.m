//
//  ImageUploadingView.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "ImageUploadingView.h"

@interface ImageUploadingView ()

@property (nonatomic,weak) IBOutlet UILabel *titleLable;
@property (nonatomic,weak) IBOutlet UIProgressView *percentView;
@property (nonatomic,weak) IBOutlet UIButton *cancelBtn;

@end

@implementation ImageUploadingView
{
    UIView *v;
}

- (instancetype)initWithTitle:(NSString *)title cancelBlock:(void (^)())block
{
    self =  [[NSBundle mainBundle]loadNibNamed:@"ImageUploadingView" owner:self options:nil].firstObject;
    self.bounds = CGRectMake(0, 0, 240, 160);
    if (self) {
        self.title = title;
        self.cancelBlock = block;
        self.percent = 0.0;
    }
    return self;
}

- (IBAction)cancel:(id)sender
{
    [self dismiss];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)setPercent:(CGFloat)percent
{
    _percent = percent;
    self.percentView.progress = percent;
}

- (void)setTitle:(NSString *)title
{
    self.titleLable.text = title;
    _title = title.copy;
}

- (void)show
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    if (v == nil) {
        v = [[UIView alloc]initWithFrame:window.bounds];
        v.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
    }
    self.center = window.center;
    [self makeRound:10];
    [window addSubview:v];
    [window addSubview:self];
}

- (void)dismiss{
    [v removeFromSuperview];
    [self removeFromSuperview];
}

@end
