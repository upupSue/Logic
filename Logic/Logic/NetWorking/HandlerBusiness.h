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

@interface HandlerBusiness : AFHTTPSessionManager

//Handler处理完成后调用的Block
typedef void (^CompleteBlock)();
//Handler处理成功时调用的Block
typedef void (^SuccessBlock)(id data , id msg);
//Handler处理失败时调用的Block
typedef void (^FailedBlock)(NSInteger code ,id errorMsg);

+(void)ServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(SuccessBlock)success Failed:(FailedBlock)failed Complete:(CompleteBlock)complete;

@end
