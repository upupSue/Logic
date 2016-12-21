//
//  ImageUploadingView.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUploadingView : UIView

@property (nonatomic,copy) NSString *title;

@property (nonatomic,assign) CGFloat percent;

@property (nonatomic,copy) void(^cancelBlock)();

- (instancetype)initWithTitle:(NSString*)title cancelBlock:(void(^)())block;

- (void)show;

- (void)dismiss;

@end
