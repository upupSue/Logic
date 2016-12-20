//
//  NewGroupView.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/20.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGroupView : UIView

@property (nonatomic,copy) void(^sureBlock)();
@property (nonatomic,assign) NSString* grpName;
@property (nonatomic,assign) UIColor* grpColor;


- (instancetype)initWithSureBlock:(void (^)())block;

- (void)show;

@end
