//
//  NSUserDefaults+Utils.m
//  Pods
//
//  Created by KentonYu on 16/6/29.
//
//

#import "NSUserDefaults+Utils.h"

static NSString *const kUserDefaultsKey = @"DTUserDefaults";

@implementation NSUserDefaults (Utils)

+ (void)saveWithDic:(NSDictionary *)dic {
    NSArray * arrKeys = [dic allKeys];
    if (arrKeys.count>0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        if([userDefaults objectForKey:kUserDefaultsKey]){
            tempDic=[(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey] mutableCopy];
        }
        for (int i = 0; i < arrKeys.count; i ++) {
            [tempDic setValue:dic[arrKeys[i]] forKey:arrKeys[i]];
        }
        [userDefaults setObject:tempDic forKey:kUserDefaultsKey];
    }
}

+ (void)saveValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if([userDefaults objectForKey:kUserDefaultsKey]){
        dic = [(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    }
    [dic setObject:value forKey:key];
    [userDefaults setObject:dic forKey:kUserDefaultsKey];
}

+ (id)valueWithKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey] objectForKey:key];
}

+ (BOOL)boolValueWithKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [(NSNumber *)[(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey] objectForKey:key] boolValue];
}

+ (void)saveBoolValue:(BOOL)value withKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    if([userDefaults objectForKey:kUserDefaultsKey]){
        tempDic = [(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    }
    [tempDic setObject:[NSNumber numberWithBool:value] forKey:key];
    [userDefaults setObject:tempDic forKey:kUserDefaultsKey];
}

+ (void)removeValueWithKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    if([userDefaults objectForKey:kUserDefaultsKey]){
        tempDic = [(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey]mutableCopy];
    }
    [tempDic removeObjectForKey:key];
    [userDefaults setObject:tempDic forKey:kUserDefaultsKey];
}

+ (void)removeValueWithArray:(NSArray<NSString *> *)arr {
    if (arr&&arr.count>0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        if([userDefaults objectForKey:kUserDefaultsKey]){
            tempDic = [(NSMutableDictionary *)[userDefaults objectForKey:kUserDefaultsKey]mutableCopy];
        }
        for (int i = 0; i<arr.count; i++) {
            [tempDic removeObjectForKey:arr[i]];
        }
        [userDefaults setObject:tempDic forKey:kUserDefaultsKey];
        [userDefaults synchronize];
    }
}

+ (void)removeAllValue {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKey];
}

+ (void)print {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    NSLog(@"%@", dic);
}


@end
