//
//  Constant.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

//color
#define Rgb2UIColor(r, g, b, a)        [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:((a)/1.0)]

#define THEME_BGCOLOR Rgb2UIColor(43 , 75, 77, 1) //主背景色
#define SECOND_BGCOLOR Rgb2UIColor(37 , 65, 67, 1) //辅背景色
#define THIRD_BGCOLOR Rgb2UIColor(241 , 252, 252, 1) //底色
#define FOURTH_BGCOLOR Rgb2UIColor(247 , 85, 85, 1) //红色

#define FIRST_FONTCOLOR Rgb2UIColor(39 , 208, 216, 1) //主要字体色
#define SECOND_FONTCOLOR Rgb2UIColor(8 , 100, 105, 1) //笔记字体色
#define THIRD_FONTCOLOR Rgb2UIColor(41 , 128, 132, 1) //灰绿
#define FOURTH_FONTCOLOR Rgb2UIColor(137 , 207, 209, 1) //白绿

#define LINE_COLOR Rgb2UIColor(222 , 247, 249, 1) //线条色


//size
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#define SCREEN_WIDTH  ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define kImageUploadUrl @"http://up.imgapi.com/"
#define kToken @"97ade20b4c5a86b625cf449f45f720d686a0154f:Mlg-545PK1Jp5vnxH0v1RP1_vc4=:eyJkZWFkbGluZSI6MTQ2NzEyODc0OCwiYWN0aW9uIjoiZ2V0IiwidWlkIjoiNTY3OTU0IiwiYWlkIjoiMTIyNjk3MSIsImZyb20iOiJmaWxlIn0="

#endif /* Constant_h */
