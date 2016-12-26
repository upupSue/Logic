//
//  HandlerBusiness.h
//  Orchid
//
//  Created by BG on 16/9/13.
//  Copyright © 2016年 ZUSTDMT. All rights reserved.
//

#import "AFNetworking.h"

extern NSString *const ApiCodeGetFolderColor;
extern NSString *const ApiCodeInsertFolderColor;
extern NSString *const ApiCodeGetImage;
extern NSString *const ApiCodeInsertImage;
extern NSString *const ApiCodeDeleteImage;

@interface HandlerBusiness : AFHTTPSessionManager

typedef void (^CompleteBlock)();
typedef void (^SuccessBlock)(id data , id msg);
typedef void (^FailedBlock)(NSInteger code ,id errorMsg);

+(void)ServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(SuccessBlock)success Failed:(FailedBlock)failed Complete:(CompleteBlock)complete;

@end
