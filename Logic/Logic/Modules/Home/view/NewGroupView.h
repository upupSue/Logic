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
@property (nonatomic,strong) NSString* grpName;
@property (nonatomic,assign) NSString* grpColor;
@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *tagTxtField;

- (instancetype)initWithSureBlock:(void (^)())block;

- (void)showAtView:(UIView *)parentview;


@end
