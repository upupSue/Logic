//
//  MarkdownSyntaxGenerator.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MarkdownSyntaxModel.h"


extern NSRegularExpression* NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v);
extern NSDictionary* AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v);

@interface MarkdownSyntaxGenerator : NSObject
- (NSArray *)syntaxModelsForText:(NSString *) text;
@end
