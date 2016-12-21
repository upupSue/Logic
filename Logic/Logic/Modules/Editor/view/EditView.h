//
//  EditView.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBCKeyBoard;

@interface EditView : UITextView

@property (nonatomic,strong) ZBCKeyBoard *keyboard;

- (void)updateSyntax;

@end
