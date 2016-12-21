//
//  EditViewController.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditView.h"
#import "Item.h"

@interface EditViewController : UIViewController

@property (nonatomic,weak) IBOutlet EditView *editView;

@property (nonatomic,weak) UIViewController *projectVc;

@property(nonatomic,assign) Item *parentItem;


@end

