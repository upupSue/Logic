//
//  MarkdownSyntaxModel.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//


#import "MarkdownSyntaxModel.h"

@implementation MarkdownSyntaxModel

- (instancetype)initWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.type = type;
    self.range = range;

    return self;
}

+ (instancetype)modelWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    return [[self alloc] initWithType:type range:range];
}

@end
