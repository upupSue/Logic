//
//  NSUserDefaults+Utils.h
//  Pods
//
//  Created by KentonYu on 16/6/29.
//
//

#import <Foundation/Foundation.h>

/**
 *  Keys:
 *  TouchIDVerify  // 是否需要 TouchID 验证
 */


@interface NSUserDefaults (Utils)

/**
 *  将字典存入 NSUserDefaults
 */
+ (void)saveWithDic:(NSDictionary *)dic;

/**
 *  将对象存入 NSUserDefaults
 */
+ (void)saveValue:(id) value forKey:(NSString *)key;

/**
 *  将 BOOL 值存入 NSUserDefaults
 */
+ (void)saveBoolValue:(BOOL)value withKey:(NSString *)key;

/**
 *  通过 key 取值
 */
+ (id)valueWithKey:(NSString *)key;

/**
 *  通过 key 取 BOOL 值
 */
+ (BOOL)boolValueWithKey:(NSString *)key;

/**
 *  移除指定的 key 的值
 */
+ (void)removeValueWithKey:(NSString *)key;

/**
 *  移除指定的数组
 */
+ (void)removeValueWithArray:(NSArray<NSString *> *)arr;

/**
 *  清空所有值
 */
+ (void)removeAllValue;

/**
 *  打印所有值
 */
+ (void)print;

@end
