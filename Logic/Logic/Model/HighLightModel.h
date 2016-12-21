//
//  HighLightModel.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighLightModel : NSObject

@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIColor *backgroudColor;
@property (nonatomic,assign) BOOL italic;
@property (nonatomic,assign) BOOL strong;
@property (nonatomic,assign) BOOL deletionLine;
@property (nonatomic,assign) CGFloat size;

- (NSDictionary*)attribute;

@end
