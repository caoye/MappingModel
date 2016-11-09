//
//  PersonModel.m
//  NewModel
//
//  Created by caoye on 16/7/4.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import "PersonModel.h"

@implementation PersonModel

+ (NSDictionary *)contentClass {
    return @{@"theArray":[ChildModel class],@"theArr":[SubModel class]};
}

+ (NSDictionary *)changeDictKey {
    return @{@"name":@"namesssss"};
}

@end
