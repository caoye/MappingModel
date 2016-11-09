//
//  ListDictModel.m
//  NewModel
//
//  Created by caoye on 16/7/19.
//  Copyright © 2016年 caoye. All rights reserved.
//

#import "ListDictModel.h"

@implementation CustomClass



@end

@implementation ListDictModel

- (NSMutableArray *)propertList {
    if (!_propertList) {
        _propertList = [[NSMutableArray alloc] init];
    }
    return _propertList;
}

- (CustomClass *)customClass {
    if (!_customClass) {
        _customClass = [[CustomClass alloc] init];
    }
    return _customClass;
}

@end


