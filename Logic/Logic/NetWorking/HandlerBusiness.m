//
//  HandlerBusiness.m
//  Orchid
//
//  Created by BG on 16/9/13.
//  Copyright © 2016年 ZUSTDMT. All rights reserved.
//

#import "HandlerBusiness.h"
#import "YYModel.h"
#define BaseURLString  @"http://localhost:3000/"

static HandlerBusiness *_sharedManager = nil;
static dispatch_once_t onceToken;
NSString *const ApiCodeGetFolderColor = @"getFolderColor";
NSString *const ApiCodeInsertFolderColor=@"insertFolderColor";
NSString *const ApiCodeGetImage=@"getImage";
NSString *const ApiCodeInsertImage=@"insertImage";
NSString *const ApiCodeDeleteImage=@"deleteImage";

@implementation HandlerBusiness

+(void)ServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(SuccessBlock)success Failed:(FailedBlock)failed Complete:(CompleteBlock)complete{
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HandlerBusiness alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
        _sharedManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
    });
    if (parameters==nil) {
        parameters = @{};
    }
    [_sharedManager POST:apicode parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if(complete != nil){
            complete();
        }
        NSString *modelStr = [HandlerBusiness mapModel][apicode];
        if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
            Class cla = NSClassFromString(modelStr);
            if (!cla) {
                NSLog(@"找不到对应模型类，%@", modelStr);
            }
            success([cla yy_modelWithJSON:responseObject[@"data"]],responseObject[@"msg"]);
        }
        else{
            success(responseObject,responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(complete != nil){
            complete();
        }
        failed([@-9999 integerValue] , @{@"prompt":@"网络错误",@"error":@"网络错误或接口调用失败"});
    }];
}

+(NSDictionary *)mapModel
{
    return @{
//             ApiCodeGetUserInfo:@"GetUserInfoModel",
             };
}
@end
