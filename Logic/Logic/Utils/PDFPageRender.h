//
//  PDFPageRender.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFPageRender : UIPrintPageRenderer

@property (nonatomic,assign) CGFloat paperWidth;
@property (nonatomic,assign) CGFloat paperHeight;

- (NSData*)renderPDFFromHtmlString:(NSString*)htmlString;

@end
