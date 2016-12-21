//
//  MarkdownSyntaxModel.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MarkdownSyntaxType){
    MarkdownSyntaxHeaders,
    MarkdownSyntaxTitle,
    MarkdownSyntaxLinks,
    MarkdownSyntaxImages,
    MarkdownSyntaxBold,
    MarkdownSyntaxEmphasis,
    MarkdownSyntaxDeletions,
    MarkdownSyntaxQuotes,
    MarkdownSyntaxBlockquotes,
    MarkdownSyntaxSeparate,
    MarkdownSyntaxULLists,
    MarkdownSyntaxOLLists,
    MarkdownSyntaxInlineCode,
    MarkdownSyntaxCodeBlock,
    MarkdownSyntaxImplicitCodeBlock,
    NumberOfMarkdownSyntax,
};

@interface MarkdownSyntaxModel : NSObject
@property(nonatomic) NSRange range;
@property(nonatomic) MarkdownSyntaxType type;

- (instancetype)initWithType:(enum MarkdownSyntaxType) type range:(NSRange) range;

+ (instancetype)modelWithType:(enum MarkdownSyntaxType) type range:(NSRange) range;

@end
