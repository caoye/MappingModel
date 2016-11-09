//
//  NSObject+MXModel.h
//  NewModel
//
//  Created by caoye on 16/7/4.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MXModel <NSObject>

@optional
/**
 *  对特殊类型进行包涵处理比如NSArray类型
 *
 *  @return 返回包涵特殊对象的字典 比如：@{@"theArray":[ChildModel class]};
 */
+ (NSDictionary *)contentClass;

/**
 *  对特殊类型的映射
 *
 *  @return 返回映射的字典 比如：@{@"id":@"nameId"};
 */
+ (NSDictionary *)changeDictKey;

@end

@interface NSObject (MXModel)

/**
 *  将字典转化成model
 *
 *  @param dict 准备转化model的目标字典
 *
 *  @return 返回转化后的model对象
 */
- (instancetype)MXmodelWithDictionary:(NSDictionary *)dict;

/**
 *  将model转化成字典
 *
 *  @return 返回通过model转化成的NSDictionary
 */
- (NSDictionary *)modelToDict;

@end

NS_ASSUME_NONNULL_END