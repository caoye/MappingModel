//
//  ListDictModel.h
//  NewModel
//
//  Created by caoye on 16/7/19.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXPropertyInfo.h"

@interface CustomClass : NSObject

{
    @package
    
    NSDictionary * contDict;  //包涵的特殊类型的字典
    NSDictionary * changeDic; //需要映射字段的字典
}
@end

@interface ListDictModel : NSObject

@property (nonatomic, strong) NSMutableArray      * propertList;
@property (nonatomic, strong) CustomClass         * customClass;

@end



