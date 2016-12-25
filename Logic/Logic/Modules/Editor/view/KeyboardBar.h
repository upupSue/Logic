//
//  KeyboardBar.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@protocol KeyboardBarDelegate <NSObject>

- (void)didInputText;

@end

@interface KeyboardBar : UIScrollView <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) UITextView *editView;
@property (nonatomic,weak) UIViewController *vc;
@property (nonatomic,weak) id<KeyboardBarDelegate> inputDelegate;

@property (nonatomic,weak) Item *item;


@end
