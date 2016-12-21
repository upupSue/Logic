//
//  Configure.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface Configure : NSObject <NSCoding>

@property (nonatomic,strong) NSString *style;

@property (nonatomic,strong) NSString *themeColor;

@property (nonatomic,strong) NSString *fontName;

@property (nonatomic,assign) CGFloat   fontSize;

@property (nonatomic,strong) NSDictionary *highlightColor;

@property (nonatomic,assign) NSInteger sortOption;

@property (nonatomic,assign) BOOL keyboardAssist;

@property (nonatomic,assign) BOOL landscapeEdit;

@property (nonatomic,strong) NSDate *upgradeTime;

@property (nonatomic,assign) CGFloat imageResolution;

@property (nonatomic,strong) NSString *currentVerion;

@property (nonatomic,strong) Item *defaultParent;

@property (nonatomic,strong) Item *defaultParentInCloud;

@property (nonatomic,assign) BOOL hasShownSwipeTips;

@property (nonatomic,assign) NSInteger useTimes;


+ (instancetype)sharedConfigure;

- (BOOL)saveToFile;

@end
